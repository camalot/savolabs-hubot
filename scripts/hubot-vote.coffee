# Description:
#   simple room poll
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !poll new <poll-name> [description]: create a new poll
#   !poll start <poll-name> : start a poll (owner)
#   !poll stop <poll-name> : stop a poll (owner)
#   !poll add <poll-name> <item> : add item to poll (owner)
#   !poll remove <poll-name> <item> : remove item from poll (owner)
#   !poll list: list polls availale in channel
#   !poll list <poll-name>: list poll items
#   !poll delete <poll-name> : delete poll (owner)
#   !poll status <poll-name> : gets the poll status (owner)
#   !poll room list : Gets all polls in the channel (hubot-admin)
#   !poll room clear -force : Delete all polls in the channel (hubot-admin)
#   !poll stats : Displays a chart of some statistics
#   !vote <poll-name> <item|number>
# Author:
#   ryan conrad

inspect = (require('util')).inspect
module.exports = (robot) ->
  robot.brain.setAutoSave(true)
  eventActions = require('./event-actions/vote-actions')
  pollPattern = /^\!poll (?:(new|start|stop|results|add|remove|list|delete|status|room|stats)\s?)(.+?)?(?:\s(.+))?$/i
  votePattern = /^!vote (.+?) (.+)$/i
  robot.hear votePattern, (msg) ->
    action = "vote"
    pollId = msg.match[1]
    vote = msg.match[2]
    data =
      msg: msg
      poll:
        name: pollId
        query: vote

    triggerEvent "poll_#{action}", data, (what) ->
      msg.send what

    return
  robot.hear pollPattern, (msg) ->
    action = msg.match[1].trim().toLowerCase()
    eventName = "poll_#{action}"
    triggerEvent eventName, msg, (what) ->
      msg.send what
    return

  triggerEvent = (eventName, data, cb) ->
    if eventActions[eventName]?
      eventActions[eventName](data, cb)
