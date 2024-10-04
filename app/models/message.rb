class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  belongs_to :property

  validates :content, presence: true
  validates :property_id, presence: true
  validates :receiver_id, presence: true

  after_create_commit :broadcast_message

  # after_create_commit do
  #   # Optionally broadcast after persistence to ensure it's stored
  #   # mark_as_unread_if_offline
  #   broadcast_message
  # end

  private

  def broadcast_message
    ActionCable.server.broadcast("chat_#{property.id}", {
      message: content,
      sender_id: sender.id,
      timestamp: created_at.strftime('%H:%M')
    })
  end

  # def mark_as_unread_if_offline
  #   unless receiver.online?
  #     update(status: "unread")
  #     # Optionally trigger an offline notification job
  #     OfflineNotificationJob.perform_later(receiver, self)
  #   end
  # end


end
