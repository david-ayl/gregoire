# Description:
#   A way to list the previews and production instances on the AYL network.
#
# Commands:
#   hubot instances - List all the instances online.
Firebase = require("firebase")

module.exports = (robot) ->
  firebaseName = process.env.HUBOT_FIREBASE_NAME
  firebaseRef = new Firebase("https://#{firebaseName}.firebaseio.com/")

  ref = firebaseRef.child("ayl-instances")

  robot.respond /instances/i, (msg) ->
    ref.once "value", (snapshot) ->
      instances = snapshot.val()

      for own key, instance of instances
        text = []

        # the name of the instance
        text.push "*#{key}*"

        # the sha
        # TODO: add a link to the commit on github
        if instance.sha
          text.push "#{instance.sha.toLowerCase()}"

        # the person who requested the deployment
        # TODO: add a link to the user on slack
        if instance.requested_by
          text.push "- @#{instance.requested_by.toLowerCase()}"

        msg.send text.join(" ")
