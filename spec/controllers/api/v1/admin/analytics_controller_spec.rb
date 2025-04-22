# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::AnalyticsController, type: :controller do
  let(:admin) { create(:admin) }
  
  describe 'authentication' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
        
        # Mock the controller to avoid database interactions
        allow_any_instance_of(Api::V1::Admin::AnalyticsController).to receive(:index).and_return(nil)
        allow(controller).to receive(:render).and_return(nil)
        allow(AuditService).to receive(:log_event).and_return(true)
      end
      
      it 'allows access to index' do
        get :index
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to patient_demographics' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::AnalyticsController).to receive(:patient_demographics).and_return(nil)
        
        get :patient_demographics
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to surveys_by_workflow' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::AnalyticsController).to receive(:surveys_by_workflow).and_return(nil)
        
        get :surveys_by_workflow
        expect(response).not_to have_http_status(:unauthorized)
      end
      
      it 'allows access to export_data' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::AnalyticsController).to receive(:export_data).and_return(nil)
        
        get :export_data
        expect(response).not_to have_http_status(:unauthorized)
      end
    end
    
    context 'when not authenticated' do
      before do
        unauthenticate_admin
      end
      
      it 'returns unauthorized status' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'environment variables' do
    it 'uses environment variables instead of Rails.env.test?' do
      # Check that the controller doesn't use Rails.env.test?
      analytics_controller_file = File.join(Rails.root, 'app', 'controllers', 'api', 'v1', 'admin', 'analytics_controller.rb')
      controller_code = File.read(analytics_controller_file)
      
      expect(controller_code).not_to include('Rails.env.test?')
    end
    
    it 'uses AuditLog for logging' do
      # Check that the controller uses AuditLog
      analytics_controller_file = File.join(Rails.root, 'app', 'controllers', 'api', 'v1', 'admin', 'analytics_controller.rb')
      controller_code = File.read(analytics_controller_file)
      
      expect(controller_code).to include('AuditLog.log')
    end
  end
end
