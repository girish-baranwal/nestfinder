class Agreement < ApplicationRecord
  has_many_attached :tenant_identifications
  has_many_attached :owner_documents
  belongs_to :property
  belongs_to :owner, class_name: 'User'

  before_create :set_default_status
  enum status: { draft: 'draft', awaiting_signature: 'awaiting_signature', completed: 'completed' }

  validates :start_date, :end_date, :property_id, presence: true, unless: :draft?
  validate :validate_dates
  # validates :signature, presence: true, if: -> { status == 'awaiting_signature' }

  # Scope to retrieve agreements from the last 3 years
  scope :recent_three_years, -> { where('start_date >= ?', 3.years.ago) }

  def send_to_tenant
    self.status = :awaiting_signature
    save
    # Trigger email or notification to tenant here
    NotificationMailer.notify_tenant(self).deliver_later if tenant_email.present?
  end

  def complete_agreement
    self.status = :completed
    save
  end

  def owner_signed?
    owner_signature.present?
  end

  def tenant_signed?
    tenant_signature.present?
  end

  private

  def validate_dates
    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def set_default_status
    self.status ||= 'draft'
  end

end
