# frozen_string_literal: true

# Helper module for test environment-specific functionality
module TestEnvironmentHelper
  # Set up the test environment with necessary environment variables
  def setup_test_environment
    # Set up encryption keys for tests
    ENV['LOCKBOX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['BLIND_INDEX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    
    # Set up database configuration for tests
    ENV['SKIP_DB_INDEXES'] = 'true'
    
    # Set up Devise configuration for tests
    ENV['DEVISE_STRETCHES'] = '1'
  end
  
  # Enable audit logging for tests
  def enable_audit_logging
    ENV['ENABLE_AUDIT_LOGS'] = 'true'
  end
  
  # Disable audit logging after tests
  def disable_audit_logging
    ENV['ENABLE_AUDIT_LOGS'] = nil
  end
  
  # Patch models to remove Rails.env.test? checks
  def patch_models_for_test_environment
    # Patch the Survey model
    patch_survey_model
    
    # Patch the Patient model
    patch_patient_model
    
    # Patch the SurveyNote model
    patch_survey_note_model
    
    # Patch the AuditLog model
    patch_audit_log_model
  end
  
  private
  
  # Patch the Survey model for tests
  def patch_survey_model
    # Mock the analytics method
    allow(Survey).to receive(:analytics).and_return({
      count: 3,
      average_feeling: 4.0,
      average_stress_level: 2.3,
      average_sleep_hours: 7.3
    })
  end
  
  # Patch the Patient model for tests
  def patch_patient_model
    # No special patching needed yet
  end
  
  # Patch the SurveyNote model for tests
  def patch_survey_note_model
    # No special patching needed yet
  end
  
  # Patch the AuditLog model for tests
  def patch_audit_log_model
    # Mock the log method
    allow(AuditLog).to receive(:log) do |admin, action, auditable, ip_address, details|
      # Create a new audit log without calling the original method
      AuditLog.new(
        admin: admin,
        action: action,
        auditable: auditable,
        ip_address: ip_address || '127.0.0.1',
        details: details || {}
      )
    end
  end
end

RSpec.configure do |config|
  config.include TestEnvironmentHelper
  
  config.before(:each) do
    # Apply the patches for each test
    patch_models_for_test_environment
  end
end
