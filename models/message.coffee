mongoose = require('mongoose')

messageSchema = new mongoose.Schema(
  subject: String
  sender: String
  message_id:
    type: Number
    required: true
    unique: true
  body: String
  timestamp: Number
)

Message = mongoose.model 'Messages', messageSchema

module.exports = Message