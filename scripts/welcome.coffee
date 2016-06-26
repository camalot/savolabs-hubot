# Description:
#   Monitors the channel for when people enter
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   camalot

module.exports = (robot) ->
  add_nicks = (nicks) ->
    robot.brain.data.welcome.nicks ||= []
    nicks = [nicks] unless Array.isArray nicks
    for nick in robot.brain.data.welcome.nicks
      robot.brain.data.welcome.nicks.push nick
      robot.logger.debug "Added nick: #{nick}"

  robot.brain.on 'loaded', =>
    robot.brain.data.welcome.nicks ||= []

  if robot.adapter.bot?.addListener?
    robot.adapter.bot.addListener 'nick', (old_nick, new_nick, channels, message) ->
      add_nicks new_nick

    robot.adapter.bot.addListener 'names', (room, nicks) ->
      add_nicks Object.keys nicks

  robot.enter (res) ->
    if Array.isArray robot.brain.data.welcome.nicks
      user = res.message.user
      if user.name in robot.brain.data.welcome.nicks
        robot.logger.debug "I already have seen #{user.name} join"
        return
      add_nicks user.name
      res.send "Hello @#{user.name}! Welcome to ##{res.channel.name}!"
