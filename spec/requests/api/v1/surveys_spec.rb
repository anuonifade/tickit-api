# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Surveys API', type: :request do
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
        expect {
          post '/api/v1/surveys', params: { survey: valid_attributes }
        }.to change(Survey, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['symptoms']).to eq('Mild headache')
      end
    end

    context 'with invalid parameters' do
      it 'returns errors and does not create survey' do
        post '/api/v1/surveys', params: { survey: valid_attributes.merge(feeling: nil) }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  context 'GET /api/v1/surveys' do
    before do
      create_list(:survey, 3)
    end

    it 'returns a list of surveys' do
      get '/api/v1/surveys'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(3)
    end
  end
end
