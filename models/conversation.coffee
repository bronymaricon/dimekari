mongoose = require('mongoose')

conversationSchema = new mongoose.Schema(
  body: String
  response: String
)

Conversation = mongoose.model 'Conversations', conversationSchema

module.exports = Conversation