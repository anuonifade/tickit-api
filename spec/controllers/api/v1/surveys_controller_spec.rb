# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SurveysController, type: :controller do
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
        expect {
          post :create, params: valid_params
        }.to change(Survey, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns the created survey' do
        post :create, params: valid_params
        expect(JSON.parse(response.body)['feeling']).to eq(4)
        expect(JSON.parse(response.body)['stress_level']).to eq(3)
        expect(JSON.parse(response.body)['sleep_hours']).to eq(7.5)
        expect(JSON.parse(response.body)['symptoms']).to eq('Occasional headaches and mild anxiety')
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
        expect {
          post :create, params: invalid_params
        }.not_to change(Survey, :count)
      end

      it 'returns an unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post :create, params: invalid_params
        expect(JSON.parse(response.body)['errors']).to include(/Feeling is not included in the list/)
      end
    end
  end

  describe 'GET #analytics' do
    before do
      create(:survey, feeling: 3, stress_level: 4, sleep_hours: 6.5)
      create(:survey, feeling: 4, stress_level: 2, sleep_hours: 8.0)
      create(:survey, feeling: 5, stress_level: 1, sleep_hours: 7.5)
    end

    it 'returns analytics data' do
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
