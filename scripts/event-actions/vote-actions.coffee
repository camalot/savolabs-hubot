#! /usr/bin/env coffee


# new|start|stop|results|pause|add|remove|list|delete

# polls_root : {
#   rooms: {
#     roomName : {
#       polls : {
#         ""
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
      owner: user.name.toLowerCase()
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
    # https://chart.googleapis.com/chart?chxt=x,y&cht=bvs&chd=t:5,7,9,1&chco=76A4FB&chls=2.0&chs=250x250&chxl=0:|Jan|Feb|Mar|Apr|May
    user = data.message.user
    robot = data.robot
    logger = robot.logger
    brain = robot.brain
    pollName = (data.match[2] || "").toLowerCase()
    queryData =
      owner: user.name
      room: data.message.room.toLowerCase()
      name: pollName
    poll = getPoll(brain,queryData)

    if !(poll)?
      callback "@#{user.name}: I don't have any results for a poll named \"#{pollName}\""

    callback "https://chart.googleapis.com/chart?cht=bvg&chd=t:10,4,8,1,7&chco=76A4FB&chxt=x,y&chxl=0:|0|1|2|3|4|1:|0|10&chs=450x125&chds=0,10&chbh=30,15,35"
    return
  poll_pause: (data, callback) ->
    callback "I haven't learned how to pause a poll yet"
    return
  poll_add: (data, callback) ->
    callback "I haven't learned how to add an item yet"
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
      owner: user.name
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
        callback "@#{user.name}: I do not have a poll named \"#{pollName}\""
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
      owner: user.name.toLowerCase()
      room: data.message.room.toLowerCase()
    pexists = pollExists brain, pollData
    if !pexists
      callback "@#{user.name}: I cannot find a poll named \"#{pollName}\""
      return
    canDelete = canDeletePoll brain, pollData
    if !canDelete
      callback "@#{user.name}: sorry, you are not the owner of the poll \"#{pollName}\". You can't delete someone else's poll."
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
      owner: data.owner
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
canDeletePoll = (brain, data) ->
  if !(pollExists brain, data)
    return false
  p = getPoll brain, data
  return (p != null && p.owner == data.owner)?
deletePoll = (brain, data, cb) ->
  if !pollExists(brain,data)
    cb(false)
    return
  if !canDeletePoll(brain,data)?
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
