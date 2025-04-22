# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::SurveyResponsesController, type: :controller do
  let(:admin) { create(:admin) }
  
  # Set environment variables for encryption
  before(:all) do
    ENV['LOCKBOX_MASTER_KEY'] = 'test_key_that_is_32_bytes_long_123'
    ENV['BLIND_INDEX_MASTER_KEY'] = 'test_key_that_is_32_bytes_long_123'
    ENV['ENABLE_AUDIT_LOGS'] = 'true'
  end

  # Reset environment variables after tests
  after(:all) do
    ENV['LOCKBOX_MASTER_KEY'] = nil
    ENV['BLIND_INDEX_MASTER_KEY'] = nil
    ENV['ENABLE_AUDIT_LOGS'] = nil
  end
  
  describe 'authentication' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
        allow_any_instance_of(Api::V1::Admin::SurveyResponsesController).to receive(:index).and_return(nil)
        allow(controller).to receive(:render).and_return(nil)
        allow(AuditLog).to receive(:log).and_return(true)
      end
      
      it 'allows access to index' do
        get :index
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to show' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::SurveyResponsesController).to receive(:show).and_return(nil)
        
        get :show, params: { id: 1 }
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to flag' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::SurveyResponsesController).to receive(:flag).and_return(nil)
        
        post :flag, params: { id: 1, reason: 'Test reason' }
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to unflag' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::SurveyResponsesController).to receive(:unflag).and_return(nil)
        
        post :unflag, params: { id: 1 }
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to add_note' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::SurveyResponsesController).to receive(:add_note).and_return(nil)
        
        post :add_note, params: { id: 1, note: { content: 'Test note' } }
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to export' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::SurveyResponsesController).to receive(:export).and_return(nil)
        
        get :export
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to destroy' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::SurveyResponsesController).to receive(:destroy).and_return(nil)
        
        delete :destroy, params: { id: 1 }
        expect(response).not_to have_http_status(:unauthorized)
      end
    end
    
    context 'when not authenticated' do
      before do
        unauthenticate_admin
      end
      
      it 'returns unauthorized status for index' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
      
      it 'returns unauthorized status for show' do
        get :show, params: { id: 1 }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'environment variables' do
    it 'uses environment variables instead of Rails.env.test?' do
      # Check that the controller doesn't use Rails.env.test?
      controller_file = File.join(Rails.root, 'app', 'controllers', 'api', 'v1', 'admin', 'survey_responses_controller.rb')
      controller_code = File.read(controller_file)
      
      expect(controller_code).not_to include('Rails.env.test?')
    end
    
    it 'uses AuditLog for logging' do
      # Check that the controller uses AuditLog
      controller_file = File.join(Rails.root, 'app', 'controllers', 'api', 'v1', 'admin', 'survey_responses_controller.rb')
      controller_code = File.read(controller_file)
      
      expect(controller_code).to include('AuditLog.log')
    end
  end
end
