# Description:
#   Wolfram
#
# Commands:
# = - Para resolver cosas matemáticas, ej: = 4 + 4343249

wolfram = require('wolfram').createClient "8UXPJ5-3VE2YTT4TL"
module.exports = (robot) ->
  robot.hear /^=(.*)$/i, (msg) ->
    wolfram.query msg.match[1], (err, rs) ->
      if err
        msg.send "WA Error: #{err}"
        return
      if rs? and rs.length == 2
        res = ''
        for response in rs
          for pod in response.subpods
            if pod.image? and pod.image isnt '' and pod.value? and pod.value isnt ''
              res = res + "[img]" + pod.image + "[/img]" + '\n'
            if pod.value and pod.value != ''
              res = res + '\n' + pod.value
        
        msg.send res
        return

      if not rs? or rs.length <= 1
        msg.send 'No hay resultados'
        return

      res = ''
      for response in rs
        if response.primary
          for pod in response.subpods
            if pod.image? and pod.image isnt ''
              res = res + "[img]" + pod.image + "[/img]" + '\n'
            if pod.value and pod.value != ''
              res = res + '\n' + pod.value
          break
      msg.send res
      return