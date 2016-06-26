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
      "(ง°ل͜°)ง┬─┬",
      "┬─┬ノ( ^_^ノ)",
      "┬─┬ ╯('□' ╯)",
      "┬─┬ノ(._.ノ)",
      "┬─┬ノʕ•ᴥ•ノʔ",
      "┬─┬ლ(⌒-⌒ლ)",
      "Please respect the table ┬─┬﻿ ノ(._.ノ)",
      "Please respect the table ┬─┬ノ(ಠ_ಠノ)",
      "http://i.imgur.com/pMFDPcg.gifv",
  ]
  robot.hear /(table\s?flip(ped)|┻━┻|flip(ped)? tables?)/i, (msg) ->
    msg.send msg.random respects
  tableThanks = [
    "Always respect the table!",
    ":+1:",
    "** respects all the tables **"
  ]
  robot.hear /(┬─┬|respects? tables)/i, (msg) ->
    msg.send msg.random tableThanks
