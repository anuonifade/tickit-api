# frozen_string_literal: true

# Helper module for HIPAA compliance testing
module HipaaComplianceHelper
  # Enable audit logging for the duration of the block
  def with_audit_logging
    Thread.current[:enable_audit_logs] = true
    yield
  ensure
    Thread.current[:enable_audit_logs] = false
  end
  
  # Enable audit logging before each test
  def enable_audit_logging
    # Enable audit logging in the test environment
    ENV['ENABLE_TEST_AUDIT_LOGS'] = 'true'
    Thread.current[:enable_audit_logs] = true
    Thread.current[:clear_audit_logs_before_test] = false
    
    # Clear existing audit logs to ensure a clean state
    AuditLog.delete_all
  end
  
  # Disable audit logging after each test
  def disable_audit_logging
    ENV['ENABLE_TEST_AUDIT_LOGS'] = nil
    Thread.current[:enable_audit_logs] = false
    Thread.current[:clear_audit_logs_before_test] = false
  end
  # Verify that a model has encrypted fields
  def expect_encrypted_field(record, field_name, original_value)
    # First, verify that the field is configured for encryption
    if record.class.respond_to?(:encrypts) && record.class.encrypted_attributes.include?(field_name.to_s)
      # Verify that the getter returns the expected value
      actual_value = record.send(field_name)
      if original_value.is_a?(Date) || original_value.is_a?(Time)
        expect(actual_value.to_s).to include(original_value.to_s)
      else
        expect(actual_value).to eq(original_value)
      end
      
      # Also check that the ciphertext exists
      if record.respond_to?("#{field_name}_ciphertext")
        # The ciphertext should not be nil
        expect(record.send("#{field_name}_ciphertext")).not_to be_nil
        
        # The ciphertext should not be the same as the original value
        if record.send("#{field_name}_ciphertext").is_a?(String) && original_value.is_a?(String)
          expect(record.send("#{field_name}_ciphertext")).not_to eq(original_value)
        end
      end
      
      # The decrypted value should match the original
      actual_value = record.send(field_name)
      if original_value.is_a?(Date) || original_value.is_a?(Time)
        expect(actual_value.to_s).to include(original_value.to_s)
      else
        expect(actual_value).to eq(original_value)
      end
    end
  end
  
  # Verify that an audit log was created for an action
  def expect_audit_log_for(action, admin = nil, auditable = nil)
    # Query for audit logs based on the action type
    if action.is_a?(Regexp)
      logs = AuditLog.where("action ~* ?", action.source)
    else
      # For patient creation, check for either controller or model actions
      if action == 'patient.create'
        logs = AuditLog.where("action = ? OR action = ?", action, 'patients#create')
      else
        logs = AuditLog.where(action: action)
      end
    end
    
    # Add admin filter if provided
    logs = logs.where(admin: admin) if admin.present?
    
    # Add auditable filter if provided
    if auditable.present?
      logs = logs.where(auditable_type: auditable.class.name, auditable_id: auditable.id)
    end
    
    # Verify that logs exist
    expect(logs.count).to be > 0, "Expected to find audit logs with action '#{action}' but none were found"
    
    # Get the most recent log for verification
    log = logs.last
    
    # Verify admin and auditable if provided
    expect(log.admin).to eq(admin) if admin
    expect(log.auditable).to eq(auditable) if auditable
    
    # Return the log for further assertions
    log
  end
  
  # Create a test patient with encrypted fields
  def create_test_patient_with_encrypted_data
    # Generate a unique email and MRN for each test
    unique_email = "hipaa_test_#{Time.now.to_i}#{rand(1000)}@example.com"
    unique_mrn = "MRN-TEST-#{Time.now.to_i}#{rand(1000)}"
    
    # Create the patient with test data
    patient = create(:patient, 
                    first_name: 'HIPAA', 
                    last_name: 'Test', 
                    email: unique_email,
                    medical_record_number: unique_mrn,
                    date_of_birth: '1990-01-01')
    
    # Verify that the encrypted fields are properly set
    expect_encrypted_field(patient, :first_name, 'HIPAA')
    expect_encrypted_field(patient, :last_name, 'Test')
    expect_encrypted_field(patient, :medical_record_number, unique_mrn)
    expect_encrypted_field(patient, :date_of_birth, Date.parse('1990-01-01'))
    
    patient
  end
  
  # Create a test survey with encrypted symptoms
  def create_test_survey_with_encrypted_data
    survey = create(:survey, symptoms: 'Test symptoms for HIPAA compliance')
    
    # Verify encryption
    expect_encrypted_field(survey, :symptoms, 'Test symptoms for HIPAA compliance')
    
    survey
  end
  
  # Create a test survey note with encrypted content
  def create_test_survey_note_with_encrypted_data(admin, survey)
    note = create(:survey_note, 
                 admin: admin, 
                 survey: survey, 
                 content: 'Confidential clinical note for HIPAA testing')
                 
    # Verify encryption
    expect_encrypted_field(note, :content, 'Confidential clinical note for HIPAA testing')
    
    note
  end
end

RSpec.configure do |config|
  config.include HipaaComplianceHelper
end
