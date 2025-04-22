# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SurveysController, type: :controller do
  # Create mock survey objects without using factories
  let(:mock_survey) do
    instance_double('Survey',
      id: 1,
      feeling: 4,
      stress_level: 3,
      sleep_hours: 7.5,
      symptoms: 'Occasional headaches and mild anxiety',
      save: true,
      created_at: Time.now,
      as_json: {
        'id' => 1,
        'feeling' => 4,
        'stress_level' => 3,
        'sleep_hours' => 7.5,
        'symptoms' => 'Occasional headaches and mild anxiety',
        'created_at' => Time.now.iso8601
      }
    )
  end
  
  let(:mock_invalid_survey) do
    instance_double('Survey',
      id: nil,
      feeling: 10, # Invalid value
      stress_level: 3,
      sleep_hours: 7.5,
      symptoms: 'Occasional headaches and mild anxiety',
      save: false,
      errors: double(full_messages: ['Feeling is not included in the list'])
    )
  end
  
  # Mock analytics data
  let(:analytics_data) do
    {
      count: 3,
      average_feeling: 4.0,
      average_stress_level: 2.3,
      average_sleep_hours: 7.3
    }
  end
  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          survey: {
            feeling: 4,
            stress_level: 3,
            sleep_hours: 7.5,
            symptoms: 'Occasional headaches and mild anxiety'
          }
        }
      end

      it 'creates a new survey' do
        # Allow Survey.new to be called with any parameters and return our mock
        allow(Survey).to receive(:new).and_return(mock_survey)
        
        # Expect the mock to be saved
        expect(mock_survey).to receive(:save).and_return(true)
        
        post :create, params: valid_params
      end

      it 'returns a created status' do
        # Stub Survey.new to return our mock
        allow(Survey).to receive(:new).and_return(mock_survey)
        
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the created survey' do
        # Create a serialized hash that matches the SurveySerializer output
        serialized_hash = {
          data: {
            id: '1',
            type: 'survey',
            attributes: {
              feeling: 4,
              stress_level: 3,
              sleep_hours: 7.5,
              symptoms: 'Occasional headaches and mild anxiety',
              created_at: Time.now.iso8601
            }
          }
        }
        
        # Mock the serializer
        serializer_double = instance_double('SurveySerializer')
        allow(SurveySerializer).to receive(:new).with(mock_survey).and_return(serializer_double)
        allow(serializer_double).to receive(:serializable_hash).and_return(serialized_hash)
        
        # Stub Survey.new to return our mock
        allow(Survey).to receive(:new).and_return(mock_survey)
        
        post :create, params: valid_params
        
        # Parse the response and verify the expected attributes
        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']['feeling']).to eq(4)
        expect(json_response['data']['attributes']['stress_level']).to eq(3)
        expect(json_response['data']['attributes']['sleep_hours']).to eq(7.5)
        expect(json_response['data']['attributes']['symptoms']).to eq('Occasional headaches and mild anxiety')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          survey: {
            feeling: 10, # Invalid - outside range
            stress_level: 3,
            sleep_hours: 7.5,
            symptoms: 'Occasional headaches and mild anxiety'
          }
        }
      end

      it 'does not create a new survey' do
        # Stub Survey.new to return our invalid mock
        allow(Survey).to receive(:new).and_return(mock_invalid_survey)
        
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an unprocessable entity status' do
        # Stub Survey.new to return our invalid mock
        allow(Survey).to receive(:new).and_return(mock_invalid_survey)
        
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        # Stub Survey.new to return our invalid mock
        allow(Survey).to receive(:new).and_return(mock_invalid_survey)
        
        post :create, params: invalid_params
        expect(JSON.parse(response.body)['errors']).to include('Feeling is not included in the list')
      end
    end
  end

  describe 'GET #analytics' do
    before do
      # Stub the Survey.analytics class method
      allow(Survey).to receive(:analytics).and_return(analytics_data)
    end
    
    it 'returns analytics data' do
      # Verify that the Survey.analytics method is called
      expect(Survey).to receive(:analytics).and_return(analytics_data)
      
      get :analytics
      
      json_response = JSON.parse(response.body)
      expect(json_response['count']).to eq(3)
      expect(json_response['average_feeling']).to eq(4.0)
      expect(json_response['average_stress_level']).to eq(2.3)
      expect(json_response['average_sleep_hours']).to eq(7.3)
    end

    it 'returns a success status' do
      get :analytics
      expect(response).to have_http_status(:success)
    end
  end
end
