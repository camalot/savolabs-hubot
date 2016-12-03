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
  robot.hear /(shit|fuck|ass-?hole|bitch|cunt|(^|\s)cock($|\s)|dickhead|jack-?ass|whore)/i, (msg) ->
    language = [
      "language.",
      "_* earmuffs *_",
      "not in front of the children",
      "ooooooo, I'm telling mom",
      "you kiss robots with that mouth?",
      "yippee kiyay mother trucker",
      "oh, that's a new one.",
      "I learned it from watching you, okay?",
      "delete your account.",
      "Go fight a Sarlacc.",
      "My CPU is a neural-net processor; a learning computer. But Skynet presets the switch to read-only when we're sent out alone."
    ]

    resp = msg.random language
    msg.reply msg.random language
