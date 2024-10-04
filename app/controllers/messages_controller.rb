class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property

  def create
    @message = @property.messages.new(message_params)
    @message.sender = current_user

    if @message.save
      # could also add a notification system here
      render json: { content: @message.content, sender_id: @message.sender.id }, status: :created
    else
      Rails.logger.error(@message.errors.full_messages.join("\n"))
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  def index
    # Fetch messages for the specific property
    @messages = Message.where(property: @property).order(created_at: :asc).last(50)
    render json: @messages
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  end

  def message_params
    params.require(:message).permit(:receiver_id, :content)
  end
end
