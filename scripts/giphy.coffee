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
#   "*buzzwords*" - Hubot likes buzzwords
#
# Author:
#   ryan conrad

module.exports = (robot) ->
  randomBuzzWordGiphy = [
    "/giphy bingo",
    "/giphy boom",
    "/giphy jif",
    "/giphy pronounced gif",
    "/giphy drop the bass",
    "/giphy drop it",
    "http://www.nooooooooooooooo.com/vader.jpg"
  ]
  robot.hear /(agile|orchestration|waterfall|automation|ansible|chef|puppet|azure|cloud|continuous (delivery|integration)|iaas|paas|iac|scrum|kanban)/i, (msg) ->
    msg.send msg.random randomBuzzWordGiphy
