# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::AuditLogsController, type: :controller do
  let(:super_admin) { create(:admin, :super_admin) }
  let(:regular_admin) { create(:admin) }
  
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
    context 'when authenticated as super admin' do
      before do
        authenticate_admin(super_admin)
        allow_any_instance_of(Api::V1::Admin::AuditLogsController).to receive(:index).and_return(nil)
        allow(controller).to receive(:render).and_return(nil)
      end
      
      it 'allows access to index' do
        get :index
        expect(response).not_to have_http_status(:unauthorized)
        expect(response).not_to have_http_status(:forbidden)
      end
      
      it 'allows access to export' do
        # Mock the controller method
        allow_any_instance_of(Api::V1::Admin::AuditLogsController).to receive(:export).and_return(nil)
        allow(controller).to receive(:render).and_return(nil)
        allow(controller).to receive(:send_data).and_return(nil)
        
        get :export
        expect(response).not_to have_http_status(:unauthorized)
        expect(response).not_to have_http_status(:forbidden)
      end
    end
    
    context 'when authenticated as regular admin' do
      before do
        authenticate_admin(regular_admin)
      end
      
      it 'returns forbidden status for index' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
      
      it 'returns forbidden status for export' do
        get :export
        expect(response).to have_http_status(:forbidden)
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
      controller_file = File.join(Rails.root, 'app', 'controllers', 'api', 'v1', 'admin', 'audit_logs_controller.rb')
      controller_code = File.read(controller_file)
      
      expect(controller_code).not_to include('Rails.env.test?')
    end
  end
end
