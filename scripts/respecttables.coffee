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
  robot.hear /┻━┻/i, (msg) ->
    msg.send msg.random respects
