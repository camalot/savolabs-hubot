#! /usr/bin/env coffee

#commit_comment,create,delete,deployment,deployment_status,fork,gollum,issue_comment,issues,member,membership,page_build,pull_request_review_comment,pull_request,push,repository,release,status,ping,team_add,watch


module.exports =
  pull_request: (data, callback) ->
    pull_num = data.number
    pull_req = data.pull_request
    base = data.base
    repo = data.repository
    sender = data.sender

    action = data.action

    switch action
      when "opened"
        callback "#{sender.login} initiated power up! \"#{pull_req.title}\" https://media3.giphy.com/media/rhdscFKah6Rva/200.gif"

  push: (data, callback) ->
    commit = data.after
    commits = data.commits
    head_commit = data.head_commit
    repo = data.repository
    pusher = data.pusher

    if !data.deleted
      # I like this one, but it's huge: https://media0.giphy.com/media/3o85xCyoIze7YOLhfO/200.gif
      callback "Power Up! thanks #{pusher.name}\n#{head_commit.message}\nhttps://media2.giphy.com/media/O5JBreFUy6ZIQ/200.gif"
