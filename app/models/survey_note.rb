# frozen_string_literal: true

# Survey note model for tracking clinical notes on surveys
# Implements HIPAA-compliant encryption for sensitive health data
class SurveyNote < ApplicationRecord
  # Associations
  belongs_to :survey
  belongs_to :admin

  # Encrypt sensitive health data
  encrypts :content

  # Validations
  validates :content, presence: true

  # Callbacks
  after_create :log_note_creation

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def admin_name
    admin.present? ? "#{admin.first_name} #{admin.last_name}".strip : "Unknown Admin"
  end

  private

  # Log note creation for HIPAA compliance audit trail
  def log_note_creation
    AuditLog.create(
      action: 'survey_note.create',
      auditable: self,
      admin: admin,
      ip_address: '0.0.0.0', # This would be set by the controller in real usage
      details: {
        survey_id: survey_id,
        patient_id: survey.patient_id
      }
    )
  end
end
