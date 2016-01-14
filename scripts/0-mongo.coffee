# Description:
#   Conexión a mongo

mongoose = require 'mongoose'

module.exports = (robot) ->
  mongoose.connect process.env.MONGOLAB_URI, (err, res) ->
    if err
      console.log 'ERROR connecting to db'
    else
      console.log 'Succeeded connected to db'
