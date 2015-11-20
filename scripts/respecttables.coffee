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
      '┬─┬ノ(ಠ_ಠノ)',
      '(╯°□°）╯︵ ┬─┬',
      '┬─┬﻿ ノ( ゜-゜ノ)',
      '┬─┬ ╯(°□° ╯)',
      '┬─┬﻿ ︵ /(.□. \）',
      '‎(ﾉಥ益ಥ）ﾉ ﻿︵ ┬─┬',
      '┬─┬ ノ( ^_^ノ)',
      "┬─┬ ︵  ╯('□' ╯)",
      '┬─┬ ~ ︵ (._.)',
      'ʕノ•ᴥ•ʔノ ︵ ┬─┬',
      '┬─┬ ︵ ლ(⌒-⌒ლ)',
      'Please respect the table! ┬─┬﻿ ノ( ゜-゜ノ)'
  ]
  robot.hear /(┻━┻|flip table)/i, (msg) ->
    msg.send msg.random respects
  tableThanks = [
    "Always respect the table!",
    "+1",
    "Hubot respects all the tables"
  ]
  robot.hear /(┬─┬|respect tables)/i, (msg) ->
    msg.send msg.random tableThanks
