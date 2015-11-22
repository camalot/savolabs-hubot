#! /usr/bin/env coffee


# new|start|stop|results|pause|add|remove|list|delete

# polls_root : {
#   rooms: {
#     roomName : {
#       polls : {
#         "poll_name": {
#           items: [
#             {
#               name: "item"
#               votes: [] // holds the usernames that voted (maybe more data)
#             }
#           ]
#           "voters": [] // holds the usernames that voted (maybe more data)
#         }
#       }
#     }
#   }
# }

inspect = (require('util')).inspect
keys =
  root : "polls_root"
  rooms : "rooms"
  polls : "polls"
  items : "items"
  item_name : "name"
  item_votes : "votes"
logger = null
module.exports =

  poll_new: (data, callback) ->
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    logger.debug("poll_new")
    brain = robot.brain
    pollName = data.match[2].toLowerCase()
    pollData =
      name: pollName
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
      if cb?
        callback "@#{user.name}: I have created the poll \"#{pollName}\". use !poll add #{pollName} <item> to add items."
      else
        robot.logger.debug("error while creating poll \"#{pollName}\"")

    return
  poll_start: (data, callback) ->
    callback "I haven't learned how to start a poll yet"
    return
  poll_stop: (data, callback) ->
    callback "I haven't learned how to stop a poll yet"
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

    if !(poll)?
      callback "@#{user.name}: I don't have any results for a poll named \"#{pollName}\""
      return
    callback "Poll Results (#{pollName}):\nhttps://chart.googleapis.com/chart?cht=bvg&chd=t:10,4,8,1,7&chco=76A4FB&chxt=x,y&chxl=0:|0|1|2|3|4|1:|0|10&chs=450x125&chds=0,10&chbh=30,15,35"
    return
  poll_pause: (data, callback) ->
    callback "I haven't learned how to pause a poll yet"
    return
  poll_add: (data, callback) ->
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
    if !(itemName || pollName)?
      return
    itemNameKey = itemName.toLowerCase()
    poll = getPoll(brain,queryData)
    # if the poll doesnt exist, or it has been started
    if (!(poll)? || poll.started )
      callback "@#{user.name}: I do not have a poll named \"#{pollName}\" that I can add an item to."
      return
    isOwner = isPollOwner brain, queryData
    if !isOwner
      callback "@#{user.name}: You do not have permission to add an item to this poll, it is owned by @#{poll.user}"
      return
    root = getRoot brain, queryData
    items = root[keys.rooms][queryData.room][keys.polls][queryData.name][keys.items]
    if (items[itemNameKey])?
      callback "@#{user.name}: I can't add that item. It already exists."
      return
    root[keys.rooms][queryData.room][keys.polls][queryData.name][keys.items][itemNameKey] =
      name: itemName
      votes: []
    brain.set keys.root, root
    callback "@#{user.name}: I added \"#{itemName}\" added to poll \"#{pollName}\""
    return
  poll_remove: (data, callback) ->
    callback "I haven't learned how to remove an item yet"
    return
  poll_list: (data, callback) ->
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
      callback msg
      return
    else # get specific poll
      poll = getPoll(brain,queryData)
      if (!(poll)?) || !poll.started
        callback "@#{user.name}: I do not have an active poll named \"#{pollName}\""
        return
      # a poll with fewer than 2 items should not be able to be started.
      msg = ""
      index = 0
      max = poll[keys.items].length
      for index in [0..max-1] by 1
        msg += "#{index+1}: #{poll[keys.items][index][keys.item_name]}\n"

      msg += "\nVote by using: !vote #{pollName} <number|name>"

      callback msg
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
    return
createPoll = (brain, data, cb) ->
  try
    roomPolls = getRoomPolls brain, data
    if roomPolls[data.name]?
      cb(false)
    root = getRoot brain, data
    root[keys.rooms][data.room][keys.polls][data.name] =
      name: data.name
      user: data.user
      room: data.room
      items: []
      started: false
    brain.set keys.root, root
    cb(true)
  catch error
    logger.error(error)
    cb(false)
  return
getRoomPolls = (brain, data) ->
  root = getRoot brain, data
  rooms = root[keys.rooms]
  if (!rooms? || !rooms[data.room]? || !rooms[data.room][keys.polls]?)
    root[keys.rooms] =
      "#{data.room}":
        "#{keys.polls}": {}
    brain.set keys.root, root
    return {}
  return rooms[data.room][keys.polls]
getPoll = (brain, data) ->
  root = getRoot brain, data
  rooms = root[keys.rooms]
  if (!rooms? || !rooms[data.room]? || !rooms[data.room][keys.polls]? || !rooms[data.room][keys.polls][data.name]?)
    return null
  result = root[keys.rooms][data.room][keys.polls][data.name]
  return result
getRoot = (brain, data) ->
  r = (brain.get keys.root)
  if r?
    return r
  else
    r =
      rooms: {}
  brain.set keys.root, r
isPollOwner = (brain, data) ->
  if !(pollExists brain, data)
    return false
  p = getPoll brain, data
  return (p != null && p.user == data.user)?
deletePoll = (brain, data, cb) ->
  if !pollExists(brain,data)
    cb(false)
    return
  if !isPollOwner(brain,data)?
    cb(false)
    return
  root = getRoot brain, data
  p = root[keys.rooms][data.room][keys.polls]
  delete p[data.name]
  brain.set keys.root, root
  cb(true)
pollExists = (brain, data) ->
  p = (getPoll(brain, data))?
  return p
