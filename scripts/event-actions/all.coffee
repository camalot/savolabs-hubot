#! /usr/bin/env coffee

#commit_comment,create,delete,deployment,deployment_status,fork,gollum,issue_comment,issues,member,membership,page_build,pull_request_review_comment,pull_request,push,repository,release,status,ping,team_add,watch

module.exports =
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
