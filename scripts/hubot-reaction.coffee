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
#   !<reply|react> <tag>
#   hubot what do you think about ...
#   hubot how do you feel about ...
#   hubot can i get your opinion about ...
#
# Author:
#   ryan conrad

module.exports = (robot) ->
  format = (require("util")).format
  apiUrl = "http://replygif.net/api/gifs?%s=%s&api-key=39YAprx5Yi"
  reactions = ["yes","no","happy","sad","thumbs+up","thumbs+down","flirt","angry","awkward","wtf","ok","exclamation+mark","question+mark","ellipsis","meh","misc"]
  replyPattern = /^\!(?:reply|react(?:ion)?) (.+)$/i
  reactPattern = /(?:(?:can i get your (?:opinion|thought)s? (?:on|about|concerning))|(?:what do you think|how do you feel)(?: about)?) (.+?)\??$/i

  robot.respond reactPattern, (msg) ->
    idx = Math.floor(Math.random() * reactions.length) || 0
    getReaction reactions[idx], (gifs) ->
      if gifs.length == 0
        msg.send "I am not actually sure how to respond to that."
      else
        rand = Math.floor(Math.random() * gifs.length) || 0
        msg.send gifs[idx].file

  robot.hear replyPattern, (msg) ->
    tag = parseTag msg.match[1]
    getTag tag, (gifs) ->
      if gifs.length == 0
        msg.send "i got nothing, sorry: http://replygif.net/i/147.gif"
      else
        idx = Math.floor(Math.random() * gifs.length) || 0
        msg.send gifs[idx].file

  getReaction = (react, callback) ->
    url = format(apiUrl,"reply",react)
    robot.http(url)
      .header("Accept", "application/json")
      .get() (err,res,body) ->
        if err
          callback []
          return
        data = JSON.parse body
        callback data
        return

  getTag = (tag, callback) ->
    xtag = tag
    if (/smoke(\+|\s|-)you/i).test(xtag)
      xtag = "fuck+you"
    url = format(apiUrl,"tag", xtag)
    robot.http(url)
      .header("Accept", "application/json")
      .get() (err,res,body) ->
        if err
          callback []
          return
        data = JSON.parse body
        callback data
        return

  parseTag = (txt) ->
    return txt.toLowerCase().replace(/[^\w \-]+/g,'').replace(/--+/g, '').replace(/\s/g,'+')
