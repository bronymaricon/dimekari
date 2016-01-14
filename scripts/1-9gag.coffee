# Description:
#   Hubot random 9gag image poster
#
# Commands:
#   hubot [b]9gag[/b] - Retorna algo aleatorio de 9gag
#

Select      = require( "soupselect" ).select
htmlparser  = require "htmlparser"

module.exports = (robot)->
  robot.respond /9gag$/i, (msg)->
    send_meme msg, false

send_meme = (msg, location)->
  meme_domain = "http://9gag.com"
  location  ||= "/random"
  if location.substr(0, 4) != "http"
    url = meme_domain + location
  else
    url = location

  msg.http(url)
    .get() (error, response, body)->
      return response_handler "Sorry, something went wrong" if error

      if response.statusCode == 302
        location = response.headers['location']
        return send_meme(msg, location)

      handler = new htmlparser.DefaultHandler((()->), ignoreWhitespace: true )
      parser = new htmlparser.Parser handler
      parser.parseComplete body

      img_title = Select(handler.dom, ".badge-item-title")[0].children[0].raw
      img_src = Select(handler.dom, ".badge-animated-container-animated")[0]
      nsfw = Select(handler.dom, ".nsfw-post")[0]
      if not nsfw
        if not img_src
          img_src = Select(handler.dom, ".badge-item-img")[0]
          img_src = img_src.attribs.src
        else
          img_src = img_src.attribs['data-image']

        text = "#{img_title}\n[img]#{img_src}[/img]"
        msg.send text
      else
        return send_meme(msg, false)