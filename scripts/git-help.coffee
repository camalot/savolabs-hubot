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
#   !git help <topic> : get help for specific _topic_.
#   !git book : Pro Git ebook
#   !git video : A Channel 9 video on getting started with git.
#
# Author:
#   vquaiato, Jens Jahnke

# https://github.com/github/hubot-scripts/blob/master/src/scripts/git-help.coffee

jsdom = require("jsdom").jsdom

module.exports = (robot) ->
  robot.hear /^!git help (.+)$/i, (msg) ->
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
        see = $.trim $('#_see_also + .sectionbody .paragraph a')
        robot.logger.debug "see: #{see}"
        if name and desc
            msg.send "*#{name}*"
            msg.send desc
            
            msg.send "See #{url} for details."
        else
            msg.send "No git help page found for #{topic}."
      )
  robot.hear /^!git book$/i, (msg) ->
    msg.send "*Pro Git* by _Scott Chacon and Ben Straub_ : http://git-scm.com/book/en/v2"
  robot.hear /^!git video$/i, (msg) ->
    msg.send "*Getting Started with Git* with _Paul Litwin_ : https://channel9.msdn.com/Shows/Visual-Studio-Toolbox/Getting-Started-with-Git"
