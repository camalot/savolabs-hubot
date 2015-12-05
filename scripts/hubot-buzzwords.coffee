# Description:
#   This is just some randomness
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !no[ooooooooooooo...]
#
# Author:
#   ryan conrad

module.exports = (robot) ->
  no_images = [
    "http://i.imgur.com/BlbH100.webm",
    "http://www.nooooooooooooooo.com/vader.jpg",
    "http://i.imgur.com/opNGKEP.webm",
    "http://i.imgur.com/FPipCdY.gifv"
  ]
  robot.hear /^\!no{1,}$/i, (msg) ->
    msg.send msg.random no_images
