# class ChatChannel < ApplicationCable::Channel
#   def subscribed
#     if current_user.nil?
#       reject_unauthorized_connection
#     else
#       @property = Property.find(params[:chat_room])
#       # stream_from "some_channel"
#       stream_from "chat_#{@property.id}"
#
#       # Send any cached messages from Redis to the user
#       cached_messages = Redis.current.lrange("chat_#{params[:chat_room]}", 0, -1)
#       cached_messages.each do |msg|
#         transmit(JSON.parse(msg))
#       end
#     end
#   end
#
#   def unsubscribed
#     # Any cleanup needed when channel is unsubscribed
#   end
#
#   def receive(data)
#     # Broadcast message to the specific chat room
#     ActionCable.server.broadcast("chat_#{params[:chat_room]}", data)
#
#     # Store chat in Redis (for offline users)
#     Redis.current.lpush("chat_#{params[:chat_room]}", data.to_json)
#
#   end
# end
