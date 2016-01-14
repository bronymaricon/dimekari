# Description:
#   La web dimekari.cf

mongoose = require 'mongoose'
Message  = require '../models/message'
express = require '../node_modules/hubot/node_modules/express'
path = require 'path'
make_pattern = require '../lib/utils'

module.exports = (robot) ->
  process.env.PWD = process.cwd()
  robot.router.use express.static path.join process.env.PWD, 'public'
  robot.router.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Headers', 'X-Requested-With'
    next()
  robot.router.set 'views', path.join process.env.PWD, 'views'
  robot.router.set 'json spaces', 0
  robot.router.set 'view engine', 'jade'
  robot.router.locals.pretty = true;

  robot.router.get '/', (req, res) ->
    res.render('index', { title: "Hola soy kari – DimeKari" });

  robot.router.get '/mensajes', (req, res) ->
    res.render('mp', { title: "Mensajes privados – DimeKari" });

  robot.router.get '/mp', (req, res) ->
    data = req.query
    if data.id?
      mpid   = parseInt(data.id)
    else
      return res.json
                error: true
                body: 'Message not found'

    if isNaN(mpid)
      return res.json
                error: true
                body: 'Message not found'

    Message.findOne { message_id: mpid }, (err, msg_obj) ->
      if err
        return res.json
                  error: true
                  body: 'Internal Error'

      if msg_obj is null
        return res.json
                  error: true
                  body: 'Message not found'

      res.json
        id: msg_obj.message_id
        body: msg_obj.body
        date: msg_obj.timestamp
        subject: msg_obj.subject
        sender: msg_obj.sender
  
  robot.router.get '/mp/last', (req, res) ->
    data = req.query
    if data.id?
      mpid   = parseInt(data.id)
    else
      return res.json
                error: true
                body: 'Message not found'

    Message
      .find('message_id': $gt: mpid)
      .limit(10)
      .sort({message_id: 'desc'})
      .exec (err,messages_obj) ->
        if err
          return res.json
                    error: true
                    body: 'Internal Error'
        messages = []
        for i of messages_obj
          temp=
            id: messages_obj[i].message_id
            body: messages_obj[i].body
            date: messages_obj[i].timestamp
            subject: messages_obj[i].subject
            sender: messages_obj[i].sender
          messages.push temp
        return res.json messages

  robot.router.get '/mp/get', (req, res) ->
    data = req.query
    perPage = 10
    page = 0
    if data.page?
      tpage = parseInt(data.page)
      if isNaN(tpage)
        page = 0
      else
        page = tpage - 1

      if page < 0
        page = 0

    if data.q?
      q = data.q
      searchp = make_pattern(q)
      Message
        .find($or: [
          { 'subject': searchp }
          { 'sender': searchp }
          { 'body': searchp }
        ])
        .sort({message_id: 'desc'})
        .exec (err,messages_obj) ->
          if err
            return res.json
                      error: true
                      body: 'Internal Error'
          matches = messages_obj.length
          messagesp = []
          i = perPage * page
          if i >= matches
            return res.json
                    matches: matches
                    messages: []
          j=0
          while i < matches
            temp=
              id: messages_obj[i].message_id
              body: messages_obj[i].body
              date: messages_obj[i].timestamp
              subject: messages_obj[i].subject
              sender: messages_obj[i].sender
            messagesp.push temp
            i++;
            j++;
            if j == perPage
              break;
          console.log "j=#{j}"
          return res.json
                  matches: matches
                  messages: messagesp

    else
      Message
        .find()
        .limit(perPage)
        .skip(perPage * page)
        .sort({message_id: 'desc'})
        .exec (err,messages_obj) ->
          if err
            return res.json
                      error: true
                      body: 'Internal Error'
          messagesp = []
          for i of messages_obj
            temp=
              id: messages_obj[i].message_id
              body: messages_obj[i].body
              date: messages_obj[i].timestamp
              subject: messages_obj[i].subject
              sender: messages_obj[i].sender
            messagesp.push temp
          return res.json
                  messages: messagesp