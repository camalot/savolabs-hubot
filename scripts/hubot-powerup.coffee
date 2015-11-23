# Description:
#   Notifies about any available GitHub repo event via webhook #
# Configuration:
#   HUBOT_POWERUP_ROOMS  - The default rooms to which message should go (optional)
#   HUBOT_GITHUB_EVENT_NOTIFIER_TYPES - Comma-separated list of event types to notify on
#   HUBOT_POWERUP_BRANCH - Comma-separated list of event types to notify on
#   (See: http://developer.github.com/webhooks/#events)
#
#   You will have to do the following:
#   1. Create a new webhook for your `myuser/myrepo` repository at:
#    https://github.com/myuser/myrepo/settings/hooks/new
#
#   2. Select the individual events to minimize the load on your Hubot.
#
#   3. Add the url: <HUBOT_URL>:<PORT>/hubot/gh-repo-events[?room=<room>]
#    (Don't forget to urlencode the room name, especially for IRC. Hint: # = %23)
#
# Commands:
#   None
#
# URLS:
#   POST /hubot/gh-repo-events?room=<room>
#
# Notes:
#   Currently tested with the following event types in HUBOT_GITHUB_EVENT_NOTIFIER_TYPES:
#     - issue
#     - page_build
#     - pull_request
#     - push
#
# Authors:
#   spajus
#   patcon
#   parkr

inspect = (require('util')).inspect
url = require('url')
querystring = require('querystring')
eventActions = require('./event-actions/powerup-actions')
eventTypesRaw = "push,pull_request:opened"
eventTypes = []

if eventTypesRaw?
  ###
  create a list like: "issues:* pull_request:comment pull_request:close fooevent:baraction"

  If any action is omitted, it will be appended with an asterisk (foo becomes foo:*) to
  indicate that any action on event foo is acceptable
  ###

  eventTypes = eventTypesRaw.split(',').map (e) ->
    append = ""

    # append :* to any elements missing it
    if e.indexOf(":") == -1
      append = ":*"

    return "#{e}#{append}"
else
  console.warn("powerup is not setup to receive any events.")

module.exports = (robot) ->
  robot.router.post "/hubot/powerup", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    data = req.body
    robot.logger.debug "powerup: Received POST to /hubot/powerup with data = #{inspect data}"
    rooms = (query.room || process.env["HUBOT_POWERUP_ROOMS"] || "#random").split(",")
    branch = (query.branch || process.env["HUBOT_POWERUP_BRANCH"] || "master")
    branchRegex = RegExp "(refs\/heads\/)?#{branch}$", "i"
    eventType = req.headers["x-github-event"]
    robot.logger.debug "powerup: Processing event type: \"#{eventType}\"..."
    try

      filter_parts = eventTypes
        .filter (e) ->
          # should always be at least two parts, from eventTypes creation above
          parts = e.split(":")
          event_part = parts[0]
          action_part = parts[1]

          if event_part != eventType
            return false # remove anything that isn't this event

          if !data.hasOwnProperty('action') || action_part == data.action || action_part == "*"
            branchMatch = false
            if data.ref # has the full ref path: /refs/heads/{branch}
              branchMatch = branchRegex.test(data.ref)
            else if data.head && data.head.ref
              branchMatch = branchRegex.test(data.head.ref)
            return branchMatch

          return false # no match, fail

      if filter_parts.length > 0
        for room in rooms
          announceRepoEvent data, eventType, (what) ->
            robot.messageRoom room, what

    catch error
      for room in rooms
        robot.messageRoom room, "I was unable to Power Up: #{error} http://replygif.net/i/1378.gif"
        console.log "powerup error: #{error}. Request: #{req.body}"

    res.end ""

announceRepoEvent = (data, eventType, cb) ->
  if eventActions[eventType]?
    eventActions[eventType](data, cb)
