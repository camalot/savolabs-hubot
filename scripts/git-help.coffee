# Description:
#   Show some help to git noobies
#
# Dependencies:
#   jsdom
#   jquery
#
# Configuration:
#   None
#
# Commands:
#   git help <topic>
#
# Author:
#   vquaiato, Jens Jahnke

# https://github.com/github/hubot-scripts/blob/master/src/scripts/git-help.coffee

jsdom = require("jsdom").jsdom

module.exports = (robot) ->
  robot.respond /!git help (.+)$/i, (msg) ->
    topic = msg.match[1].toLowerCase()

    url = 'http://git-scm.com/docs/git-' + topic
    msg.http(url).get() (err, res, body) ->
      window = (jsdom body,
        features:
          FetchExternalResources: false
          ProcessExternalResources: false
          MutationEvents: false
          QuerySelector: false
      ).defaultView
      jsdom.jQueryify(window, "http://code.jquery.com/jquery-2.2.0.js", () -> 
        $ = window.$
        name = $.trim $('#_name + .sectionbody .paragraph').text()
        robot.logger.debug "name: #{name}"
        desc = $.trim $('#_synopsis + .sectionbody .content').text()
        robot.logger.debug "desc: #{desc}"
        if name and desc
            msg.send "*#{name}*"
            msg.send desc
            msg.send "See #{url} for details."
        else
            msg.send "No git help page found for #{topic}."
      )
  robot.respond /!git book$/i, (msg) -> 
    msg.send "*Git Pro* by _Scott Chacon and Ben Straub_ : http://git-scm.com/book/en/v2"