# Description:
#   Cosas relacionadas con taringa
#
# Commands:
#   hubot [b]follow|sigue a[/b] {nick} - Sigue a @'nick'
#   hubot [b]escreador[/b] {usuario} - Verifica si <usuario> es creador en taringa
#   hubot [b]estabaneado[/b] {usuario} - Verifica si <usuario> está baneado en taringa
findGif = (robot,list,i) ->
  if i > 10
    return console.log "No se encontró ningun gif correcto"
  gif = list[ Math.floor(Math.random() * list.length) ]
  url = gif.data.url
  url = url.replace /\.gifv/g, "\.gif"
  if gif.data.thumbnail is "nsfw"
    return findGif robot, list, i = i+1
  robot.adapter.taringa.kn3.import url,(err,data) ->
    if err
      console.log "#{err}"
      return findGif robot, list, i = i+1
    return robot.adapter.taringa.shout.add "#KariGif",1,0,data


checkUser = (usuario, t_obj,callback) ->
  t_obj.request.get 'http://api.taringa.net/user/nick/view/' + usuario.toLowerCase().trim(), (error, response, body) ->
    msg = ''
    if !error
      try
        data = JSON.parse(body)
        if "#{data.status}" is '5'
          msg = usuario + ' fue baneado por gil'
        else
          if data.profile_active != true
            msg = usuario + ' no está baneado, solo desactivó su cuenta'
          else
            msg = usuario + ' no está baneado'
      catch e
        msg = 'Ocurrió un error al hacer la petición, cuentale a OverJT 😋'
    else
      msg = 'El usuario ' + usuario + ' no existe'
    callback(msg)
    return
  return

checkUserCreador = (usuario, t_obj,callback) ->
  t_obj.request.get 'http://api.taringa.net/user/nick/view/' + usuario.toLowerCase().trim(), (error, response, body) ->
    msg = ''
    if !error
      try
        data = JSON.parse(body)
        if data.rewards_active is true
          msg = 'El usuario ' + usuario + ' pertenece al programa Taringa Creadores'
        else
          msg = usuario + ' no hace parte de Taringa Creadores'
      catch e
        msg = 'Ocurrió un error al hacer la petición, cuentale a OverJT 😋'
    else
      msg = 'El usuario ' + usuario + ' no existe'
    callback(msg)
    return
  return

whitelist = [
  "overjt",
  "anpep",
  "pozimi",
  "starg09",
  "ehcarrarix",
  "killerphantom"
]

module.exports = (robot) ->
  robot.respond /shoutea(?: (.*))?$/i, (msg) ->
    sender = msg.message.user.user_nick.toLowerCase()
    if sender in whitelist
      if msg.match[1]?
        robot.adapter.taringa.shout.add msg.match[1]
        return msg.send "Listo :)"
      robot.http("http://www.reddit.com/r/gifs/top/.json?sort=top&t=day")
        .get() (err, res, body) ->
          try
            data = JSON.parse body
            list = data.data.children
            msg.send "Ok :)"
            findGif(robot, list, 0)
          catch ex
            console.log "Erm, something went EXTREMELY wrong - #{ex}"
    else
      msg.send "Lo siento, no estás en la lista blanca"

  robot.respond /(?:follow|sigue a) (?:@|)([a-z0-9_\-]{2,})/i, (msg) ->
    user = msg.match[1]
    msg.finish()
    follower_id = robot.adapter.taringa.user.get_user_id_from_nick user, (error, response) ->
      if error
        return console.log error
      robot.adapter.taringa.user.follow response

  setInterval () ->
    robot.http("http://www.reddit.com/r/gifs/top/.json?sort=top&t=day")
      .get() (err, res, body) ->
        try
          data = JSON.parse body
          list = data.data.children
          findGif(robot, list, 0)
        catch ex
          console.log "Erm, something went EXTREMELY wrong - #{ex}"
  , 18000000

  robot.respond /estabaneado @?([a-z0-9\-\_]{1,16})/i, (msg) ->
    checkUser msg.match[1],robot.adapter.taringa, (text) ->
      msg.send text

  robot.respond /escreador @?([a-z0-9\-\_]{1,16})/i, (msg) ->
    checkUserCreador msg.match[1], robot.adapter.taringa,(text) ->
      msg.send text