# frozen_string_literal: true

# Survey model for mental health survey responses
# This model implements HIPAA-compliant encryption for sensitive health data
class Survey < ApplicationRecord
  # Associations
  belongs_to :patient, optional: true
  belongs_to :survey_workflow, optional: true
  has_many :responses, dependent: :destroy
  has_many :notes, class_name: 'SurveyNote', dependent: :destroy

  # Callbacks
  after_create :log_survey_creation
  after_update :log_survey_update, if: :flagged_changed?

  # Encrypt sensitive health data
  encrypts :symptoms
  blind_index :symptoms

  # Validations
  validates :feeling, presence: true, inclusion: { in: 1..5 }
  validates :stress_level, presence: true, inclusion: { in: 1..5 }
  validates :sleep_hours, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 24 }
  validates :symptoms, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :flagged, -> { where(flagged: true) }
  scope :by_workflow, ->(workflow_id) { where(survey_workflow_id: workflow_id) }
  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Methods
  def self.average_feeling
    average(:feeling).to_f.round(1)
  end

  def self.average_stress_level
    average(:stress_level).to_f.round(1)
  end

  def self.average_sleep_hours
    average(:sleep_hours).to_f.round(1)
  end

  def self.analytics
    {
      count: count,
      average_feeling: average_feeling,
      average_stress_level: average_stress_level,
      average_sleep_hours: average_sleep_hours
    }
  end

  private

  # Log survey creation for HIPAA compliance audit trail
  def log_survey_creation
    AuditLog.create(
      action: 'survey.create',
      auditable: self,
      ip_address: '0.0.0.0', # This would be set by the controller in real usage
      details: {
        patient_id: patient_id,
        survey_workflow_id: survey_workflow_id
      }
    )
  end

  # Log survey updates for HIPAA compliance audit trail
  def log_survey_update
    AuditLog.create(
      action: 'survey.update',
      auditable: self,
      ip_address: '0.0.0.0', # This would be set by the controller in real usage
      details: {
        patient_id: patient_id,
        survey_workflow_id: survey_workflow_id,
        flagged: flagged,
        flagged_reason: flagged_reason
      }
    )
  end
end
