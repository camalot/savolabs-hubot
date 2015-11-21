# Description:
#   Make hubot respect tables
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   "flipped table" - Hubot respects the table
#
# Author:
#   ryan conrad

module.exports = (robot) ->
  respects = [
      "┬─┬ノ(ಠ_ಠノ)",
      "┬─┬ノ(°□°ノ）",
      "┬─┬ノ( ゜-゜ノ)",
      "┬─┬╯(°□° ╯)",
      "┬─┬/(.□./）",
      "‎┬─┬ノ(ಥ益ಥノ）",
      "┬─┬ノ( ^_^ノ)",
      "┬─┬ ╯('□' ╯)",
      "┬─┬ノ(._.ノ)",
      "┬─┬ノʕ•ᴥ•ノʔ",
      "┬─┬ლ(⌒-⌒ლ)",
      "Please respect the table ┬─┬﻿ ノ(._.ノ)",
      "Please respect the table ┬─┬ノ(ಠ_ಠノ)",
      "https://media2.giphy.com/media/mKxsVRaYEXUgo/200.gif",
  ]
  robot.hear /(┻━┻|flip(ped)? tables?)/i, (msg) ->
    msg.send msg.random respects
  tableThanks = [
    "Always respect the table!",
    ":+1:",
    "** respects all the tables **"
  ]
  robot.hear /(┬─┬|respects? tables)/i, (msg) ->
    msg.send msg.random tableThanks
