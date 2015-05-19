# Description:
#   A way to List the last changes done to the Back Office on the production
#   server.
#
# Dependencies:
#   Firebase
#
# Commands:
#   hubot changelog - List the last changes done to the Back Office
#
# Author:
#   cbellino
#

Firebase = require("firebase")

module.exports = (robot) ->
  firebaseName = process.env.HUBOT_FIREBASE_NAME
  commitBaseUrl = process.env.HUBOT_COMMIT_BASE_URL # No trailing slash
  firebaseRef = new Firebase("https://#{firebaseName}.firebaseio.com/")

  ref = firebaseRef.child("bo-changelog")

  robot.respond /changelog/i, (msg) ->
    ref.once "value", (snapshot) ->
      logs = snapshot.val()

      for own key, log of logs
        text = []

        # the title of the change
        if log.title
          text.push "*#{log.title}* :\n"

        if log.changes and log.changes.length > 0
          log.changes.forEach forEachChanges = (change) ->
            text.push "- #{change} -"

        msg.send text.join(" ")
