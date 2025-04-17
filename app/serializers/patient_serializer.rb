# frozen_string_literal: true

# Serializer for Patient model
class PatientSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :phone_number, :gender, :status, :created_at, :updated_at
  
  # Include encrypted fields
  attribute :first_name
  attribute :last_name
  attribute :date_of_birth
  attribute :medical_record_number
  
  # Computed attributes
  attribute :full_name do |patient|
    patient.full_name
  end
  
  attribute :age do |patient|
    patient.age
  end
  
  # Relationships
  has_many :surveys
  
  # Metadata for HIPAA compliance
  attribute :hipaa_compliant do
    true
  end
  
  attribute :last_accessed_at do |_patient, params|
    params[:last_accessed_at] || Time.current
  end
end
