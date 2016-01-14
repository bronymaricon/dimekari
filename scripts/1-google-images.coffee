# Description:
#   Busca imagenes en google images
#
# Commands:
#   hubot [b]img[/b] texto - Busca una imagen relacionada con <texto>
#   hubot [b]gif[/b] texto - Lo mismo que img pero devuelve un gif animado
#   hubot [b]mostacho[/b] texto - Busca una imagen que concuerde con <texto> y le añade un mostacho
S = require "string"
whitelist = [
  "overjt",
  "anpep",
  "pozimi",
  "starg09",
  "uhcarrarix",
  "killerphantom",
  "naoko-",
  "lvdota"
]
module.exports = (robot) ->
  robot.respond /img (.*)/i, (msg) ->
    sender = msg.message.user.user_nick.toLowerCase()
    if sender in whitelist
      imageMe msg, msg.match[1], (url) ->
        msg.send "[img]#{url}[/img]"
    else
      msg.send "Nope :)"

  robot.respond /gif (.*)/i, (msg) ->
    sender = msg.message.user.user_nick.toLowerCase()
    if sender in whitelist
      imageMe msg, msg.match[1], true, (url) ->
        msg.send "[img]#{url}[/img]"
    else
      msg.send "Nope :)"

  robot.respond /mostacho (.*)/i, (msg) ->
    sender = msg.message.user.user_nick.toLowerCase()
    if sender in whitelist
      mustachify = "https://kari-mustacho.herokuapp.com/rand?src="
      imagery = msg.match[1]
      imageMe msg, imagery, false, true, (url) ->
        encodedUrl = encodeURIComponent url
        msg.send "[img]#{mustachify}#{encodedUrl}[/img]"
    else
      msg.send "Nope :)"

imageMe = (msg, query, animated, faces, cb) ->
  noPorn query, (valid) ->
    if valid      
      cb = animated if typeof animated == 'function'
      cb = faces if typeof faces == 'function'
      q = v: '1.0', rsz: '8', q: query, safe: 'active'
      q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
      q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
      msg.http('http://ajax.googleapis.com/ajax/services/search/images')
        .query(q)
        .get() (err, res, body) ->
          images = JSON.parse(body)
          images = images.responseData?.results
          if images?.length > 0
            image = msg.random images
            cb ensureImageExtension image.unescapedUrl
    else
      msg.send "Buen intento picarón ;)"

ensureImageExtension = (url) ->
  ext = url.split('.').pop()
  if /(png|jpe?g|gif)/i.test(ext)
    url
  else
    "#{url}#.png"

noPorn = (text, cb) ->
  txtLower = S(text.toLowerCase())
  words = [
    'suicide'
    'porn'
    'poring'
    'sex'
    'nipple'
    'pezón'
    'pezon'
    'lawita'
    'arwen'
    'rosemo'
    'coolicio'
    'nadeshda'
    'penis'
    'pene'
    'tattooed girl'
    'tattoo girl'
    'suicid'
    'gore'
    'gor3'
    'g0r3'
    'g0re'
    'rule34'
    'yiff'
    'hentai'
    'tetas'
    'teta '
    'nudist'
    'nudism'
    'autopsy'
    'autopsia'
    'bodypainting'
  ]
  valid = true
  for word in words
    if txtLower.contains(word)
      valid = false
      break
  return cb valid