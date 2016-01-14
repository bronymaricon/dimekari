# Description:
#   Genera el comando Ayuda de kari
#
# Commands:
#   hubot [b]ayuda|help[/b] - Muestra la ayuda de todos los comandos
#
module.exports = (robot) ->
  robot.respond /(?:help|ayuda)\s*(.*)?$/i, (msg) ->
    cmds = robot.helpCommands()
    filter = msg.match[1]

    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(filter, 'i')
      if cmds.length == 0
        msg.send "No hay comandos que concuerden"
        return

      text = "[b]Comandos disponibles:[/b]\n\n"
      prefix = ""
      for cmd in cmds
        comando = cmd.replace /hubot/ig,  ""
        comando = comando.replace new RegExp("^"), prefix
        comando = comando.replace /\|/ig, " o "
        if not filter
          comando = comando.split("-")[0]

        if comando.length > 2
          text = "#{text}\n#{comando}"

      #text = "#{text}\n\nEscriba \"kari help {comando}\" para obtener ayuda sobre un comando en específico"

      msg.send text
    else
      msg.send "[img]http://i.imgur.com/DDnI0U4.png[/img]"