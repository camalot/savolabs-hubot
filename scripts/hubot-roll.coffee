# Description:
#   Allows Hubot to roll dice
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot roll (die|one|1) - Roll one six-sided dice
#   hubot roll dice - Roll two six-sided dice
#   hubot roll <x>d<y> - roll x dice, each of which has y sides
#   !roll [die|one|1] - Roll one six-sided dice
#   !roll [dice] - Roll two six-sided dice
#   !roll <x>d<y> - roll x dice, each of which has y sides
#
# Author:
#   ab9 : https://github.com/github/hubot-scripts/blob/master/src/scripts/dice.coffee
format = (require("util")).format
module.exports = (robot) ->
  robot.respond /roll (die|one|1)$/i, (msg) ->
    msg.reply report [rollOne(6)]
  robot.hear /^!roll (die|one|1)$/i, (msg) ->
    msg.reply report [rollOne(6)]
  robot.respond /roll(\sdice)?$/i, (msg) ->
    msg.reply report roll 2, 6
  robot.hear /^!roll(\sdice)?$/i, (msg) ->
    msg.reply report roll 2, 6
  robot.respond /roll (\d+)\s?d(\d+)$/i, (msg) ->
    rollAction msg
  robot.hear /^!roll (\d+)\s?d(\d+)$/i, (msg) ->
    rollAction msg

rollAction = (msg) ->
  dice = parseInt msg.match[1]
  sides = parseInt msg.match[2]
  answer = if dice <= 1
    "I cannot roll nothing"
  else if sides < 1
    "I don't know how to roll a zero-sided die."
  else if dice > 15
    "I'm not going to roll more than 15 dice for you."
  else
    report roll dice, sides
  msg.reply answer

report = (results) ->
  if results?
    switch results.length
      when 0
        "I didn't roll any dice."
      when 1
        "I rolled a #{results[0]}."
      else
        total = results.reduce (x, y) -> x + y
        finalComma = if (results.length > 2) then "," else ""
        last = results.pop()
        format("I rolled %s%s and %s, making %s.",results.join(", "),finalComma,last,total)

roll = (dice, sides) ->
  rollOne(sides) for i in [0...dice]

rollOne = (sides) ->
  1 + Math.floor(Math.random() * sides)
