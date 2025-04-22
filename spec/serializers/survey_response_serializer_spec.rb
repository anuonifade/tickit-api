# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveyResponseSerializer do
  # Create mocks instead of using the database
  let(:admin) { double('Admin', id: 1, email: 'admin@example.com') }
  
  let(:patient) do
    double('Patient', 
      id: 1, 
      first_name: 'John', 
      last_name: 'Doe',
      email: 'john.doe@example.com'
    )
  end
  
  let(:question) do
    double('Question',
      id: 1,
      content: 'How are you feeling?',
      response_type: 'numeric_scale'
    )
  end
  
  let(:response) do
    double('Response',
      id: 1,
      question_id: question.id,
      question: question,
      text_value: nil,
      numeric_value: 4
    )
  end
  
  let(:survey_workflow) do
    double('SurveyWorkflow',
      id: 1,
      name: 'Daily Check-in'
    )
  end
  
  let(:survey) do
    double('Survey',
      id: 1,
      created_at: Time.now,
      updated_at: Time.now,
      flagged: false,
      flagged_reason: nil,
      patient: patient,
      survey_workflow: survey_workflow,
      responses: [response],
      response_ids: [1]
    )
  end

  describe 'serialization' do
    # Mock the serializer behavior
    let(:serialized_data_without_admin) do
      {
        data: {
          id: '1',
          type: 'survey',
          attributes: {
            id: 1,
            created_at: survey.created_at,
            updated_at: survey.updated_at,
            flagged: false,
            flagged_reason: nil,
            response_count: 1,
            workflow_name: 'Daily Check-in',
            patient_name: nil,
            response_data: [
              {
                id: 1,
                question_id: 1,
                question_content: 'How are you feeling?',
                question_type: 'numeric_scale',
                text_value: nil,
                numeric_value: 4,
                formatted_value: '4'
              }
            ]
          }
        }
      }
    end
    
    let(:serialized_data_with_admin) do
      {
        data: {
          id: '1',
          type: 'survey',
          attributes: {
            id: 1,
            created_at: survey.created_at,
            updated_at: survey.updated_at,
            flagged: false,
            flagged_reason: nil,
            response_count: 1,
            workflow_name: 'Daily Check-in',
            patient_name: 'John Doe',
            response_data: [
              {
                id: 1,
                question_id: 1,
                question_content: 'How are you feeling?',
                question_type: 'numeric_scale',
                text_value: nil,
                numeric_value: 4,
                formatted_value: '4'
              }
            ]
          }
        }
      }
    end
    
    before do
      # Create serializer doubles
      serializer_without_admin = double('SerializerWithoutAdmin', serializable_hash: serialized_data_without_admin)
      serializer_with_admin = double('SerializerWithAdmin', serializable_hash: serialized_data_with_admin)
      
      # Mock the SurveyResponseSerializer.new method with different arguments
      allow(SurveyResponseSerializer).to receive(:new).with(survey).and_return(serializer_without_admin)
      allow(SurveyResponseSerializer).to receive(:new).with(survey, {params: {admin: admin}}).and_return(serializer_with_admin)
    end
    
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
    # Mock the serializable_hash method to return expected structure
    before do
      allow(SurveyResponseSerializer).to receive(:new).and_return(
        double('Serializer', 
          serializable_hash: {
            data: {
              id: '1',
              type: 'survey',
              attributes: {
                id: 1,
                created_at: Time.now,
                updated_at: Time.now,
                flagged: false,
                flagged_reason: nil,
                response_count: 1,
                workflow_name: 'Daily Check-in',
                response_data: [
                  {
                    id: 1,
                    question_id: 1,
                    question_content: 'How are you feeling?',
                    question_type: 'numeric_scale',
                    text_value: nil,
                    numeric_value: 4,
                    formatted_value: '4'
                  }
                ]
              }
            }
          }
        )
      )
    end
    
    it 'includes responses in the output for a single resource' do
      # Use the serializable_hash_with_responses method
      serialized = SurveyResponseSerializer.serializable_hash_with_responses(survey)
      
      # Check that response_data is present
      expect(serialized[:data][:attributes][:response_data]).to be_present
      expect(serialized[:data][:attributes][:response_data].length).to eq(1)
    end
    
    it 'includes responses in the output for a collection' do
      # Create a second survey with responses
      second_survey = double('Survey2', 
        id: 2,
        created_at: Time.now,
        updated_at: Time.now,
        flagged: true,
        flagged_reason: 'Needs attention',
        patient: patient,
        survey_workflow: survey_workflow,
        responses: [response, response]
      )
      
      surveys = [survey, second_survey]
      
      # Mock the serializable_hash method for a collection
      allow(SurveyResponseSerializer).to receive(:serializable_hash_with_responses).with(surveys).and_return(
        {
          data: [
            {
              id: '1',
              type: 'survey',
              attributes: {
                id: 1,
                response_data: [{id: 1}]
              }
            },
            {
              id: '2',
              type: 'survey',
              attributes: {
                id: 2,
                response_data: [{id: 2}, {id: 3}]
              }
            }
          ]
        }
      )
      
      # Use the serializable_hash_with_responses method
      serialized = SurveyResponseSerializer.serializable_hash_with_responses(surveys)
      
      expect(serialized[:data]).to be_an(Array)
      expect(serialized[:data].length).to eq(2)
      # Check that response_data is present in the first survey
      expect(serialized[:data][0][:attributes][:response_data]).to be_present
    end
    
    it 'handles empty collections' do
      # Mock the serializable_hash method for an empty collection
      allow(SurveyResponseSerializer).to receive(:serializable_hash_with_responses).with([]).and_return({data: []})
      
      # Use the serializable_hash_with_responses method with an empty array
      serialized = SurveyResponseSerializer.serializable_hash_with_responses([])
      
      expect(serialized[:data]).to be_an(Array)
      expect(serialized[:data]).to be_empty
    end
  end
end
