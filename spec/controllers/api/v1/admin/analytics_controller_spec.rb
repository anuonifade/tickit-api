# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::AnalyticsController, type: :controller do
  let(:admin) { create(:admin) }
  
  describe 'GET #index' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :index
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns analytics data' do
        create_list(:survey, 3)
        create_list(:patient, 2)
        
        get :index
        json_response = JSON.parse(response.body)
        
        expect(json_response).to have_key('surveys')
        expect(json_response).to have_key('patients')
        expect(json_response).to have_key('response_metrics')
        expect(json_response).to have_key('surveys_by_date')
        expect(json_response).to have_key('response_distribution')
        expect(json_response).to have_key('hipaa_compliance')
      end
      
      it 'logs the analytics access for HIPAA compliance' do
        # Clear existing logs before the test
        AuditLog.delete_all
        
        # Make the request
        get :index
        
        # Verify a log was created
        expect(AuditLog.count).to eq(1)
        log = AuditLog.last
        expect(log.action).to eq('analytics.index')
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
  
  describe 'GET #patient_demographics' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :patient_demographics
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns patient demographics data' do
        create(:patient, gender: 'male')
        create(:patient, gender: 'female')
        create(:patient, :with_surveys)
        
        get :patient_demographics
        json_response = JSON.parse(response.body)
        
        expect(json_response).to have_key('gender_distribution')
        expect(json_response).to have_key('age_groups')
        expect(json_response).to have_key('status_distribution')
        expect(json_response).to have_key('survey_completion')
      end
      
      it 'logs the demographics access for HIPAA compliance' do
        # Clear existing logs before the test
        AuditLog.delete_all
        
        # Make the request
        get :patient_demographics
        
        # Verify a log was created
        expect(AuditLog.count).to eq(1)
        log = AuditLog.last
        expect(log.action).to eq('analytics.patient_demographics')
        expect(log.admin).to eq(admin)
      end
    end
  end
  
  describe 'GET #surveys_by_workflow' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :surveys_by_workflow
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns surveys grouped by workflow' do
        workflow = create(:survey_workflow)
        create(:survey, survey_workflow: workflow)
        create(:survey, survey_workflow: nil)
        
        get :surveys_by_workflow
        json_response = JSON.parse(response.body)
        
        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(2) # One for the workflow, one for nil workflow
      end
      
      it 'logs the access for HIPAA compliance' do
        # Clear existing logs before the test
        AuditLog.delete_all
        
        # Make the request
        get :surveys_by_workflow
        
        # Verify a log was created
        expect(AuditLog.count).to eq(1)
        log = AuditLog.last
        expect(log.action).to eq('analytics.surveys_by_workflow')
        expect(log.admin).to eq(admin)
      end
    end
  end
  
  describe 'GET #export_data' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :export_data
        expect(response).to have_http_status(:ok)
      end
      
      it 'logs the data export for HIPAA compliance' do
        # Clear existing logs before the test
        AuditLog.delete_all
        
        # Make the request
        get :export_data
        
        # Verify a log was created
        expect(AuditLog.count).to eq(1)
        log = AuditLog.last
        expect(log.action).to eq('analytics.export_data')
        expect(log.admin).to eq(admin)
      end
    end
  end
end
