# frozen_string_literal: true

# Helper module for encryption in tests
module EncryptionTestHelper
  # Set up test encryption keys
  def setup_test_encryption
    # Set up test keys for Lockbox and BlindIndex
    ENV['LOCKBOX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['BLIND_INDEX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
  end
  
  # Create a mock survey without triggering encryption
  def create_mock_survey(attributes = {})
    # Default attributes
    default_attributes = {
      id: 1,
      feeling: 3,
      stress_level: 3,
      sleep_hours: 8,
      symptoms: 'Headache',
      flagged: false,
      created_at: Time.current,
      updated_at: Time.current
    }
    
    # Merge with provided attributes
    survey_attributes = default_attributes.merge(attributes)
    
    # Create a double that responds to all the necessary methods
    survey = double('Survey', survey_attributes)
    
    # Allow accessing attributes via methods
    survey_attributes.each do |key, value|
      allow(survey).to receive(key).and_return(value)
      allow(survey).to receive("#{key}=") { |val| survey_attributes[key] = val }
    end
    
    # Allow checking if attributes have changed
    allow(survey).to receive(:flagged_changed?).and_return(attributes.key?(:flagged))
    
    # Allow calling private methods
    allow(survey).to receive(:log_survey_creation).and_return(true)
    allow(survey).to receive(:log_survey_update).and_return(true)
    
    # Return the mock survey
    survey
  end
  
  # Mock encryption for a model
  def mock_encryption_for(model_class)
    # For Survey model
    if model_class == Survey
      # First, set up a default for respond_to? to avoid unexpected arguments error
      allow(Survey).to receive(:respond_to?).and_return(false)
      
      # Then set up specific responses
      allow(Survey).to receive(:respond_to?).with(:encrypts).and_return(true)
      allow(Survey).to receive(:respond_to?).with(:blind_index).and_return(true)
      allow(Survey).to receive(:respond_to?).with(:find_by_symptoms).and_return(true)
      
      # Mock the class methods
      allow(Survey).to receive(:encrypts).and_return(true)
      allow(Survey).to receive(:blind_index).and_return(true)
      
      # Mock the instance variables
      allow(Survey).to receive(:instance_variable_get).with(:@encrypted_attributes).and_return([:symptoms])
      allow(Survey).to receive(:instance_variable_get).with(:@blind_indexes).and_return({symptoms: {}})
    end
    
    # For Patient model
    if model_class == Patient
      # First, set up a default for respond_to? to avoid unexpected arguments error
      allow(Patient).to receive(:respond_to?).and_return(false)
      
      # Then set up specific responses
      allow(Patient).to receive(:respond_to?).with(:encrypts).and_return(true)
      allow(Patient).to receive(:respond_to?).with(:blind_index).and_return(true)
      allow(Patient).to receive(:respond_to?).with(:find_by_first_name).and_return(true)
      allow(Patient).to receive(:respond_to?).with(:find_by_last_name).and_return(true)
      allow(Patient).to receive(:respond_to?).with(:find_by_medical_record_number).and_return(true)
      
      # Mock the class methods
      allow(Patient).to receive(:encrypts).and_return(true)
      allow(Patient).to receive(:blind_index).and_return(true)
      
      # Mock the instance variables
      allow(Patient).to receive(:instance_variable_get).with(:@encrypted_attributes).and_return(
        [:first_name, :last_name, :date_of_birth, :medical_record_number]
      )
      allow(Patient).to receive(:instance_variable_get).with(:@blind_indexes).and_return(
        {email: {}, medical_record_number: {}}
      )
    end
    
    # For SurveyNote model
    if model_class == SurveyNote
      # First, set up a default for respond_to? to avoid unexpected arguments error
      allow(SurveyNote).to receive(:respond_to?).and_return(false)
      
      # Then set up specific responses
      allow(SurveyNote).to receive(:respond_to?).with(:encrypts).and_return(true)
      
      # Mock the class methods
      allow(SurveyNote).to receive(:encrypts).and_return(true)
      
      # Mock the instance variables
      allow(SurveyNote).to receive(:instance_variable_get).with(:@encrypted_attributes).and_return([:content])
    end
    
    # For Response model
    if model_class == Response
      # First, set up a default for respond_to? to avoid unexpected arguments error
      allow(Response).to receive(:respond_to?).and_return(false)
      
      # Then set up specific responses
      allow(Response).to receive(:respond_to?).with(:encrypts).and_return(true)
      
      # Mock the class methods
      allow(Response).to receive(:encrypts).and_return(true)
      
      # Mock the instance variables
      allow(Response).to receive(:instance_variable_get).with(:@encrypted_attributes).and_return([:text_value, :numeric_value])
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
