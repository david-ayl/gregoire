# Description:
#   Send a cool message when the word `coincidence` is heard.
#
# Dependencies:
#   None
#
# Commands:
#   hubot coincidence - Send a cool message in relation with the sentence
#   `Coincidence ? I think NOT`
#
# Author:
#   cbellino

module.exports = (robot) ->
  messages = [
    "http://i.imgur.com/PhijPZB.gif"
    "http://i226.photobucket.com/albums/dd39/goblinmonger/coincidence-i-think-not_zps04c901d9.jpg"
    "http://4.bp.blogspot.com/-P9gxwF0HHdk/U45n01syy8I/AAAAAAAAFsQ/iAtqeuWU8G8/s1600/IThinkNot.gif"
  ]

  robot.hear /coincidence/ig, (msg) ->
    randomMessage = messages[Math.floor(Math.random() * messages.length)]

    msg.send randomMessage
