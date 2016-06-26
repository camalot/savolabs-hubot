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

module.exports = (robot) ->
  robot.hear /(shit|fuck|ass-?hole|bitch|cunt|cock|dickhead|jack-?ass|whore)/i, (msg) ->
    language = [
      "language.",
      "_* earmuffs *_",
      "not in front of the children",
      "ooooooo, I'm telling mom",
      "you kiss robots with that mouth?",
      "yippee kiyay mother trucker",
      "http://i.imgur.com/XWQDGWe.jpg",
      "http://i.imgur.com/yv2jYns.jpg",
      "http://i.imgur.com/qAtjU1F.jpg",
      "http://i.imgur.com/r3YpfD6.jpg",
      "http://i.imgur.com/bstAx4u.jpg"
    ]

    resp = msg.random language
    msg.reply msg.random language
