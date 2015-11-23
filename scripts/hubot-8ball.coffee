# Description:
#   The Magic Eight ball
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot eightball <query> - Ask the magic eight ball a question
#
# Author:
#   ryanatwork : https://github.com/github/hubot-scripts/blob/master/src/scripts/eight-ball.coffee

ball = [
  "It is certain",
  "It is decidedly so",
  "Without a doubt",
  "Yes – definitely",
  "You may rely on it",
  "As I see it, yes",
  "Most likely",
  "Outlook good",
  "Signs point to yes",
  "Yes",
  "Reply hazy, try again",
  "Ask again later",
  "Better not tell you now",
  "Cannot predict now",
  "Concentrate and ask again",
  "Don't count on it",
  "My reply is no",
  "My sources say no",
  "Outlook not so good",
  "Very doubtful",
]

module.exports = (robot) ->
  robot.respond /(eightball|8-?ball)(.*)/i, (msg) ->
    msg.reply msg.random ball
