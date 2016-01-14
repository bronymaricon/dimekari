# Description:
#   Cosas relacionadas con taringa
#
# Commands:
#   hubot [b]ping[/b] - responde pong
#   hubot [b]uptime[/b] - responde el tiempo que lleva encendida


module.exports = (robot) ->
  start = Date.now()
  robot.respond /ping$/i, (msg) ->
    msg.send "pong"

  robot.respond /uptime$/i, (msg) ->
    end = Date.now()
    tmp = new Date(start).toString()
    seconds = Math.floor((end - start) / 1000)
    minutes = Math.floor(seconds / 60)
    hours = Math.floor(minutes / 60)
    days = Math.floor(hours / 24)
    msg_time = 'Llevo encendida sin reiniciarme:\n'
    hours = hours - (days * 24)
    minutes = minutes - (days * 24 * 60) - (hours * 60)
    seconds = seconds - (days * 24 * 60 * 60) - (hours * 60 * 60) - (minutes * 60)
    if days > 0
      if days > 1
        msg_time = msg_time + days + ' días\n'
      else
        msg_time = msg_time + days + ' día\n'
    if hours > 0
      if hours > 1
        msg_time = msg_time + hours + ' horas\n'
      else
        msg_time = msg_time + hours + ' hora\n'
    if minutes > 0
      if minutes > 1
        msg_time = msg_time + minutes + ' minutos\n'
      else
        msg_time = msg_time + minutes + ' minuto\n'
    if seconds > 1
      msg_time = msg_time + seconds + ' segundos\n'
    else
      msg_time = msg_time + seconds + ' segundo\n'
    msg_time = msg_time + 'Desde: ' + tmp
    msg.send msg_time

  robot.hear /^hola((?: kari)?)$/i, (msg) ->
    user = msg.message.user.user_nick
    msg.send "Hola #{user}"