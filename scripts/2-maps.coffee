# Description:
#   Interactua con google maps
#
# Commands:
#   hubot [b]mapa de[/b] {lugar} - Retorna el mapa de `lugar`.
#   hubot [b]mapa satelite de[/b] {lugar} - Retorna el mapa satelital de 'lugar', 'satelite' puede ser reemplazado por terreno o hibrido

module.exports = (robot) ->
  robot.respond /mapa (?:(satelite |terreno |hibrido ))?de (.+)/i, (msg) ->
    if msg.match[1]?
      switch msg.match[1].trim().toLowerCase()
        when "satelite" then mapType = "satellite"
        when "terreno" then mapType = "terrain"
        when "hibrido" then mapType = "hybrid"
        else mapType = "roadmap"
    else
      mapType = "roadmap"
    location = encodeURIComponent(msg.match[2])
    mapUrl   = "http://maps.google.com/maps/api/staticmap?markers=" +
                location +
                "&size=400x400&maptype=" +
                mapType +
                "&sensor=false" +
                "&format=png"
    url      = "http://maps.google.com/maps?q=" +
               location +
              "&hl=en&sll=37.0625,-95.677068&sspn=73.579623,100.371094&vpsrc=0&hnear=" +
              location +
              "&t=m&z=11"

    msg.send "[img]#{mapUrl}[/img]\n#{url}"