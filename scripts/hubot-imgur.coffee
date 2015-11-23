# Description:
#   imgur search and reactions
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot imgur <search> - get random image from imgur based on the search
#   !imgur <search> - get random image from imgur based on the search
#   hubot reactgif nope - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif child fail - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif fuck - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif disgust - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif excited - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif clapping - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif stfu - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif angry - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif not bad - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif popcorn - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif haters - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif no read - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif mind blown - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif wut - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif cool story - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif umad - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif deal with it - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif no fucks - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif laughing - get random gif from reactiongifarchives.imgur.com
#   hubot reactgif self inflict - get random gif from reactiongifarchives.imgur.com
#
# Author:
#   ryan conrad

token = "Client-ID #{process.env["HUBOT_IMGUR_CLIENTID"]}"
unless process.env["HUBOT_IMGUR_CLIENTID"]
  throw new Error "HUBOT_IMGUR_CLIENTID not set: #{process.env["HUBOT_IMGUR_CLIENTID"]}"
format = require("util").format
inspect = (require('util')).inspect
api_url = "https://api.imgur.com/3/%s/%s"

module.exports = (robot) ->
  robot.respond /imgur (.+)$/i, (msg) ->
    imgur_search msg, robot
  robot.hear /^!imgur (.+)$/i, (msg) ->
    imgur_search msg, robot
  robot.respond /reactgif (.+)/i, (msg) ->
    switch msg.match[1]
      when "nope" then album = "JNzjB"
      when "child fail" then album = "Oc5Gp"
      when "fuck" then album = "aYJkp"
      when "disgust" then album = "AXues"
      when "excited" then album = "1GOKT"
      when "clapping" then album = "NzuZS"
      when "stfu" then album = "FGIfa"
      when "angry" then album = "qfkyX"
      when "not bad" then album = "LoNV2"
      when "popcorn" then album = "LPRbU"
      when "haters" then album = "yGacg"
      when "no read" then album = "tVg8K"
      when "mind blown" then album = "FEnwc"
      when "wut" then album = "ywmyw"
      when "cool story" then album = "yIdY2"
      when "umad" then album = "zKaIL"
      when "deal with it" then album = "K21Ft"
      when "no fucks" then album = "cB34U"
      when "laughing" then album = "s16Zv"
      when "self inflict" then album = "VvMv5"
      else "fail"
    full_url = format(api_url,"album",album)
    msg.http(full_url).headers('Authorization': token).get() (err, res, body) ->
      if res.statusCode is 200
        data = JSON.parse body
        msg.send data.data.images[Math.floor(Math.random() * data.data.images.length)].link
      else
        robot.logger.error "imgur-info script error: #{full_url} returned #{res.statusCode}: #{body}"

imgur_search = (msg, robot) ->
  search = msg.match[1]
  unless search
    return
  query_url = format(api_url, "gallery","top/?q=#{encodeURIComponent(search)}")
  msg.http(query_url)
    .headers("Authorization": token)
    .get() (err, res, body) ->
      if (res.statusCode is 200)
        imgur = JSON.parse body
        images = imgur.data.filter (x) ->
          return !x.nsfw && !x.is_album
        if images.length == 0
          robot.logger.debug("I found nothing")
          return
        randImg = images[Math.floor(Math.random() * images.length)]
        img_url = (randImg.gifv || randImg.mp4 || randImg.webm || randImg.link)
        msg.send "#{randImg.title}\n#{img_url}"
      else
        robot.logger.error "imgur: error: #{query_url} returned #{res.statusCode}: #{body}"
