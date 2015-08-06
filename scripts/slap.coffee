# Made by Luke Kysow
#
# Description:
#   trout-slap is the second most important thing in your life
#
# Commands:
#   hubot slap TARGET - hubot will slap the specified target

slaps = [
  "around a bit with a large trout",
  "around a bit with a large pig",
  "around a bit with a large horse",
  "around a bit with a large cat",
  "around a bit with a Big Mac",
  "around a bit with a large dog",
  "around a bit with a computer",
  "around a bit with a stolen car",
]

module.exports = (robot) ->

  robot.respond /slap\s(.+)/i, (msg) ->
    target = msg.match[1].replace(/\s+$/g, "")
    msg.emote "slaps #{target} " + msg.random slaps
