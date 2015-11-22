#! /usr/bin/env coffee


# new|start|stop|results|pause|add|remove|list|delete
inspect = (require('util')).inspect

module.exports =
  poll_new: (data, callback) ->
    user = data.message.user
    robot = data.robot
    brain = robot.brain
    pollName = data.match[2].toLowerCase()
    pollKey = getPollKey data.message.room, user.name, pollName
    robot.logger.debug pollKey
    pexists = pollExists brain, pollKey
    robot.logger.debug "poll exists: #{pexists}"
    if pexists
      callback "@#{user.name}: You already have an active poll named \"#{pollName}\""
      return
    pollData =
      name: pollName
      user: user.name
      room: data.message.room
      key: pollKey
      active: true
      started: false,
      items: []
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
    callback "I haven't learned how to list a poll's result yet"
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

    return
  poll_delete: (data, callback) ->
    user = data.message.user
    robot = data.robot
    brain = robot.brain
    pollName = data.match[2].toLowerCase()
    pollKey = getPollKey data.message.room, user.name, pollName
    robot.logger.debug pollKey
    pexists = pollExists brain, pollKey
    robot.logger.debug "poll exists: #{pexists}"
    if !pexists
      callback "@#{user.name}: I cannot find a poll named #{pollName}"
      return
    deletePoll brain, pollKey
    callback "@#{user.name}: I have deleted the poll \"#{pollName}\""
    return
createPoll = (brain, data, cb) ->
  try
    brain.set data.key, data
    cb(true)
  catch error
    cb(false)
  return
getPoll = (brain, key) ->
  return (brain.get key)
deletePoll = (brain, key) ->
  brain.set key, null
pollExists = (brain, key) ->
  return (brain.get key)?
getPollKey = (room, user, poll) ->
  return "poll_#{room.toLowerCase()}_#{user.toLowerCase()}_#{poll.toLowerCase()}"
