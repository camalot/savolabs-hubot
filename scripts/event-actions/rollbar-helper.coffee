rollbar = require("rollbar")
rollbarToken = process.env["HUBOT_ROLLBAR_KEY"]
unless rollbarToken
  rollbar =
    reportMessage: (message, level, req, callback) ->
      process.console.log(message)
    reportMessageWithPayloadData: (message, payloadData, req, callback) ->
      process.console.log(message)
      process.console.log(payloadData)
    handleErrorWithPayloadData: (err, payloadData, req, callback) ->
      process.console.error(err)
    handleError: (err, req, callback) ->
      process.console.error(err)
else
  rollbar.init(rollbarToken)

module.exports = rollbar
