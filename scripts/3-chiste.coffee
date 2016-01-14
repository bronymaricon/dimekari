# Description:
#   Chistes
#
# Commands:
#   hubot [b]chiste[/b] - Busca un chiste

S = require 'string'
module.exports = (robot) ->
  robot.respond /chiste$/i, (msg) ->
    msg.http('http://www.chistescortos.eu/random')      
      .get() (err, res, body) ->
        if !err
          pattern = /<div class=\"post\">(?:[^]+?)class=\"oldlink\">([^]+?)<\/a>/g
          match = pattern.exec(body)
          if match? and match.length > 1
            chiste = S(match[1].trim()).decodeHTMLEntities().replaceAll('<br />', '\n').s
            msg.send chiste