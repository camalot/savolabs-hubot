#! /usr/bin/env coffee


# new|start|stop|results|add|remove|list|delete|status|room

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
#           created: "2015-11-23T05:11:28.677Z"
#
#           items: {
#             "item-key" : {
#               name: "item-key
#               user: "username" // should be the owner / or the hubot owner
#               created: "2015-11-23T05:11:28.677Z"
#               votes: [
#                 {
#                   time: "2015-11-23T05:11:28.677Z"
#                   room: "room-name"
#                   user: "username1"
#                 }
#               ] // holds the usernames that voted (maybe more data)
#             }
#           },
#           "voters": [ "username1", "username2" ] // holds the usernames that voted
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
  poll_room: (data, callback) ->
    # gets the polls in the room:
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    action = (data.match[2]||"list").toLowerCase()
    subAction = (data.match[3]||"").toLowerCase()
    queryData =
      user: user.name.toLowerCase()
      room: data.message.room.toLowerCase()

    if !isHubotOwner(brain,queryData)
      return
    switch action
      when "list"
        polls = getRoomPolls(brain, queryData)
        if polls == {}
          return
        pre_msg = "@#{queryData.user}: Here are the polls that were created in this channel:"
        msg = ""
        for own x, value of polls
          p = polls[x]
          msg += "\n\t#{p.name}: {created: #{p.created}; started: #{p.started}; owner: #{p.user};}"
        if msg.length > 0
          callback "#{pre_msg}#{msg}"
        return

      when "clear"
        # delete all polls
        if subAction != "-force"
          return

        root = getRoot brain, queryData
        logger.debug("find polls: [#{keys.root}][#{keys.rooms}][#{data.room}][#{keys.polls}]")
        polls = root[keys.rooms][queryData.room][keys.polls]
        count = 0
        for own x, value of polls
          count++
          delete polls[x]
        callback "@#{queryData.user}: I have deleted #{count} #{if count == 1 then "poll" else "polls"}"
        brain.set keys.root, root
        return
    return
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
      user: user.name
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
    chart = "https://chart.googleapis.com/chart?cht=bvg&chd=t:%s&chco=76A4FB&chxt=x,y&chxl=0:|%s|1:|0|%s&chs=550x275&chds=0,%s&chbh=30,15,35&chg=0,%s,0,0&chtt=%s&chts=777777,14,c"
    pollResults = getPollResults brain, queryData
    logger.debug("results: #{inspect pollResults}")
    high = pollResults.high + 5
    values = []
    labelsEncoded = []
    for idx in [0..pollResults.keys.length-1] by 1
      if pollResults.keys[idx]
        fullLabel = pollResults.keys[idx]
        if fullLabel.length > 7
          fullLabel = "#{fullLabel.substring(0,7)}…"
        labelsEncoded[labelsEncoded.length] = encodeURIComponent("#{fullLabel}(#{pollResults.counts[idx]})")
        values[values.length] = pollResults.counts[idx]
    # for idx in [0..itemsArray.length-1] by 1
    #   if pollResults.counts[idx]
    chartData =
      values: values.join(",")
      labels: labelsEncoded.join("|")
      max: high
    vals = chartData.values
    gline = Math.floor(100 / high)
    pollDesc = (poll.description || poll.name)
    pollDescEsc = encodeURIComponent(pollDesc)
    callback "Poll Results (#{pollDesc}):\n#{format(chart,vals.substring(0,vals.length-1), chartData.labels, chartData.max, chartData.max, gline, pollDescEsc)}"
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
      item: itemName
    addPollItem brain, queryData, callback
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
      item: itemName
    removePollItem brain, queryData, callback
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
      created: new Date
      started: false
      voters: []
    logger.debug("save root after create: #{inspect root}")
    brain.set keys.root, root
    cb(true)
  catch error
    logger.error(error)
    cb(false)
  return
getRoomPolls = (brain, data) ->
  root = getRoot brain, data
  logger.debug("find rooms: [#{keys.root}][#{keys.rooms}]")
  rooms = root[keys.rooms]
  logger.debug("#{inspect rooms}")
  if (!rooms || !rooms[data.room] || !rooms[data.room][keys.polls])
    logger.debug("creating object set for room [#{data.room}][#{keys.polls}]")
    root[keys.rooms] =
      "#{data.room}":
        "#{keys.polls}": {}
    logger.debug("save root: #{keys.root}: #{inspect root}")
    brain.set keys.root, root
    return {}
  return rooms[data.room][keys.polls]
getPoll = (brain, data) ->
  root = getRoot brain, data
  logger.debug("find rooms: [#{keys.root}][#{keys.rooms}]")
  rooms = root[keys.rooms]
  if (!rooms || !rooms[data.room] || !rooms[data.room][keys.polls] || !rooms[data.room][keys.polls][data.name])
    logger.debug("poll not found. [#{keys.root}][#{keys.rooms}][#{data.room}][#{keys.polls}][#{data.name}]")
    return null
  result = root[keys.rooms][data.room][keys.polls][data.name]
  logger.debug("return poll: #{inspect result}")
  return result
votePollItem = (brain, data, keyOrIndex, callback) ->

  poll = getPoll(brain,data)
  if !poll
    logger.debug("no poll found: #{data}")
    callback "@#{data.user}: I was unable to find the poll \"#{data.name}\""
    return
  else if !poll.started
    logger.debug("poll \"#{data.name}\" is not started.")
    callback "@#{data.user}: You can't vote on \"#{data.name}\". The poll has not been started."
    return
  root = getRoot brain, data
  logger.debug("find voters: [#{keys.root}][#{keys.rooms}][#{data.room}][#{keys.polls}][#{data.name}][#{keys.voters}]")
  voters = root[keys.rooms][data.room][keys.polls][data.name][keys.voters] || []
  logger.debug("voters: #{inspect voters}")
  filtered = (voters.filter (i) -> i.toLowerCase() == data.user.toLowerCase())
  if(filtered.length > 0)
    callback "@#{data.user}: Sorry, but you already cast your vote. No do-overs."
    return

  logger.debug("find items: [#{keys.root}][#{keys.rooms}][#{data.room}][#{keys.polls}][#{data.name}][#{keys.items}]")
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

  logger.debug("save root: #{keys.root} #{inspect root}")
  brain.set keys.root, root
  callback "@#{data.user}: I have recorded your vote for \"#{lookup}\" in poll \"#{data.name}\""
  return
getPollResults = (brain, data) ->
  poll = getPoll(brain,data)
  logger.debug("poll: #{inspect poll}")
  if !poll
    logger.debug("no poll to retrieve: return empty {}")
    return {}
  results = []
  resultKeys = []
  counts = []
  max = 0
  items = poll.items
  for own x, value of items
    cnt = items[x].votes.length
    logger.debug("add key: #{x}")
    resultKeys[resultKeys.length] = x
    counts[counts.length] = items[x].votes.length
    if cnt > max
      logger.debug("max changed to #{cnt}")
      max = cnt
    results[results.length] =
      "#{x}": items[x].votes.length
  out =
    high: max
    results: results
    keys: resultKeys
    counts: counts
  logger.debug("poll results: #{inspect out}")
  return out
addPollItem = (brain, data, callback) ->
  if (data.item == "" || data.name == "") || !(data.item || data.name)
    logger.debug("one is empty: (item: #{data.item} : poll: #{data.name})")
    return
  itemKey = data.item.toLowerCase()
  poll = getPoll(brain,data)
  # if the poll doesnt exist, or it has been started
  if !poll || poll.started
    callback "@#{data.user}: I do not have a poll named \"#{data.name}\" that I can add an item to."
    return
  isOwner = isPollOwner brain, data
  if !isOwner
    callback "@#{data.user}: You do not have permission to add an item to this poll, it is owned by @#{poll.user}"
    return
  root = getRoot brain, data
  items = root[keys.rooms][data.room][keys.polls][data.name][keys.items]
  if items[itemKey]
    callback "@#{data.user}: I can't add that item. It already exists."
    return
  root[keys.rooms][data.room][keys.polls][data.name][keys.items][itemKey] =
    name: data.item
    created: new Date # when it was added
    user: data.user # user that added it (should always be the owner, or the hubot owner :D)
    votes: []
  logger.debug("saving root: #{keys.root}: #{inspect root}")
  brain.set keys.root, root
  callback "@#{data.user}: I have added \"#{data.item}\" to poll \"#{data.name}\""
removePollItem = (brain, data, callback) ->
  if (data.item == "" || data.name == "") || !(data.item || data.name)
    logger.debug("one is empty: (item: #{data.item} : poll: #{data.name})")
    return
  itemKey = data.item.toLowerCase()
  poll = getPoll(brain,data)
  # if the poll doesnt exist, or it has been started
  if !poll || poll.started
    callback "@#{data.user}: I do not have a poll named \"#{data.name}\" that I can add an item to."
    return
  isOwner = isPollOwner brain, data
  if !isOwner
    callback "@#{data.user}: You do not have permission to add an item to this poll, it is owned by @#{poll.user}"
    return
  root = getRoot brain, data
  items = root[keys.rooms][data.room][keys.polls][data.name][keys.items]
  theItem = items[itemKey]
  if !theItem
    callback "@#{data.user}: I can't remove that item. It doesn't exist."
    return
  if theItem.votes && theItem.votes.length > 0
    callback "@#{data.user}: I can't remove that item. There are votes on it."
    return
  logger.debug("removing item: [#{keys.rooms}][#{data.room}][#{keys.polls}][#{data.name}][#{keys.items}][#{itemKey}]")
  delete root[keys.rooms][data.room][keys.polls][data.name][keys.items][itemKey]
  logger.debug("saving root: #{keys.root}: #{inspect root}")
  brain.set keys.root, root
  callback "@#{data.user}: I have removed \"#{data.item}\" from poll \"#{data.name}\""
getRoot = (brain, data) ->
  logger.debug("get root: #{keys.root}")
  r = (brain.get keys.root)
  if r
    logger.debug("root exists: #{inspect r}")
    return r
  else
    logger.debug("creating new root")
    r =
      "#{keys.rooms}":
        "#{data.room}":
          "#{keys.polls}"
  logger.debug("saving root: #{keys.root}")
  brain.set keys.root, r
isPollOwner = (brain, data) ->
  if !(pollExists brain, data)
    logger.debug("no poll found: #{inspect data}")
    return false
  p = getPoll brain, data
  logger.debug("poll: #{inspect data}")
  return ((p && p.user.toLowerCase() == data.user.toLowerCase()) || isHubotOwner(brain,data))
isHubotOwner = (brain, data) ->
  owner = process.env["HUBOT_OWNER"] || process.env["HUBOT_SLACK_BOTNAME"] || "__N_O__O_N_E__O_W_N_S__ME__"
  result = ((owner) && owner.toLowerCase() == data.user.toLowerCase())
  logger.debug("isHubotOwner: owner: {#{owner.toLowerCase()}}; user: {#{data.user.toLowerCase()}}")
  return result
deletePoll = (brain, data, cb) ->
  if !pollExists(brain,data)
    logger.debug("no poll: can't delete nothing.")
    cb(false)
    return
  if !isPollOwner(brain,data)
    logger.debug("not the owner: shame on you")
    cb(false)
    return
  root = getRoot brain, data
  logger.debug("find polls: [#{keys.root}][#{keys.rooms}][#{data.room}][#{keys.polls}]")
  p = root[keys.rooms][data.room][keys.polls]
  delete p[data.name]
  logger.debug("save root: #{keys.root} : #{inspect root}")
  brain.set keys.root, root
  cb(true)
pollExists = (brain, data) ->
  p = (getPoll(brain, data))
  return p != null && p != undefined
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

  if pollName.length == 0
    roomPolls = getRoomPolls(brain, queryData)
    logger.debug("polls: #{inspect roomPolls}")
    msg = ""
    pollCount = 0
    for own x, value of roomPolls
      pollCount++
      p = roomPolls[x]
      if (p.started)
        msg += "\n\t!poll list #{x}\n"
    if pollCount == 0
      callback "@#{user.name}: I am sorry, it seems that I don't have any active polls."
    else
      callback format("@#{user.name}: I have #{pollCount} active poll%s #{msg}", if pollCount > 1 then "s" else "")
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
