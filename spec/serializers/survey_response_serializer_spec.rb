# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveyResponseSerializer do
  let(:admin) { create(:admin) }
  let(:patient) { create(:patient) }
  let(:question) { create(:question, content: 'How are you feeling?', response_type: 'numeric_scale') }
  let(:mock_response) { create_mock_response(question: question, numeric_value: 4) }
  let(:survey) { create_mock_survey_with_responses(patient: patient, responses: [mock_response]) }

  describe 'serialization' do
    it 'includes the correct attributes' do
      serialized = SurveyResponseSerializer.new(survey).serializable_hash
      
      expect(serialized[:data][:attributes]).to include(
        :id,
        :created_at,
        :updated_at,
        :flagged,
        :flagged_reason,
        :response_count,
        :workflow_name,
        :response_data
      )
    end
    
    it 'includes response_data with correct format' do
      serialized = SurveyResponseSerializer.new(survey).serializable_hash
      
      response_data = serialized[:data][:attributes][:response_data]
      expect(response_data).to be_an(Array)
      expect(response_data.length).to eq(1)
      
      response_item = response_data.first
      expect(response_item).to include(
        :id,
        :question_id,
        :question_content,
        :question_type,
        :text_value,
        :numeric_value,
        :formatted_value
      )
      
      expect(response_item[:question_content]).to eq('How are you feeling?')
      expect(response_item[:question_type]).to eq('numeric_scale')
      expect(response_item[:numeric_value]).to eq(4)
      expect(response_item[:formatted_value]).to eq('4')
    end
    
    it 'includes patient name when admin is provided' do
      serialized = SurveyResponseSerializer.new(survey, { params: { admin: admin } }).serializable_hash
      
      expect(serialized[:data][:attributes][:patient_name]).to be_present
      expect(serialized[:data][:attributes][:patient_name]).to eq("#{patient.first_name} #{patient.last_name}")
    end
    
    it 'does not include patient name when admin is not provided' do
      serialized = SurveyResponseSerializer.new(survey).serializable_hash
      
      expect(serialized[:data][:attributes][:patient_name]).to be_nil
    end
  end
  
  describe '.serializable_hash_with_responses' do
    it 'includes responses in the output for a single resource' do
      # Use the serializable_hash_with_responses method
      serialized = SurveyResponseSerializer.serializable_hash_with_responses(survey)
      
      # Check that response_data is present
      expect(serialized[:data][:attributes][:response_data]).to be_present
      expect(serialized[:data][:attributes][:response_data].length).to eq(1)
    end
    
    it 'includes responses in the output for a collection' do
      # Create a second survey with responses
      second_survey = create_mock_survey_with_responses(response_count: 2)
      surveys = [survey, second_survey]
      
      # Use the serializable_hash_with_responses method
      serialized = SurveyResponseSerializer.serializable_hash_with_responses(surveys)
      
      expect(serialized[:data]).to be_an(Array)
      expect(serialized[:data].length).to eq(2)
      # Check that response_data is present in the first survey
      expect(serialized[:data][0][:attributes][:response_data]).to be_present
    end
    
    it 'handles empty collections' do
      # Use the serializable_hash_with_responses method with an empty array
      serialized = SurveyResponseSerializer.serializable_hash_with_responses([])
      
      expect(serialized[:data]).to be_an(Array)
      expect(serialized[:data]).to be_empty
    end
  end
end
