# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Surveys API', type: :request do
  # Create mock survey objects without using factories
  let(:mock_survey) do
    instance_double('Survey',
      id: 1,
      feeling: 4,
      stress_level: 3,
      sleep_hours: 7.5,
      symptoms: 'Mild headache',
      save: true,
      created_at: Time.now,
      as_json: {
        'id' => 1,
        'feeling' => 4,
        'stress_level' => 3,
        'sleep_hours' => 7.5,
        'symptoms' => 'Mild headache',
        'created_at' => Time.now.iso8601
      }
    )
  end
  
  # Mock serialized data for a collection of surveys
  let(:mock_surveys) do
    Array.new(3) do |i|
      instance_double('Survey',
        id: i + 1,
        feeling: 4,
        stress_level: 3,
        sleep_hours: 7.5,
        symptoms: 'Mild headache',
        created_at: Time.now
      )
    end
  end
  let(:valid_attributes) do
    {
      feeling: 4,
      stress_level: 3,
      sleep_hours: 7.5,
      symptoms: 'Mild headache'
    }
  end

  context 'POST /api/v1/surveys' do
    context 'with valid parameters' do
      it 'creates a new Survey and returns 201' do
        # Create a serialized hash that matches the SurveySerializer output
        serialized_hash = {
          data: {
            id: '1',
            type: 'survey',
            attributes: {
              feeling: 4,
              stress_level: 3,
              sleep_hours: 7.5,
              symptoms: 'Mild headache',
              created_at: Time.now.iso8601
            }
          }
        }
        
        # Mock the Survey class and serializer
        allow(Survey).to receive(:new).and_return(mock_survey)
        allow(mock_survey).to receive(:save).and_return(true)
        
        # Mock the serializer
        serializer_double = instance_double('SurveySerializer')
        allow(SurveySerializer).to receive(:new).with(mock_survey).and_return(serializer_double)
        allow(serializer_double).to receive(:serializable_hash).and_return(serialized_hash)
        
        # We can't use change matcher since we're mocking the Survey class
        post '/api/v1/surveys', params: { survey: valid_attributes }
        
        expect(response).to have_http_status(:created)
        
        # Parse the response and verify the expected attributes
        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['symptoms']).to eq('Mild headache')
      end
    end

    context 'with invalid parameters' do
      it 'returns errors and does not create survey' do
        # Create an invalid survey mock
        invalid_survey = instance_double('Survey',
          save: false,
          errors: double(full_messages: ['Feeling can\'t be blank'])
        )
        
        # Mock the Survey class
        allow(Survey).to receive(:new).and_return(invalid_survey)
        
        post '/api/v1/surveys', params: { survey: valid_attributes.merge(feeling: nil) }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  context 'GET /api/v1/surveys' do
    it 'returns a list of surveys' do
      # Create a serialized hash for a collection of surveys
      serialized_hash = {
        data: mock_surveys.map.with_index do |survey, i|
          {
            id: (i + 1).to_s,
            type: 'survey',
            attributes: {
              feeling: 4,
              stress_level: 3,
              sleep_hours: 7.5,
              symptoms: 'Mild headache',
              created_at: Time.now.iso8601
            }
          }
        end
      }
      
      # Mock the Survey class and serializer
      allow(Survey).to receive(:all).and_return(mock_surveys)
      
      # Mock the serializer
      serializer_double = instance_double('SurveySerializer')
      allow(SurveySerializer).to receive(:new).with(mock_surveys).and_return(serializer_double)
      allow(serializer_double).to receive(:serializable_hash).and_return(serialized_hash)
      
      get '/api/v1/surveys'
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['data'].length).to eq(3)
    end
  end
end
