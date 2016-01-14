# Description:
#   Los scripts de code
#
# Commands:
#   hubot [b]xkcd[/b] - Retorna algo aleatorio de xkcd.com
#   hubot [b]bit[/b] {monto} - Convierte bits en dólares
#   hubot [b]caracola[/b] {pregunta} - La caracola mágica
#   hubot [b]troesma[/b] - ?

getXKCD = (msg, id, alt) ->
  msg.http('http://xkcd.com/' + id + '/info.0.json')      
    .get() (err, res, body) ->
      if !err
        table = JSON.parse(body)
        text = "#{table.safe_title}\n[img]#{table.img}[/img]"
        if alt == '-alt'
          text = text + "\n#{table.alt}"
        msg.send text
      else
        msg.send 'Error al revisar la validez del link. Por favor, intenta mas tarde.'


module.exports = (robot) ->

  robot.respond /xkcd(?: ([a-z0-9]+)?( \-alt)?)?$/i, (msg) ->
    msg.http('http://xkcd.com/info.0.json')      
      .get() (err, res, body) ->
        if !err
          maxid = body.match(/\"num\": (\d+?),/)[1]
          if msg.match[1]?
            param1 = msg.match[1]
            if param1.toLowerCase() is "count"
              msg.send 'Numero de comics disponible: ' + maxid
            else if param1.toLowerCase() is "random"
              id = Math.floor(Math.random() * maxid + 1)
              if msg.match[2]?
                getXKCD msg, id, msg.match[2]
              else
                getXKCD msg, id, ''
            else
              if msg.match[2]?
                getXKCD msg, param1, msg.match[2]
              else
                getXKCD msg, param1, ''
          else
            id = Math.floor(Math.random() * maxid + 1)
            getXKCD msg, id, ''
        else
          msg.send 'Error al contactar a xkcd. Por favor, intenta mas tarde.'

  robot.respond /bit(?: (\d*))?/i, (msg) ->
    msg.http('https://api.bitcoinaverage.com/ticker/global/USD/last')      
      .get() (err, res, body) ->
        if !err
          valoractual = body
          if msg.match[1]? and msg.match[1].trim() isnt ""
            multiplo = msg.match[1].trim() * valoractual * 0.000001
            if multiplo < 0.01
              text = msg.match[1].trim() + ' bits = ' + multiplo.toFixed(4) + ' USD'
            else if multiplo >= 0.01
              text = msg.match[1].trim() + ' bits = ' + multiplo.toFixed(2) + ' USD'
          else
            text = "Cotización actual del Bitcoin: 1 BTC = 1.000.000 bits = #{valoractual} USD"
          msg.send text
        else
          msg.send 'Ocurrió un error :/'

  robot.respond /caracola (.*)$/i, (msg) ->
    r = [
      'Sí.'
      'No.'
      'Probablemente.'
    ]
    if msg.match[1].indexOf('que hago') > -1 or msg.match[1].indexOf('que hacemos') > -1
      text = 'Nada.'
    else
      text = r[Math.floor(Math.random() * 2)]
    msg.send text

  robot.respond /troesma$/i, (msg) ->
    As = [
      'Gran post'
      'Buen reco'
      'Te zarpaste'
      'Alto bardo empezaste'
      'Gran aporte'
      'Despedite de tu cuenta,'
      '+10, reco y denunciado,'
    ]
    C1s = [
      'cósmico'
      'místico'
      'negro'
      'estratosférico'
      'vegano'
    ]
    C2s = [
      'cósmica'
      'mística'
      'negra'
      'estratosférica'
      'vegana'
    ]
    Bs = [
      'lince ' + C1s[Math.floor(Math.random() * C1s.length)]
      'maquinola ' + C2s[Math.floor(Math.random() * C1s.length)]
      'fiera ' + C2s[Math.floor(Math.random() * C1s.length)]
      'orangután ' + C1s[Math.floor(Math.random() * C1s.length)]
      'canibal ' + C1s[Math.floor(Math.random() * C1s.length)]
      'troesma ' + C1s[Math.floor(Math.random() * C1s.length)]
    ]
    Ds = [
      'de las praderas'
      'cual merodeador de calles oscuras'
      'que vigila la noche'
      'de las llanuras'
      'temor de los paranóicos'
    ]
    msg.send As[Math.floor(Math.random() * As.length)] + ' ' + Bs[Math.floor(Math.random() * Bs.length)] + ' ' + Ds[Math.floor(Math.random() * Ds.length)] + '.'
