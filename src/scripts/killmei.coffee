# Description
#   Killmei is the most important thing in life
#
# Dependencies:
#   "request": "^2.37.0"
#   "cheerio": "^0.17.0"
#   "q": "^1.0.1"
#
# Configuration:
#   None
#
# Commands:
#   hubot killmei          - receive a killme icon
#   hubot killmei bomb <N> - get N killme icons
#
# Author:
#   emanon001 <emanon001@gmail.com>
#

request = require 'request'
cheerio = require 'cheerio'
q = require 'q'

module.exports = (robot) ->
  getIconUrls = (->
    iconUrlCache = null
    ->
      deferred = q.defer()
      if iconUrlCache?
        deferred.resolve(iconUrlCache)
        return deferred.promise

      request
        .get 'http://killmebaby.tv/special_icon.html'
          , (e, _, body) ->
            if e?
              deferred.reject e
              return

            $ = cheerio.load body
            iconUrls = $('table.td01 td img').map(-> $(this).attr 'src').toArray()
            iconUrlCache = iconUrls
            deferred.resolve iconUrls

      deferred.promise
  )()

  random = (max) ->
    Math.floor Math.random() * (max + 1)

  choiceN = (coll, n) ->
    coll = [].concat coll
    [1..n].reduce (acc) ->
      i = random coll.length - 1
      acc.push coll[i]
      coll.splice i, 1
      acc
    , []

  robot.respond /killmei(\s+bomb(\s+(\d+))?)?/i, (msg) ->
    bomb = msg.match[1]?
    count = if bomb then msg.match[3] || 5 else 1

    getIconUrls()
    .then (iconUrls) ->
      choiceN(iconUrls, count).forEach (url) ->
        msg.send url
    , (e) ->
      robot.logger.error e.message
      res.send 'wasawasa'
