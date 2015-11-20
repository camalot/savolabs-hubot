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
  randomBuzzWord = [
    "https://media1.giphy.com/media/13IKMvjqRIysHm/200.gif",
    "https://media3.giphy.com/media/Plo5B2kahH06k/200.gif",
    "https://media2.giphy.com/media/3kbkoDnCQJkm4/200.gif",
    "https://media0.giphy.com/media/hY3CjIvQajG8w/200.gif",
    "https://media1.giphy.com/media/HM0yrJYfXfeNi/200.gif",
    "https://media1.giphy.com/media/ntpzwedUHOycM/200.gif",
    "https://media3.giphy.com/media/8dmB4qPhZudOM/200.gif",
    "https://media1.giphy.com/media/EldfH1VJdbrwY/200.gif",
    "http://www.nooooooooooooooo.com/vader.jpg",
    "https://media3.giphy.com/media/1L5YuA6wpKkNO/200.gif",
    "https://media1.giphy.com/media/xTiTnoHt2NwerFMsCI/200.gif",
    "https://media2.giphy.com/media/s1sW9X81SbMVa/200.gif",
    "https://media4.giphy.com/media/A6x5SdKrGnYHu/200.gif",
    "https://media3.giphy.com/media/zfYpmAfrcVOAE/200.gif",
    "https://media0.giphy.com/media/xpLocgdzHqW9G/200.gif",
    "https://media1.giphy.com/media/Mcw4BnNE7T1PG/200.gif",
    "https://media0.giphy.com/media/11CGJUWW1TqnHW/200.gif",
    "https://media0.giphy.com/media/SyC4Pywv6Go1O/200.gif",
    "https://media1.giphy.com/media/Z9mJHxBD3n0aY/200.gif",
    "https://media1.giphy.com/media/122T1wvaC49HJS/200.gif",
    "https://media0.giphy.com/media/ntpzwedUHOycM/200.gif",
    "https://media1.giphy.com/media/HM0yrJYfXfeNi/200.gif",
    "https://media4.giphy.com/media/gLNxsIBRWQoZW/200.gif",
    "https://media4.giphy.com/media/1ET7hRlCcZLuE/200.gif",
    "https://media3.giphy.com/media/2SfBhaLXliChG/200.gif",
    "https://media4.giphy.com/media/aaw0ay7NqrucU/200.gif",
    "https://media4.giphy.com/media/YIbgEP9NpNY5O/200.gif",
    "https://media2.giphy.com/media/ALJI2lzh2Plcs/200.gif",
    "https://media2.giphy.com/media/9biCoFP1V2xZm/200.gif"
  ]
  robot.hear /(agile|orchestration|waterfall|automation|ansible|chef|puppet|azure|cloud|continuous (delivery|integration)|iaas|paas|iac|scrum|kanban)/i, (msg) ->
    msg.send msg.random randomBuzzWord
