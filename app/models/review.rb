class Review < ApplicationRecord
  belongs_to :user
  belongs_to :property

  validates :comments, presence: true
end
