# Description:
#   None
#
# Commands:
#   hubot [b]define[/b] {texto} - Busca la definición de {texto}
#

_          = require("underscore")
_s         = require("underscore.string")
Select     = require("soupselect").select
HTMLParser = require "htmlparser"

module.exports = (robot) ->
  robot.respond /define (.*)$/i, (msg) ->
    define msg, "", msg.match[1]

wikiMe = (msg, query, cb) ->
  articleURL = makeArticleURL(makeTitleFromQuery(query))

  msg.http(articleURL)
    .header('User-Agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.132 Safari/537.36')
    .get() (err, res, body) ->
      return cb "Las tuberías está rotas :P" if err

      if res.statusCode is 301
        return cb res.headers.location

      if /Wikipedia aún no tiene una página llamada/.test body
        return cb "Wikipedia no tiene ni puta idea"

      paragraphs = parseHTML(body, "p")

      bodyText = findBestParagraph(paragraphs) or "Miralo tu mismo:"
      cb bodyText, articleURL

# Utility Methods

childrenOfType = (root, nodeType) ->
  return [root] if root?.type is nodeType

  if root?.children?.length > 0
    return (childrenOfType(child, nodeType) for child in root.children)

  []

findBestParagraph = (paragraphs) ->
  return null if paragraphs.length is 0

  childs = _.flatten childrenOfType(paragraphs[0], 'text')
  text = (textNode.data for textNode in childs).join ''

  # remove parentheticals (even nested ones)
  text = text.replace(/\s*\([^()]*?\)/g, '').replace(/\s*\([^()]*?\)/g, '')
  text = text.replace(/\s{2,}/g, ' ')               # squash whitespace
  text = text.replace(/\[[\d\s]+\]/g, '')           # remove citations
  text = _s.unescapeHTML(text)                      # get rid of nasties

  # if non-letters are the majority in the paragraph, skip it
  if text.replace(/[^a-zA-Z]/g, '').length < 35
    findBestParagraph(paragraphs.slice(1))
  else
    text

makeArticleURL = (title) ->
  "https://es.wikipedia.org/wiki/#{encodeURIComponent(title)}"

makeTitleFromQuery = (query) ->
  strCapitalize(_s.trim(query).replace(/[ ]/g, '_'))

parseHTML = (html, selector) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser  = new HTMLParser.Parser handler
  parser.parseComplete html

  Select handler.dom, selector

strCapitalize = (str) ->
  return str.charAt(0).toUpperCase() + str.substring(1);

processResponse = (msg, temp, data) ->
  text = data.word + '\n'
  for i of data.meanings
    text = text + ' - ' + data.meanings[i].meaning + ' ' + data.meanings[i].meta + '\n'
  msg.send "#{temp}#{text}"
  return

define = (msg, temp, word) ->
  msg.http('http://dulcinea.herokuapp.com/api/?query=' + encodeURI(word))      
    .get() (err, res, body) ->
      if !err
        data = JSON.parse(body)
        if data.status == 'success'
          if data.type == 'multiple'
            wikiMe msg, word, (text, url) ->
              if url == null or typeof url == 'undefined'
                temp = 'Quizás quiso decir: ' + data.response[0].word + "\n"
                return define(msg, temp, data.response[0].id)
              if url?
                text = "#{temp}#{text}\n#{url}"
              msg.send text
          else
            return processResponse(msg, temp, data.response[0])
        else
          wikiMe msg, word, (text, url) ->
            if url == null or typeof url == 'undefined'
              return msg.send('No se encontraron resultados')
            if url?
              text = "#{temp}#{text}\n#{url}"
            msg.send text
      else
        wikiMe msg, word, (text, url) ->
          if url == null or typeof url == 'undefined'
            return msg.send('No se encontraron resultados para')
          if url?
            text = "#{temp}#{text}\n#{url}"
          msg.send text
      return
    return
