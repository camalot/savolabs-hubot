# Description:
#   Hubot doesn't like swearing :D
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <swear word> - Hubot will respond letting you know to watch your language
#
# Author:
#   ryan conrad

language = [
  "#{msg.message.user.name}, language.",
  "_* earmuffs *_",
  "not in front of the children"
]

module.exports = (robot) ->
  robot.respond /(shit|fuck|ass-?hole|bitch|cunt|cock|dickhead|jack-?ass|whore)/i, (msg) ->
    resp = msg.random language
    msg.reply msg.random language
