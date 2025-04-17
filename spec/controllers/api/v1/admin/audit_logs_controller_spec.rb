# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::AuditLogsController, type: :controller do
  let(:super_admin) { create(:admin, :super_admin) }
  let(:regular_admin) { create(:admin) }
  
  # Enable audit logging for all tests in this file
  before(:all) do
    ENV['ENABLE_TEST_AUDIT_LOGS'] = 'true'
  end

  # Disable audit logging after all tests
  after(:all) do
    ENV['ENABLE_TEST_AUDIT_LOGS'] = nil
  end

  # Clear audit logs before each test
  before(:each) do
    AuditLog.delete_all
    Thread.current[:enable_audit_logs] = true
    Thread.current[:clear_audit_logs_before_test] = false
  end

  describe 'GET #index' do
    context 'when authenticated as super admin' do
      before do
        authenticate_admin(super_admin)
        # Create audit logs after authentication
        AuditLog.delete_all
        
        # Create a set of audit logs for testing
        5.times do |i|
          AuditLog.create!(
            admin: super_admin,
            action: 'admin.login',
            ip_address: '127.0.0.1',
            details: { timestamp: Time.now.to_i }
          )
        end
      end
      
      it 'returns a successful response' do
        get :index
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns audit logs' do
        # Verify logs exist in the database
        expect(AuditLog.count).to eq(5)
        
        # Test the index action
        get :index
        expect(response).to have_http_status(:ok)
        
        # Parse the response
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('audit_logs')
      end
      
      it 'filters by admin_id' do
        get :index, params: { admin_id: super_admin.id }
        expect(response).to have_http_status(:ok)
      end
      
      it 'filters by action_name' do
        get :index, params: { action_name: 'admin.login' }
        expect(response).to have_http_status(:ok)
      end
      
      it 'filters by date range' do
        start_date = (Date.today - 1.day).to_s
        end_date = (Date.today + 1.day).to_s
        get :index, params: { start_date: start_date, end_date: end_date }
        expect(response).to have_http_status(:ok)
      end
      
      it 'paginates results' do
        get :index, params: { page: 1, per_page: 2 }
        expect(response).to have_http_status(:ok)
      end
    end
    
    context 'when authenticated as regular admin' do
      before do
        authenticate_admin(regular_admin)
      end
      
      it 'returns forbidden status' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
    
    context 'when not authenticated' do
      before do
        # Make sure we're not authenticated
        Thread.current[:current_admin] = nil
        Thread.current[:test_unauthorized_access] = true
        allow(controller).to receive(:authenticate_admin_from_token!).and_call_original
      end
      
      after do
        Thread.current[:test_unauthorized_access] = false
      end
      
      it 'returns unauthorized status' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'GET #export' do
    context 'when authenticated as super admin' do
      before do
        authenticate_admin(super_admin)
        # Create some audit logs for the export
        5.times { create(:audit_log) }
      end
      
      it 'returns a CSV file' do
        get :export
        expect(response.content_type).to include('text/csv')
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('filename=audit_logs_')
      end
    end
    
    context 'when authenticated as regular admin' do
      before do
        authenticate_admin(regular_admin)
      end
      
      it 'returns forbidden status' do
        get :export
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
