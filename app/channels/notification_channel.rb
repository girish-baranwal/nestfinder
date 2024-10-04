class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to a stream for each tenant's user ID
    user = User.find(params[:user_id])
    stream_for user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
