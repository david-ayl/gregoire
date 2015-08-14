# Made by Mehdi
#
# Description:
#   Shame the person just like Game of Thrones
#
# Commands:
#   hubot shame TARGET - hubot will shame the target
module.exports = (robot) ->

  robot.respond /shame\s(.+)/i, (msg) ->
    target = msg.match[1].replace(/\s+$/g, "")
    msg.send "#{target} : shame shame shame"
    msg.send "#{target} : :bell:"
