# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Authentication', type: :request do
  describe 'POST /api/v1/admin/login' do
    let(:admin) { create(:admin, email: 'admin@example.com', password: 'password123') }
    
    context 'with valid credentials' do
      let(:valid_params) do
        {
          admin: {
            email: admin.email,
            password: 'password123'
          }
        }
      end
      
      it 'returns a JWT token' do
        post '/api/v1/admin/login', params: valid_params
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('token')
        expect(json_response['admin']['email']).to eq(admin.email)
        expect(json_response['admin']['id']).to eq(admin.id)
      end
      
      it 'logs the successful login for HIPAA compliance' do
        # Enable audit logging for this test
        ENV['ENABLE_TEST_AUDIT_LOGS'] = 'true'
        Thread.current[:enable_audit_logs] = true
        
        # Create the admin first to ensure it exists
        admin
        
        expect {
          post '/api/v1/admin/login', params: valid_params
          # Set current admin after login since we need the admin ID for logging
          Thread.current[:current_admin] = Admin.find_by(email: valid_params[:email])
        }.to change(AuditLog, :count).by_at_least(1)
        
        # Clean up thread variables and environment
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
        ENV.delete('ENABLE_TEST_AUDIT_LOGS')
      end
    end
    
    context 'with invalid credentials' do
      let(:invalid_params) do
        {
          admin: {
            email: admin.email,
            password: 'wrong_password'
          }
        }
      end
      
      it 'returns unauthorized status' do
        post '/api/v1/admin/login', params: invalid_params
        
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
      end
    end
  end
  
  describe 'DELETE /api/v1/admin/logout' do
    let(:admin) { create(:admin) }
    let(:token) { admin.generate_jwt }
    let(:auth_header) { { 'Authorization' => "Bearer #{token}" } }
    
    context 'with valid token' do
      it 'returns success message' do
        delete '/api/v1/admin/logout', headers: auth_header
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Logged out successfully')
      end
      
      it 'logs the logout for HIPAA compliance' do
        # Enable audit logging for this test
        Thread.current[:current_admin] = admin
        Thread.current[:enable_audit_logs] = true
        
        expect {
          delete '/api/v1/admin/logout', headers: auth_header
        }.to change(AuditLog, :count).by_at_least(1)
        
        log = AuditLog.where(action: 'sessions#destroy').last
        expect(log.action).to eq('sessions#destroy')
        
        # Clean up thread variables
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
      end
    end
    
    context 'without token' do
      it 'returns unauthorized status' do
        delete '/api/v1/admin/logout'
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'GET /api/v1/admin/profile' do
    let(:admin) { create(:admin) }
    let(:token) { admin.generate_jwt }
    let(:auth_header) { { 'Authorization' => "Bearer #{token}" } }
    
    context 'with valid token' do
      before do
        setup_request_authentication(admin)
      end
      
      after do
        cleanup_request_authentication
      end
      
      it 'returns admin profile' do
        get '/api/v1/admin/profile', headers: auth_header
      
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['admin']['email']).to eq(admin.email)
        expect(json_response['admin']['id']).to eq(admin.id)
      end
    end
    
    context 'without token' do
      it 'returns unauthorized status' do
        # Ensure we're not using any thread variables
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
        
        # Mock the JWT authentication to properly return unauthorized
        allow_any_instance_of(Api::V1::Admin::AdminsController).to receive(:authenticate_admin_from_token!).and_call_original
        allow_any_instance_of(Api::V1::Admin::AdminsController).to receive(:render).with(hash_including(status: :unauthorized)).and_call_original
        
        get '/api/v1/admin/profile'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
