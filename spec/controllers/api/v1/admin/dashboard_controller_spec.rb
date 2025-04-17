# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::DashboardController, type: :controller do
  let(:admin) { create(:admin) }
  let(:super_admin) { create(:admin, :super_admin) }
  
  describe 'GET #index' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :index
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns dashboard statistics' do
        create_list(:survey, 3)
        create_list(:question, 2)
        create(:survey_workflow)
        
        get :index
        json_response = JSON.parse(response.body)
        
        expect(json_response).to have_key('surveys')
        expect(json_response).to have_key('questions')
        expect(json_response).to have_key('workflows')
        expect(json_response).to have_key('patients')
        expect(json_response).to have_key('audit_logs')
        expect(json_response).to have_key('recent_activity')
      end
      
      it 'logs the dashboard access for HIPAA compliance' do
        expect {
          get :index
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('dashboard.view')
        expect(log.admin).to eq(admin)
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
  
  describe 'GET #hipaa_compliance' do
    context 'when authenticated as admin' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :hipaa_compliance
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns HIPAA compliance statistics' do
        create_list(:audit_log, 3)
        create(:admin, :super_admin)
        
        get :hipaa_compliance
        json_response = JSON.parse(response.body)
        
        expect(json_response).to have_key('audit_logs')
        expect(json_response).to have_key('data_encryption')
        expect(json_response).to have_key('access_controls')
      end
      
      it 'logs the compliance check for HIPAA audit trail' do
        expect {
          get :hipaa_compliance
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('dashboard.hipaa_compliance')
        expect(log.admin).to eq(admin)
      end
    end
    
    context 'when authenticated as super admin' do
      before do
        authenticate_admin(super_admin)
      end
      
      it 'returns a successful response' do
        get :hipaa_compliance
        expect(response).to have_http_status(:ok)
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
        get :hipaa_compliance
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
