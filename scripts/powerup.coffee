# Description:
#   Notifies about any available GitHub repo event via webhook #
# Configuration:
#   HUBOT_GITHUB_EVENT_NOTIFIER_ROOM  - The default room to which message should go (optional)
#   HUBOT_GITHUB_EVENT_NOTIFIER_TYPES - Comma-separated list of event types to notify on
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
branch = process.env["HUBOT_GH_POWERUP_BRANCH"] || "master"
branchRegex = /\/refs\/heads\/#{branch}/i
eventActions =
  push: (data, callback) ->
    commit = data.after
    commits = data.commits
    head_commit = data.head_commit
    repo = data.repository
    pusher = data.pusher

    if !data.deleted
      callback "Power up! https://media1.giphy.com/media/rhdscFKah6Rva/200.gif"

  pull_request: (data, callback) ->
    pull_num = data.number
    pull_req = data.pull_request
    base = data.base
    repo = data.repository
    sender = data.sender

    action = data.action

    msg = "Pull Request \##{data.number} \"#{pull_req.title}\" "

    switch action
      when "opened"
        msg = "#{sender.login} submitted a powerup https://media4.giphy.com/media/3o85xCyoIze7YOLhfO/200.gif"
    callback msg
eventTypesRaw = ["push","pull_request"]
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
  robot.router.post "/hubot/gh-powerup", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    data = req.body
    robot.logger.debug "powerup: Received POST to /hubot/gh-powerup with data = #{inspect data}"
    allRooms = (query.room || process.env["HUBOT_GITHUB_EVENT_NOTIFIER_ROOM"] || "#general,#random").split(",")
    eventType = req.headers["x-github-event"]
    robot.logger.debug "powerup: Processing event type: \"#{eventType}\"..."
    rooms = []
    if req.body.rooms
      rooms = req.body.rooms.split(',')
    else
      rooms = allRooms

    try

      filter_parts = eventTypes
        .filter (e) ->
          # should always be at least two parts, from eventTypes creation above
          parts = e.split(":")
          event_part = parts[0]
          action_part = parts[1]

          if event_part != eventType
            return false # remove anything that isn't this event

          if action_part == "*"
            return true # wildcard on this event

          if !data.hasOwnProperty('action')
            return true # no action property, let it pass

          if action_part == data.action
            return true # action match

          return false # no match, fail

      if filter_parts.length > 0
        for room in rooms
          announceRepoEvent data, eventType, (what) ->
            robot.messageRoom room, what
      else
        console.log "Ignoring #{eventType}:#{data.action} as it's not allowed."
    catch error
      for room in rooms
        robot.messageRoom room, "Whoa, I got an error during powerup: #{error}"
      console.log "Github powerup error: #{error}. Request: #{req.body}"

    res.end ""

announceRepoEvent = (data, eventType, cb) ->
  if eventActions[eventType]?
    eventActions[eventType](data, cb)
