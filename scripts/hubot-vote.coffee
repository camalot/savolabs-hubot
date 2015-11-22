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
#   !poll new <poll-name> : create a new poll
#   !poll start <poll-name> : start a poll
#   !poll stop <poll-name> : stop a poll
#   !poll add <poll-name> <item> : add item to poll
#   !poll remove <poll-name> <item> : remove item from poll
#   !poll list: list polls availale in channel
#   !poll list <poll-name>: list poll items
#   !poll delete <poll-name> : delete poll
#   !vote <poll-name> <item|number>
# Author:
#   ryan conrad

inspect = (require('util')).inspect
module.exports = (robot) ->
  eventActions = require('./event-actions/vote-actions')
  pollPattern = /\!poll (?:(new|start|stop|results|add|remove|list|delete)\s?)(.+?)?(?:\s(.+))?$/i
  robot.hear /\!brain/i, (msg) ->
    robot.logger.debug("#{inspect robot.brain.get("polls_root")}")
  robot.hear pollPattern, (msg) ->
    action = msg.match[1].trim().toLowerCase()
    eventName = "poll_#{action}"
    triggerEvent eventName, msg, (what) ->
      msg.send what

  triggerEvent = (eventName, data, cb) ->
    if eventActions[eventName]?
      eventActions[eventName](data, cb)
