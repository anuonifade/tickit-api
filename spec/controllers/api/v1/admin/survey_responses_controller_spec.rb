# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::SurveyResponsesController, type: :controller do
  let(:admin) { create(:admin) }
  let!(:surveys) { create_list(:survey, 3) }
  let(:survey) { surveys.first }
  
  describe 'GET #index' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :index
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns all surveys' do
        get :index
        json_response = JSON.parse(response.body)
        expect(json_response['data'].length).to eq(3)
      end
      
      it 'includes response_data attribute in the serialized output' do
        get :index
        json_response = JSON.parse(response.body)
        expect(json_response['data'].first['attributes']).to have_key('response_data')
      end
      
      it 'creates responses for surveys that have none' do
        # Clear any existing responses
        Response.delete_all
        
        # Make sure our survey has no responses
        expect(survey.responses.count).to eq(0)
        
        get :index
        
        # Reload the survey to see if responses were created
        survey.reload
        expect(survey.responses.count).to be > 0
      end
      
      context 'with filtering' do
        let!(:flagged_survey) { create(:survey, :flagged) }
        let!(:patient) { create(:patient) }
        let!(:patient_survey) { create(:survey, patient: patient) }
        let!(:workflow) { create(:survey_workflow) }
        let!(:workflow_survey) { create(:survey, survey_workflow: workflow) }
        
        it 'filters by flagged status' do
          get :index, params: { flagged: 'true' }
          json_response = JSON.parse(response.body)
          expect(json_response['data'].length).to eq(1)
        end
        
        it 'filters by patient' do
          get :index, params: { patient_id: patient.id }
          json_response = JSON.parse(response.body)
          expect(json_response['data'].length).to eq(1)
        end
        
        it 'filters by workflow' do
          get :index, params: { workflow_id: workflow.id }
          json_response = JSON.parse(response.body)
          expect(json_response['data'].length).to eq(1)
        end
        
        it 'filters by date range' do
          old_survey = create(:survey, created_at: 10.days.ago)
          get :index, params: { start_date: 2.days.ago.to_date.to_s, end_date: Date.today.to_s }
          json_response = JSON.parse(response.body)
          expect(json_response['data'].length).to eq(6) # 3 + flagged + patient + workflow
        end
      end
      
      it 'logs the search for HIPAA compliance' do
        # Enable audit logging for this test
        Thread.current[:current_admin] = admin
        Thread.current[:enable_audit_logs] = true
        
        expect {
          get :index
        }.to change(AuditLog, :count).by_at_least(1)
        
        log = AuditLog.where(action: 'survey_responses.search').last
        expect(log.action).to eq('survey_responses.search')
        
        # Clean up thread variables
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
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
  
  describe 'GET #show' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :show, params: { id: survey.id }
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns the requested survey' do
        get :show, params: { id: survey.id }
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id'].to_i).to eq(survey.id)
      end
      
      it 'includes response_data attribute in the serialized output' do
        get :show, params: { id: survey.id }
        json_response = JSON.parse(response.body)
        expect(json_response['data']['attributes']).to have_key('response_data')
      end
      
      it 'creates responses for a survey that has none' do
        # Clear any existing responses for this survey
        survey.responses.delete_all
        
        # Make sure our survey has no responses
        expect(survey.responses.count).to eq(0)
        
        get :show, params: { id: survey.id }
        
        # Reload the survey to see if responses were created
        survey.reload
        expect(survey.responses.count).to be > 0
      end
    end
  end
  
  describe 'DELETE #destroy' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'destroys the requested survey' do
        expect {
          delete :destroy, params: { id: survey.id }
        }.to change(Survey, :count).by(-1)
      end
      
      it 'returns a no content response' do
        delete :destroy, params: { id: survey.id }
        expect(response).to have_http_status(:no_content)
      end
    end
  end
  
  describe 'POST #flag' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'flags the survey' do
        post :flag, params: { id: survey.id, reason: 'Concerning response' }
        survey.reload
        expect(survey.flagged).to be true
        expect(survey.flagged_reason).to eq('Concerning response')
        expect(survey.flagged_by_id).to eq(admin.id)
      end
      
      it 'returns a successful response' do
        post :flag, params: { id: survey.id, reason: 'Concerning response' }
        expect(response).to have_http_status(:ok)
      end
      
      it 'logs the action for HIPAA compliance' do
        # Enable audit logging for this test
        Thread.current[:current_admin] = admin
        Thread.current[:enable_audit_logs] = true
        
        expect {
          post :flag, params: { id: survey.id, reason: 'Concerning response' }
        }.to change(AuditLog, :count).by_at_least(1)
        
        log = AuditLog.where(action: 'survey.flag').last
        expect(log.action).to eq('survey.flag')
        expect(log.auditable).to eq(survey)
        
        # Clean up thread variables
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
      end
    end
  end
  
  describe 'POST #unflag' do
    let!(:flagged_survey) { create(:survey, :flagged) }
    
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'unflags the survey' do
        post :unflag, params: { id: flagged_survey.id }
        flagged_survey.reload
        expect(flagged_survey.flagged).to be false
        expect(flagged_survey.flagged_reason).to be_nil
        expect(flagged_survey.flagged_by_id).to be_nil
      end
      
      it 'returns a successful response' do
        post :unflag, params: { id: flagged_survey.id }
        expect(response).to have_http_status(:ok)
      end
      
      it 'logs the action for HIPAA compliance' do
        # Enable audit logging for this test
        Thread.current[:current_admin] = admin
        Thread.current[:enable_audit_logs] = true
        
        expect {
          post :unflag, params: { id: flagged_survey.id }
        }.to change(AuditLog, :count).by_at_least(1)
        
        log = AuditLog.where(action: 'survey.unflag').last
        expect(log.action).to eq('survey.unflag')
        expect(log.auditable).to eq(flagged_survey)
        
        # Clean up thread variables
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
      end
    end
  end
  
  describe 'POST #add_note' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'adds a note to the survey' do
        expect {
          post :add_note, params: { id: survey.id, content: 'Test note' }
        }.to change(SurveyNote, :count).by(1)
        
        note = SurveyNote.last
        expect(note.survey).to eq(survey)
        expect(note.admin).to eq(admin)
        expect(note.content).to eq('Test note')
      end
      
      it 'returns a successful response' do
        post :add_note, params: { id: survey.id, content: 'Test note' }
        expect(response).to have_http_status(:ok)
      end
      
      it 'logs the action for HIPAA compliance' do
        # Enable audit logging for this test
        Thread.current[:current_admin] = admin
        Thread.current[:enable_audit_logs] = true
        
        expect {
          post :add_note, params: { id: survey.id, content: 'Test note' }
        }.to change(AuditLog, :count).by_at_least(1)
        
        log = AuditLog.where(action: 'survey.add_note').last
        expect(log.action).to eq('survey.add_note')
        expect(log.auditable).to eq(survey)
        
        # Clean up thread variables
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
      end
    end
  end
  
  describe 'GET #export' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :export
        expect(response).to have_http_status(:ok)
      end
      
      it 'logs the action for HIPAA compliance' do
        # Enable audit logging for this test
        Thread.current[:current_admin] = admin
        Thread.current[:enable_audit_logs] = true
        
        expect {
          get :export
        }.to change(AuditLog, :count).by_at_least(1)
        
        # Clean up thread variables
        Thread.current[:current_admin] = nil
        Thread.current[:enable_audit_logs] = nil
      end
    end
  end
end
