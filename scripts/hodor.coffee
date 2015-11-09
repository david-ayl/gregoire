# Description:
#   Hodor (https://gist.github.com/wjlroe/5612848).
#
# Commands:
#   hodor - Hodor!
#
# Author:
#   wjlroe
#

variantes = [
  'Hodor'
  'Hodor!'
  'Hodor?'
  'HODOR'
  'HODOR!'
  'HODOR?'
]

module.exports = (robot) ->
  robot.hear /hodor/i, (msg) ->
    msg.send variantes[Math.floor(Math.random() * variantes.length)]
