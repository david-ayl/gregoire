Firebase = require("firebase")

module.exports = (robot) ->
  firebaseName = process.env.HUBOT_FIREBASE_NAME
  firebaseRef = new Firebase("https://#{firebaseName}.firebaseio.com/")

  ref = firebaseRef.child("previews")

  robot.respond /previews/i, (msg) ->
    ref.once "value", (snapshot) ->
      previews = snapshot.val()

      for own key, preview of previews
        text = []
        text.push "*preview-#{key}*"
        text.push "#{preview.sha.toLowerCase()}" if preview.sha
        text.push "- @#{preview.used_by.toLowerCase()}" if preview.used_by

        msg.send text.join(" ")
