# frozen_string_literal: true

# Helper module for encryption in tests
module EncryptionTestHelper
  # Set up test encryption keys
  def setup_test_encryption
    # Set up test keys for Lockbox and BlindIndex
    ENV['LOCKBOX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['BLIND_INDEX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
  end
  
  # Mock encryption for a model
  def mock_encryption_for(model_class)
    # For Survey model
    if model_class == Survey
      # Mock the encrypted_attributes method
      allow(Survey).to receive(:encrypted_attributes).and_return(['symptoms'])
      
      # Mock the blind_index method to be a no-op
      allow(Survey).to receive(:blind_index).and_return(nil)
    end
    
    # For Patient model
    if model_class == Patient
      # Mock the encrypted_attributes method
      allow(Patient).to receive(:encrypted_attributes).and_return(
        ['first_name', 'last_name', 'date_of_birth', 'medical_record_number']
      )
      
      # Mock the blind_index method to be a no-op
      allow(Patient).to receive(:blind_index).and_return(nil)
    end
    
    # For SurveyNote model
    if model_class == SurveyNote
      # Mock the encrypted_attributes method
      allow(SurveyNote).to receive(:encrypted_attributes).and_return(['content'])
    end
    
    # For Response model
    if model_class == Response
      # Mock the encrypted_attributes method
      allow(Response).to receive(:encrypted_attributes).and_return(['text_value', 'numeric_value'])
    end
  end
end

RSpec.configure do |config|
  config.include EncryptionTestHelper
  
  config.before(:suite) do
    # Set up test encryption keys for the entire test suite
    ENV['LOCKBOX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['BLIND_INDEX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
  end
end
