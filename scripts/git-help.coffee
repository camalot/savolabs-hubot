# Description:
#	 Show some help to git noobies
#
# Dependencies:
#	 jsdom
#	 jquery
#
# Configuration:
#	 None
#
# Commands:
#	 !git help <topic> : get help for specific _topic_.
#	 !git book : Pro Git ebook
#	 !git video : A Channel 9 video on getting started with git.
#
# Author:
#	 vquaiato, Jens Jahnke

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
				hname = $.trim($('#_name + .sectionbody .paragraph').text())
				robot.logger.debug "name: #{hname}"
				hdesc = $.trim($('#_synopsis + .sectionbody .content').text())
				robot.logger.debug "desc: #{hdesc}"
				hsee = $.trim $('#_see_also + .sectionbody .paragraph a')
				robot.logger.debug "see: #{hsee}"
				if name and desc
					msg.send "*#{hname}*"
					msg.send desc
					msg.send "See #{url} for details."
				else
					msg.respond "No git help page found for #{topic}."
			)
	robot.hear /^!git version$/i, (msg) ->
		url = 'http://git-scm.com/downloads'
		msg.http(url).get() (err,res,body) ->
			window = (jsdom body,
				features:
					FetchExternalResources: false
					ProcessExternalResources: false
					MutationEvents: false
					QuerySelector: false
			).defaultView
			jsdom.jQueryify(window, "http://code.jquery.com/jquery-2.2.0.js", () ->
				$ = window.$
				robot.logger.debug "getting version"
				dateText = $.trim($(".monitor .release-date").text())
				pattern = /\(([0-9]{4}-[0-9]{2}-[0-9]{2})\)/i
				if pattern.test dateText
					ver = $.trim($(".monitor .version").text())
					date = pattern.exec(dateText)[1]
					robot.logger.debug "date found: #{date}"
					robot.logger.debug "version: #{ver}"
					msg.respond "The latest version if git is _*#{ver}*_ and was released on #{date}"
					msg.send "Release Notes: https://raw.github.com/git/git/master/Documentation/RelNotes/#{ver}.txt"
				else
					msg.respond "I am having trouble locating the info on the latest version."
			)
	robot.hear /^!git book$/i, (msg) ->
		msg.send "*Pro Git* by _Scott Chacon and Ben Straub_ : http://git-scm.com/book/en/v2"
	robot.hear /^!git video$/i, (msg) ->
		msg.send "*Getting Started with Git* with _Paul Litwin_ : https://channel9.msdn.com/Shows/Visual-Studio-Toolbox/Getting-Started-with-Git"
