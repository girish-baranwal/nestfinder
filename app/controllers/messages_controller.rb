class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @message = current_user.sent_messages.build(message_params)
    if @message.save
      # could also add a notification system here
      render json: @message, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def index
    @messages = Message.where(receiver: current_user)
    render json: @messages
  end

  private

  def message_params
    params.require(:message).permit(:receiver_id, :content)
  end
end
