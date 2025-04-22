# frozen_string_literal: true

# Patient model with encrypted fields for HIPAA compliance
class Patient < ApplicationRecord
  # Associations
  has_many :surveys, dependent: :destroy

  # Encrypted fields using Lockbox for HIPAA compliance
  encrypts :first_name, :last_name, :date_of_birth, :medical_record_number
  blind_index :medical_record_number

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :medical_record_number, presence: true, uniqueness: true

  # Callbacks
  after_create :log_patient_creation

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def age
    return nil unless date_of_birth

    now = Time.current
    dob = date_of_birth.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  private

  def log_patient_creation
    # Create audit log for patient creation (HIPAA compliance)
    AuditLog.create(
      action: 'patient.create',
      auditable: self,
      ip_address: '0.0.0.0', # This would be set by the controller in real usage
      details: { email: email }
    )
  end
end
