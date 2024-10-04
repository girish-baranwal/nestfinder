class Property < ApplicationRecord

  searchkick

  # before_action :authenticate_user!, except: [:index, :show]

  validates :title, presence: true
  validates :price, presence: true
  validates :description, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true


  # If you want to customize the fields to be indexed, you can do it here
  def search_data
    # Rails.logger.info "Title: #{title}, City: #{city}, Postal Code: #{postal_code}, Address: #{address_line_1}"
    {
      title: title,
      description: description,
      price: price,
      status: status,
      address_line_1: address_line_1,
      address_line_2: address_line_2,
      city: city,
      postal_code: postal_code
    }
  end

  belongs_to :user
  has_many_attached :images
  has_many :comments, dependent: :destroy
  has_many :agreements
  has_many :messages
end
