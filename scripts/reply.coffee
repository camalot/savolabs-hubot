# Description:
#   reaction gifs
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   /reply <tag>
#
# Author:
#   ryan conrad

request = require('request')
format = require("util").format
url = "http://replygif.net/api/gifs?tag=%s&api-key=39YAprx5Yi"

module.exports = (robot) ->
  robot.hear /^\/reply (.+)$/, (msg) ->
    tag = parseTag msg.match[1]
    get tag, (gifs) =>
      if gifs.length == 0
        robot.send "i got nothing, sorry: http://replygif.net/i/147.gif"
      else
        ind = Math.floor(Math.random() * gifs.length) || 0
        msg.send gifs[ind].file
  get = (tag, callback) ->
    xurl = format(url,tag)
    robot.http(xurl)
      .header("Accept", "application/json")
      .get() (err,res,body) =>
        if err
          callback []
          return
        data = JSON.parse body
        callback data
        return
  parseTag = (txt) ->
    txt.toLowerCase().replace(/[^\w \-]+/g,'').replace(/--+/g, '').replace(/\s/g,'+')
