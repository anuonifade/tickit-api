# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::PatientsController, type: :controller do
  let(:admin) { create(:admin) }
  let!(:patients) { create_list(:patient, 3) }
  let(:patient) { patients.first }
  
  describe 'GET #index' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :index
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns all patients' do
        get :index
        json_response = JSON.parse(response.body)
        expect(json_response['patients'].length).to eq(3)
      end
      
      context 'with filtering' do
        let!(:inactive_patient) { create(:patient, :inactive) }
        
        it 'filters by email' do
          get :index, params: { email: patient.email }
          json_response = JSON.parse(response.body)
          expect(json_response['patients'].length).to eq(1)
        end
        
        it 'filters by status' do
          get :index, params: { status: 'inactive' }
          json_response = JSON.parse(response.body)
          expect(json_response['patients'].length).to eq(1)
        end
      end
      
      it 'paginates results' do
        get :index, params: { page: 1, per_page: 2 }
        json_response = JSON.parse(response.body)
        expect(json_response['patients'].length).to eq(2)
        expect(json_response['meta']['total_count']).to eq(3)
        expect(json_response['meta']['total_pages']).to eq(2)
        expect(json_response['meta']['current_page']).to eq(1)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          get :index
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#index')
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
  
  describe 'GET #show' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :show, params: { id: patient.id }
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns the requested patient' do
        get :show, params: { id: patient.id }
        json_response = JSON.parse(response.body)
        expect(json_response['patient']['id']).to eq(patient.id)
        expect(json_response['patient']['email']).to eq(patient.email)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          get :show, params: { id: patient.id }
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#show')
        expect(log.admin).to eq(admin)
      end
    end
  end
  
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
        phone_number: '555-123-4567',
        date_of_birth: '1985-05-15',
        gender: 'male',
        medical_record_number: 'MRN12345',
        status: 'active'
      }
    end
    
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'creates a new patient' do
        expect {
          post :create, params: { patient: valid_attributes }
        }.to change(Patient, :count).by(1)
      end
      
      it 'returns a created status' do
        post :create, params: { patient: valid_attributes }
        expect(response).to have_http_status(:created)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          post :create, params: { patient: valid_attributes }
        }.to change(AuditLog, :count).by(2) # One for controller action, one for patient creation
        
        log = AuditLog.order(created_at: :desc).first
        expect(log.action).to eq('patients#create')
        expect(log.admin).to eq(admin)
      end
      
      context 'with invalid attributes' do
        let(:invalid_attributes) { { email: nil } }
        
        it 'does not create a new patient' do
          expect {
            post :create, params: { patient: invalid_attributes }
          }.not_to change(Patient, :count)
        end
        
        it 'returns unprocessable entity status' do
          post :create, params: { patient: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
  
  describe 'PATCH #update' do
    let(:new_attributes) { { first_name: 'Updated' } }
    
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'updates the requested patient' do
        patch :update, params: { id: patient.id, patient: new_attributes }
        # Reload the patient from the database to get the updated values
        updated_patient = Patient.find(patient.id)
        expect(updated_patient.first_name).to eq('Updated')
      end
      
      it 'returns a successful response' do
        patch :update, params: { id: patient.id, patient: new_attributes }
        expect(response).to have_http_status(:ok)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          patch :update, params: { id: patient.id, patient: new_attributes }
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#update')
        expect(log.admin).to eq(admin)
      end
    end
  end
  
  describe 'DELETE #destroy' do
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'destroys the requested patient' do
        expect {
          delete :destroy, params: { id: patient.id }
        }.to change(Patient, :count).by(-1)
      end
      
      it 'returns a no content response' do
        delete :destroy, params: { id: patient.id }
        expect(response).to have_http_status(:no_content)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          delete :destroy, params: { id: patient.id }
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#destroy')
        expect(log.admin).to eq(admin)
      end
    end
  end
  
  describe 'GET #surveys' do
    let!(:patient_with_surveys) { create(:patient, :with_surveys) }
    
    context 'when authenticated' do
      before do
        authenticate_admin(admin)
      end
      
      it 'returns a successful response' do
        get :surveys, params: { id: patient_with_surveys.id }
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns the patient\'s surveys' do
        get :surveys, params: { id: patient_with_surveys.id }
        json_response = JSON.parse(response.body)
        expect(json_response['surveys'].length).to eq(2)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          get :surveys, params: { id: patient_with_surveys.id }
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#surveys')
        expect(log.admin).to eq(admin)
      end
    end
  end
end
