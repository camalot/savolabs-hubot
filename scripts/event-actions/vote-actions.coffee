#! /usr/bin/env coffee


# new|start|stop|results|add|remove|list|delete|status|

# polls_root : {
#   rooms: {
#     roomName : {
#       polls : {
#         "poll_name": {
#           name: "poll-name",
#           description: "poll description text",
#           user: "poll-owner-username",
#           started: false,
#           room: "room-name",
#           items: {
#             "item-key" : {
#               name: "item-key
#               votes: [] // holds the usernames that voted (maybe more data)
#             }
#           },
#           "voters": [] // holds the usernames that voted (maybe more data)
#         }
#       }
#     }
#   }
# }

inspect = (require('util')).inspect
format = (require("util")).format
keys =
  root : "polls_root"
  rooms : "rooms"
  polls : "polls"
  items : "items"
  item_name : "name"
  item_votes : "votes"
  voters: "voters"
logger = null
module.exports =

  poll_new: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = data.match[2].toLowerCase()
    pollDescription = data.match[3]
    pollData =
      name: pollName
      description: pollDescription
      user: user.name.toLowerCase()
      room: data.message.room.toLowerCase()
      started: false

    pexists = pollExists brain, pollData
    robot.logger.debug "poll exists: #{pexists}"
    if pexists
      callback "@#{user.name}: there is already an active poll named \"#{pollName}\" in this channel. Please choose a different name."
      return
    robot.logger.debug "#{inspect pollData}"
    createPoll brain, pollData, (cb) ->
      if cb
        callback "@#{user.name}: I have created the poll \"#{pollName}\". use !poll add #{pollName} <item> to add items."
      else
        robot.logger.debug("error while creating poll \"#{pollName}\"")
    brain.save()
    return
  poll_start: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = (data.match[2] || "").toLowerCase()

    queryData =
      user: user.name
      room: data.message.room.toLowerCase()
      name: pollName
    isOwner = isPollOwner brain, queryData
    if !isOwner
      callback "@#{user.name}: You do not own this poll, you cannot start it."
      return
    poll = getPoll(brain,queryData)

    # if the poll doesnt exist, or it has been started
    if !poll
      callback "@#{user.name}: I do not have a poll named \"#{pollName}\" that I can start."
      return
    if poll.started
      callback "@#{user.name}: The poll \"#{pollName}\" is already started."
      return
    # get items count
    itemCount = 0
    for own x, value of poll["items"]
      itemCount++
    if itemCount < 2
      callback "@#{user.name}: The poll \"#{pollName}\" must have at least 2 items to start it."
      return
    root = getRoot brain, queryData
    root[keys.rooms][queryData.room][keys.polls][queryData.name]["started"] = true
    brain.set keys.root, root
    listPolls(data,callback)
    brain.save()
    return
  poll_stop: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = (data.match[2] || "").toLowerCase()

    queryData =
      user: user.name.toLowerCase()
      room: data.message.room.toLowerCase()
      name: pollName
    isOwner = isPollOwner brain, queryData
    if !isOwner
      callback "@#{user.name}: You do not own this poll, you cannot stop it."
      return
    poll = getPoll(brain,queryData)

    # if the poll doesnt exist, or it has been started
    if !poll
      callback "@#{user.name}: I do not have a poll named \"#{pollName}\" that I can stop."
      return
    if !poll.started
      callback "@#{user.name}: The poll \"#{pollName}\" is already stopped."
      return
    root = getRoot brain, queryData
    root[keys.rooms][queryData.room][keys.polls][queryData.name]["started"] = false
    brain.set keys.root, root
    callback "@#{user.name}: I have stopped the poll \"#{pollName}\"."
    brain.save()
    return
  poll_results: (data, callback) ->
    # https://chart.googleapis.com/chart?cht=bvg&chd=t:10,4,8,1,7&chco=76A4FB&chxt=x,y&chxl=0:|0|1|2|3|4|1:|0|10&chs=450x125&chds=0,10&chbh=30,15,35
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = (data.match[2] || "").toLowerCase()
    queryData =
      user: user.name
      room: data.message.room.toLowerCase()
      name: pollName
    poll = getPoll(brain,queryData)

    if !poll
      callback "@#{user.name}: I don't have any results for a poll named \"#{pollName}\""
      return
    itemsArray = []
    for own x, value of poll.items
      itemsArray[itemsArray.length] = x
    if itemsArray.length < 2
      # this poll can not be "resulted"
      return

    # chd = values
    # chxl:0 = x:labels
    # chxl:1 = y:labels
    # chds = chard data scaling
    # chbh = bar width,padding,spacing
    # chg = chart graph lines
    # chts = chart title style
    # chtt = chart title text
    chart = "https://chart.googleapis.com/chart?cht=bvg&chd=t:%s&chco=76A4FB&chxt=x,y&chxl=0:|%s|1:|0|%s&chs=450x175&chds=0,%s&chbh=30,15,35&chg=0,%s,0,0&chtt=%s&chts=777777,14,c"
    pollResults = getPollResults brain, queryData
    logger.debug("results: #{inspect pollResults}")
    high = pollResults.high + 5
    values = []
    for idx in [0..itemsArray.length] by 1
      values[values.length] = pollResults.counts[idx]
    chartData =
      values: values.join(",")
      labels: pollResults.keys.join("|")
      max: high
    vals = chartData.values
    gline = Math.floor(100 / high)
    pollDesc = encodeURIComponent(poll.description || poll.name)
    callback "Poll Results (#{pollName}):\n#{format(chart,vals.substring(0,vals.length-1), chartData.labels, chartData.max, chartData.max, gline, pollDesc)}"
    brain.save()
    return
  poll_add: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = (data.match[2] || "").toLowerCase()
    itemName = (data.match[3] || "")

    queryData =
      user: user.name.toLowerCase()
      room: data.message.room.toLowerCase()
      name: pollName
    if (itemName == "" || pollName == "")
      logger.debug("item: #{itemName} : poll: #{pollName}")
      return
    itemNameKey = itemName.toLowerCase()
    poll = getPoll(brain,queryData)
    # if the poll doesnt exist, or it has been started
    if !poll || poll.started
      callback "@#{user.name}: I do not have a poll named \"#{pollName}\" that I can add an item to."
      return
    isOwner = isPollOwner brain, queryData
    if !isOwner
      callback "@#{user.name}: You do not have permission to add an item to this poll, it is owned by @#{poll.user}"
      return
    root = getRoot brain, queryData
    items = root[keys.rooms][queryData.room][keys.polls][queryData.name][keys.items]
    if items[itemNameKey]
      callback "@#{user.name}: I can't add that item. It already exists."
      return
    root[keys.rooms][queryData.room][keys.polls][queryData.name][keys.items][itemNameKey] =
      name: itemName
      votes: []
    brain.set keys.root, root
    callback "@#{user.name}: I have added \"#{itemName}\" to poll \"#{pollName}\""
    brain.save()
    return
  poll_remove: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = (data.match[2] || "").toLowerCase()
    itemName = (data.match[3])

    queryData =
      user: user.name
      room: data.message.room.toLowerCase()
      name: pollName
    if !(itemName || pollName)
      return
    itemNameKey = itemName.toLowerCase()
    poll = getPoll(brain,queryData)
    # if the poll doesnt exist, or it has been started
    if !poll || poll.started
      callback "@#{user.name}: I do not have a poll named \"#{pollName}\" that I can add an item to."
      return
    isOwner = isPollOwner brain, queryData
    if !isOwner
      callback "@#{user.name}: You do not have permission to add an item to this poll, it is owned by @#{poll.user}"
      return
    root = getRoot brain, queryData
    items = root[keys.rooms][queryData.room][keys.polls][queryData.name][keys.items]
    if !(items[itemNameKey])
      callback "@#{user.name}: I can't remove that item. It doesn't exist."
      return
    delete root[keys.rooms][queryData.room][keys.polls][queryData.name][keys.items][itemNameKey]
    brain.set keys.root, root
    callback "@#{user.name}: I have removed \"#{itemName}\" from poll \"#{pollName}\""
    brain.save()
    return
  poll_status: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = (data.match[2] || "").toLowerCase()
    queryData =
      user: user.name
      room: data.message.room.toLowerCase()
      name: pollName
    isOwner = isPollOwner brain, queryData
    poll = getPoll(brain,queryData)
    if !poll
      callback "@#{user.name}: I do not have an active poll named \"#{pollName}\""
      return
    if !isOwner
      callback "@#{user.name}: You do not own the poll \"#{pollName}\". You cannot request the status."
      return

    msg = "Poll Status: #{pollName}\n"
    msg += "\tstarted: #{poll.started}\n"
    if poll.description
      msg += "\t#{poll.description}\n"

    logger.debug("poll: #{inspect poll}")
    index = 0
    for own x, value of poll[keys.items]
      msg += "\t#{index+1}: #{poll[keys.items][x][keys.item_name]}\n"
      index++
    callback msg
    brain.save()
    return
  poll_list: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain

    listPolls(data,callback)
    brain.save()
    return
  poll_delete: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = data.match[2].toLowerCase()
    pollData =
      name: pollName
      user: user.name.toLowerCase()
      room: data.message.room.toLowerCase()
    pexists = pollExists brain, pollData
    if !pexists
      callback "@#{user.name}: I cannot find a poll named \"#{pollName}\""
      return
    poll = getPoll brain, pollData
    canDelete = isPollOwner brain, pollData
    if !canDelete
      callback "@#{user.name}: sorry, you are not the owner of the poll \"#{pollName}\". You can't delete @#{poll.user}'s poll."
      return
    deletePoll brain, pollData, (cb) ->
      if cb
        callback "@#{user.name}: I have deleted the poll \"#{pollName}\""
      else
        callback "@#{user.name}: There was some catastrophic error that caused time to skip. As a result, I couldn't delete \"#{pollName}\"."
    brain.save()
    return
  poll_vote: (data, callback) ->
    msg = data.msg
    voteInfo = data.poll
    user = msg.message.user
    robot = msg.robot
    logger = robot.logger
    brain = robot.brain
    queryData =
      user: user.name.toLowerCase()
      room: msg.message.room.toLowerCase()
      name: voteInfo.name.toLowerCase()
    votePollItem(brain, queryData, voteInfo.query, callback)
    brain.save()
    return
createPoll = (brain, data, cb) ->
  try
    roomPolls = getRoomPolls brain, data
    if roomPolls[data.name]
      cb(false)
    root = getRoot brain, data
    root[keys.rooms][data.room][keys.polls][data.name] =
      name: data.name
      user: data.user
      room: data.room
      description: data.description
      items: {}
      started: false
      voters: []
    brain.set keys.root, root
    cb(true)
  catch error
    logger.error(error)
    cb(false)
  return
getRoomPolls = (brain, data) ->
  root = getRoot brain, data
  rooms = root[keys.rooms]
  if (!rooms || !rooms[data.room] || !rooms[data.room][keys.polls])
    root[keys.rooms] =
      "#{data.room}":
        "#{keys.polls}": {}
    brain.set keys.root, root
    return {}
  return rooms[data.room][keys.polls]
getPoll = (brain, data) ->
  root = getRoot brain, data
  rooms = root[keys.rooms]
  if (!rooms || !rooms[data.room] || !rooms[data.room][keys.polls] || !rooms[data.room][keys.polls][data.name])
    return null
  result = root[keys.rooms][data.room][keys.polls][data.name]
  return result
votePollItem = (brain, data, keyOrIndex, callback) ->

  poll = getPoll(brain,data)
  if !poll
    callback "@#{data.user}: I was unable to find the poll \"#{data.name}\""
    return
  else if !poll.started
    logger.debug("poll \"#{data.name}\" is not started.")
    return
  root = getRoot brain, data
  voters = root[keys.rooms][data.room][keys.polls][data.name][keys.voters] || []

  filtered = (voters.filter (i) -> i.toLowerCase() == data.user.toLowerCase())
  if(filtered.length > 0)
    callback "@#{data.user}: Sorry, but you already casted your vote. No do-overs."
    return

  items = root[keys.rooms][data.room][keys.polls][data.name][keys.items]

  index = parseInt(keyOrIndex)
  lookup = keyOrIndex
  if !isNaN(index)
    logger.debug("got the index value: #{index}")
    # get by index
    i = 0
    for own x, value of items
      logger.debug("checking #{i} == #{index}")
      if i == (index-1)
        logger.debug("setting lookup : #{x}")
        lookup = x
        break
      i++
  # this will probably never happen
  if !lookup
    logger.debug("lookup is empty")
    callback "@#{data.user}: I was unable to locate the item \"#{keyOrIndex}\" in the poll \"#{data.name}\""
    return

  # now we have the name, get the item
  item = items[lookup.toLowerCase()]
  if !(item)
    logger.debug("items: #{inspect items}")
    callback "@#{data.user}: I was unable to locate the item \"#{keyOrIndex}\" in the poll \"#{data.name}\""
    return

  voters[voters.length] = data.user.toLowerCase()
  votes = item[keys.item_votes]
  votes[votes.length] =
    time: new Date
    room: data.room
    user: data.user.toLowerCase()
  brain.set keys.root, root
  callback "@#{data.user}: I have recorded your vote for \"#{lookup}\" in poll \"#{data.name}\""
  return
getPollResults = (brain, data) ->
  poll = getPoll(brain,data)
  logger.debug("poll: #{poll}")
  if !poll
    return {}
  results = []
  keys = []
  counts = []
  max = 0
  items = poll.items
  for own x, value of items
    cnt = items[x].votes.length
    keys[keys.length] = x
    counts[counts.length] = items[x].votes.length
    if cnt > max
      max = cnt
    results[results.length] =
      "#{x}": items[x].votes.length
  out =
    high: max
    results: results
    keys: keys
    counts: counts
  return out
getRoot = (brain, data) ->
  r = (brain.get keys.root)
  if r
    return r
  else
    r =
      "#{keys.rooms}":
        "#{data.room}":
          "#{keys.polls}"
  brain.set keys.root, r
isPollOwner = (brain, data) ->
  if !(pollExists brain, data)
    logger.warn("no poll found: #{inspect data}")
    return false
  p = getPoll brain, data
  logger.warn("poll: #{inspect data}")
  return ((p != null && p.user.toLowerCase() == data.user.toLowerCase()) || isHubotOwner(brain,data))
isHubotOwner = (brain, data) ->
  owner = process.env["HUBOT_OWNER"] || process.env["HUBOT_SLACK_BOTNAME"] || "__N_O__O_N_E__O_W_N_S__ME__"
  return ((owner) && owner.toLowerCase() == data.user.toLowerCase())
deletePoll = (brain, data, cb) ->
  if !pollExists(brain,data)
    cb(false)
    return
  if !isPollOwner(brain,data)
    cb(false)
    return
  root = getRoot brain, data
  p = root[keys.rooms][data.room][keys.polls]
  delete p[data.name]
  brain.set keys.root, root
  cb(true)
pollExists = (brain, data) ->
  p = (getPoll(brain, data))
  return p
listPolls = (data, callback) ->
  user = data.message.user
  robot = data.robot
  logger = robot.logger
  brain = robot.brain
  pollName = (data.match[2] || "").toLowerCase()
  queryData =
    user: user.name
    room: data.message.room.toLowerCase()
    name: pollName

  if pollName == ""
    roomPolls = getRoomPolls(brain, queryData)
    logger.debug("polls: #{inspect roomPolls}")
    msg = ""
    for own x, value of roomPolls
      p = roomPolls[x]
      if (p.started)
        msg += "!poll list #{x}\n"
    if msg.length == 0
      callback "It seems that I don't have any active polls"
    else
      callback msg
    return
  else # get specific poll
    poll = getPoll(brain,queryData)
    if !poll || !poll.started
      callback "@#{user.name}: I do not have an active poll named \"#{pollName}\""
      return
    # a poll with fewer than 2 items should not be able to be started.
    msg = ""
    if (poll.description)
      msg += "#{poll.description}\n"
    else
      msg += "#{poll.name}\n"
    index = 0
    for own x, value of poll[keys.items]
      msg += "\n\t#{index+1}: #{poll[keys.items][x][keys.item_name]}"
      index++

    msg += "\nVote by using: !vote #{pollName} <number|name>"

    callback msg
  return
