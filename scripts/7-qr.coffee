# Description:
#   qr
#
# Commands:
#   hubot [b]qr[/b] {texto} - Comando desactivado.

#qr = require('qr-image')
#fs = require('fs')
module.exports = (robot) ->

  robot.respond /qr(?: (.*)?)?$/i, (msg) ->
    return msg.send "Comando desactivado por posible ban."
    ###
    if msg.match[1]?
      qr_svg = qr.image(msg.match[1])
      file = fs.createWriteStream('d01ab2d9b1b6901c30911023cbda0bc72.png')
      qr_svg.pipe file
      file.on 'finish', ->
        robot.adapter.taringa.kn3.upload 'd01ab2d9b1b6901c30911023cbda0bc72.png',(err,data) ->
          if err
            return msg.send "#{err}"
          msg.send "[img]#{data}[/img]"
    else
      msg.send "Debes ingresar un texto :)"
    ###