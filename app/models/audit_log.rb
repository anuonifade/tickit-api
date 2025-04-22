# frozen_string_literal: true

# AuditLog model for tracking access to sensitive data (HIPAA compliance)
class AuditLog < ApplicationRecord
  # Associations
  belongs_to :admin, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true
  validates :ip_address, presence: true

  # Scopes
  scope :by_admin, ->(admin_id) { where(admin_id: admin_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Instance methods
  def admin_email
    admin&.email || 'System'
  end

  def admin_name
    admin&.full_name || 'System'
  end

  # Class methods
  def self.log(admin, action, auditable = nil, ip_address = nil, details = {})
    create(
      admin: admin,
      action: action,
      auditable: auditable,
      ip_address: ip_address || '0.0.0.0',
      details: details
    )
  end
end
