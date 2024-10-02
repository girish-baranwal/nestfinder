class Agreement < ApplicationRecord
  has_many_attached :tenant_identifications
  has_many_attached :owner_documents
  belongs_to :property
  belongs_to :owner, class_name: 'User'

  validates :start_date, :end_date, :property_id, presence: true
  validate :validate_dates

  # Scope to retrieve agreements from the last 3 years
  scope :recent_three_years, -> { where('start_date >= ?', 3.years.ago) }

  private

  def validate_dates
    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
