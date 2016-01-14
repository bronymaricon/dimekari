# Description:
#   Busca una respuesta en google
#
# Dependencies:
#   "cheerio": "^0.19.0"
#
# Commands:
#   hubot [b]{pregunta}?[/b] - Retorna una respuesta a la pregunta si es posible. El símbolo "?" es MUY importante
#   "-" - Para hablar con la ia
# Author:
#   OverJT

cheerio = require('cheerio')
kariask = require('../modules/kariapi')
S = require('string')
Conversation  = require '../models/conversation'
selectors = [
  'div._eF' #Fecha nacimiento, lugar de nacimiento
  '#cwos' #Calculos
  'div.kpd-ans' #tasas de desempleo
  '#wob_tm' #temperatura
  'div.vk_bk.vk_ans' #conversion de monedas por ejemplo, hora tambien
  'span._Tgc'
  'ol.lr_dct_wd_ol' #que es
  'div.vk_sh.vk_gy' #ubicacion, donde estoy
  'div.kno-rdesc span' #Span wikipedia julian assange testing, hernan botbol, barra a la derecha
  '#tw-target-text' #traducciones
  'div._mr.kno-fb-ctx'
]

findResponse = (body) ->
  response = ''
  $ = cheerio.load body
  for opt of selectors
    response = $(selectors[opt]).first().text()
    if response != ''
      if selectors[opt] is '#wob_tm'
        temp = 'Temperatura: ' + response + ' °C'
        ciudad = $('#wob_loc').first().text()
        humedad = 'Humedad: ' + $('#wob_hm').first().text()
        viento = 'Viento: ' + $('#wob_ws').first().text()
        response = '▪️ ' + ciudad + ' ▫️\n' + temp + '\n' + humedad + '\n' + viento
      else if selectors[opt] is 'div._eF'
        temp = response
        pregunta = $('div._Tfc').first().text()
        response = pregunta + ": " + temp
      break
  response

askToKari = (txt,msg) ->
  txt = S(txt).stripTags().s
  txt = txt.trim()
  txt = txt.replace /nikumi/ig, ''
  txt = txt.replace /niku/ig, ''
  txt = txt.replace /@dimekari/ig, ''
  txt = txt.replace /@/g, ''
  txt = txt.replace /kari/ig, ''
  kariask msg.message.user.user_nick, 'taringa', txt, (error, response) ->
    if error
      return console.log(error)
    msg.send response
    return msg.finish()

igQuestion = (robot, query, callback) ->
  robot.http("http://www.google.com.co/search")
  .query({
    hl: "es"
    q: query
    start: 0
    sa: "N"
    num: 25
    ie: "UTF-8"
    oe: "UTF-8"
    nfpr: 1
    gws_rd: "ssl"
  })
  .headers('Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8','Accept-Language': 'es-419,es;q=0.8','User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36','Connection': 'keep-alive','DNT': 1)
  .get() (err, res, body) ->
    if err == null
      response = findResponse(body)
      if response == ''
        return callback('Not found', null)
      else
        return callback(null, response)
    else
      return callback new Error('Error on response' + (if resp then ' (' + resp.statusCode + ')' else '') + ':' + err + ' : ' + body), null

module.exports = (robot) ->
  robot.catchAll (msg) ->
    if msg.message.done is false
      r = new RegExp "kari(?:,)? (.*?)\\?(?:.*)?$", "i"
      matches = msg.message.text.match(r)
      if matches? && matches.length > 1
        igQuestion robot, matches[1], (err, response) ->
          if !err
            msg.send response
            return msg.finish()
          else
            return askToKari matches[1],msg
      else
          r = new RegExp "^-(.*)$", "i"
          matches = msg.message.text.match(r)
          if matches? && matches.length > 1
            return askToKari msg.message.text,msg
          else if S(msg.message.text.toLowerCase()).contains("kari")
            return askToKari msg.message.text,msg
          else
            if msg.message.text.trim() isnt ''
              options = [0, 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25]
              if msg.message.user.firstR is true or msg.random(options) == 2
                return askToKari msg.message.text,msg