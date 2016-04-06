# Description:
#   Do a Google Image search for a given keywords, extract the image URL and
#   sends it in a message.
#
#   Based on the work of @shao1555: https://github.com/shao1555/hubot-image-search
#
# Dependencies:
#   phantom
#
# Commands:
#   hubot image me - Find an image on Google using keywords
#
# Author:
#   cbellino
#   shao1555

phantom = require('phantom')

USER_AGENT_STRING = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5)
AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.110 Safari/537.36'
GOOGLE_SEARCH_BASE_URL = 'https://www.google.com/search'

generateResponse = (robot, res, prefix = '') ->
  query = encodeURIComponent(res.match[1])
  searchUrl = "#{GOOGLE_SEARCH_BASE_URL}?q=#{prefix}#{query}&tbm=isch"

  phantom.create().then (ph) ->
    ph.createPage().then (page) ->
      page.setting('userAgent', USER_AGENT_STRING).then ->
        page.open(searchUrl).then (status) ->
          if status == 'success'
            page.evaluate(() ->
              elements = document.querySelectorAll('div#isr_mc div.ivg-i a')
              element = elements[Math.floor(Math.random() * elements.length)]
              ret = undefined
              if element
                matches = element.getAttribute('href').match(/imgurl=(.*?)&/)
                if matches != null
                  ret = decodeURIComponent(decodeURIComponent(matches[1]))
              ret
            ).then (url) ->
              if url != null
                res.send url
              else
                res.send('Not found')
              ph.exit()

module.exports = (robot) ->

  robot.respond(/image (.+)/i, (res) ->
    generateResponse(robot, res)
  )

  robot.respond(/gif (.+)/i, (res) ->
    generateResponse(robot, res, 'animated gif ')
  )
