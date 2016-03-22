# Description:
#   A way to list the previews and production instances on the AYL network.
#
# Dependencies:
#   Firebase
#   rsvp
#   lodash
#   moment
#
# Commands:
#   hubot instances - List all the instances online.
#
# Author:
#   cbellino
#

Firebase = require("firebase")
RSVP = require("rsvp")
_ = require("lodash")
moment = require("moment")

# Debug settings
debugMode = process.env.HUBOT_DEBUG_MODE

# Github settings
githubAPIBaseURL = process.env.HUBOT_GITHUB_API_BASE_URL
githubOAuthToken = process.env.HUBOT_GITHUB_OAUTH_TOKEN
githubCommitBaseURL = process.env.HUBOT_COMMIT_BASE_URL # No trailing slash!

# Firebase settings
firebaseName = process.env.HUBOT_FIREBASE_NAME
firebaseInstancesNodeName = process.env.HUBOT_FIREBASE_INSTANCES_NODE
firebaseRef = new Firebase("https://#{firebaseName}.firebaseio.com/")
firebaseInstancesRef = firebaseRef.child(firebaseInstancesNodeName)

# Slack settings
slackAPIToken = process.env.HUBOT_SLACK_TOKEN
slackAPIBaseURL = process.env.HUBOT_SLACK_API_BASE_URL
slackAPIMessageURL = "#{slackAPIBaseURL}?token=#{slackAPIToken}"
slackIntroMessages = [
  "Aye aye Capt'n, here aaaaaare the previews:"
  "Yes milord..."
  "HEY! LISTEN! HEY! WATCH OUT! :navi:"
  "Prepare for unforseen consequences:"
  "IT'S DANGEROUS TO GO ALONE. TAKE THIS!"
  "Sorry, your preview is in another castle..."
  "The President has been kidnapped by ninjas. Are you a bad enough dude to rescue the president?"
  "I AM ERROR."
  "All your previews are belong to us."
  "I hate you so much."
]
slackColors = {
  red: "#f44336"
  blue: "#219ed2"
  green: "#78cd51"
  orange: "#fabb3d"
}

capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

createInstanceAttachment = (key, instance, user) ->
  attachment = { text: "" }

  if instance.requested_by && user
    if user.name
      attachment.author_name = "#{user.name}"
    else
      attachment.author_name = "#{user.login}"

    attachment.author_icon = "#{user.avatar_url}"
    attachment.author_link = "#{user.html_url}"

  if key
    attachment.text += "<https://#{key}.ayl.io|#{capitalizeFirstLetter(key)}>: "

  if instance.comment
    attachment.text += "#{instance.comment}. "

    # if instance.updated_at
    #   updatedAtDate = moment.unix(instance.updated_at)

    #   attachment.text += "Updated #{updatedAtDate.fromNow()}. "

  if instance.sha
    shaText = instance.sha.toLowerCase()
    shaLink = "#{githubCommitBaseURL}/#{shaText}"

    attachment.text += "<#{shaLink}|#{shaText.substring(1, 7)}>"

  if instance.status == "locked"
    attachment.color = slackColors.red

  else if instance.status == "used"
    attachment.color = slackColors.orange

  else
    attachment.color = slackColors.green

  return attachment

getJSON = (robot, url) ->
  promise = new RSVP.Promise( (resolve, reject) ->
    robot.http(url).get()((err, res, body) ->
      resolve(JSON.parse(body))

      return
    )

    return
  )

  return promise

getInstances = ->
  return new RSVP.Promise( (resolve, reject) ->
    firebaseInstancesRef.once("value", (snapshot) ->
      resolve(snapshot.val())
      return
    )

    return
  )

getInstancesUsers = (robot, instances) ->
  userURLs = []

  for own key, instance of instances
    userBaseURL = "#{githubAPIBaseURL}/users/#{instance.requested_by}"
    userURL = "#{userBaseURL}?access_token=#{githubOAuthToken}"

    if !_.contains(userURLs, userURL)
      userURLs.push(userURL)

  return userURLs.map( (url) ->
    return getJSON(robot, url)
  )

genericErrorLog = (error) ->
  if error
    console.error("Error: ", error)

  return

generateInstances = (robot, msg, instances, users) ->
  attachments = []
  url = slackAPIMessageURL

  for own key, instance of instances
    user = _.find(users, { login: instance.requested_by.toLowerCase() })
    attachments.push(createInstanceAttachment(key, instance, user))

  url += "&attachments=#{encodeURIComponent(JSON.stringify(attachments))}"
  introMessage = slackIntroMessages[Math.floor(
    Math.random() * slackIntroMessages.length
  )]

  # prepare the query
  data = {
    channel: encodeURIComponent("##{msg.message.room}")
    as_user: true
    username: "Grégoire"
    text: introMessage
  }

  if debugMode
    data.channel = encodeURIComponent("#api-tests")

  for property of data
    url += "&#{property}=#{data[property]}"

  # send the query
  robot.http(url).get()(genericErrorLog)

  return

generateResponse = (robot, msg) ->
  getInstances().then( (instances) ->
    usersPromises = getInstancesUsers(robot, instances)

    RSVP.all(usersPromises).then( (users) ->
      generateInstances(robot, msg, instances, users)
    , genericErrorLog)
  , genericErrorLog)

  return

module.exports = (robot) ->

  robot.respond(/instances/i, (msg) ->
    generateResponse(robot, msg)
  )
