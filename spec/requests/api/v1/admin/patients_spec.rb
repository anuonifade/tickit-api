# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Patient Management', type: :request do
  let(:admin) { create(:admin) }
  let(:token) { admin.generate_jwt }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}" } }
  
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
    # Set current admin in thread-local variable for HIPAA audit logging
    Thread.current[:current_admin] = admin
  end
  
  # Clear thread-local variables after each test
  after(:each) do
    Thread.current[:current_admin] = nil
  end
  
  describe 'GET /api/v1/admin/patients' do
    let!(:patients) { create_list(:patient, 3) }
    
    context 'with valid token' do
      before do
        setup_request_authentication(admin)
      end

      after do
        cleanup_request_authentication
      end
      
      it 'returns all patients' do
        get '/api/v1/admin/patients', headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['patients'].length).to eq(3)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          get '/api/v1/admin/patients', headers: auth_headers
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#index')
        expect(log.admin_id).to eq(admin.id)
      end
    end
    
    context 'without token' do
      before do
        setup_unauthorized_access
      end
      
      it 'returns unauthorized status' do
        get '/api/v1/admin/patients'
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe 'GET /api/v1/admin/patients/:id' do
    let!(:patient) { create(:patient) }
    
    context 'with valid token' do
      before do
        setup_request_authentication(admin)
      end

      after do
        cleanup_request_authentication
      end
      
      it 'returns the patient' do
        get "/api/v1/admin/patients/#{patient.id}", headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['patient']['id']).to eq(patient.id)
        expect(json_response['patient']['email']).to eq(patient.email)
        expect(json_response['patient']['first_name']).to eq(patient.first_name)
        expect(json_response['patient']['last_name']).to eq(patient.last_name)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          get "/api/v1/admin/patients/#{patient.id}", headers: auth_headers
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#show')
        expect(log.admin_id).to eq(admin.id)
      end
    end
  end
  
  describe 'POST /api/v1/admin/patients' do
    let(:valid_params) do
      {
        patient: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          phone_number: '555-123-4567',
          date_of_birth: '1985-05-15',
          gender: 'male',
          medical_record_number: 'MRN12345',
          status: 'active'
        }
      }
    end
    
    context 'with valid token and parameters' do
      before do
        setup_request_authentication(admin)
      end

      after do
        cleanup_request_authentication
      end
      
      it 'creates a new patient' do
        expect {
          post '/api/v1/admin/patients', params: valid_params, headers: auth_headers
        }.to change(Patient, :count).by(1)
        
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['patient']['email']).to eq('john.doe@example.com')
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          post '/api/v1/admin/patients', params: valid_params, headers: auth_headers
        }.to change(AuditLog, :count).by(2) # One for controller action, one for patient creation
        
        log = AuditLog.where(action: 'patients#create').first
        expect(log.admin_id).to eq(admin.id)
      end
    end
    
    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          patient: {
            first_name: 'John',
            # Missing required fields
          }
        }
      end
      
      before do
        setup_request_authentication(admin)
      end

      after do
        cleanup_request_authentication
      end
      
      it 'returns unprocessable entity status' do
        post '/api/v1/admin/patients', params: invalid_params, headers: auth_headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_present
      end
    end
  end
  
  describe 'PATCH /api/v1/admin/patients/:id' do
    let!(:patient) { create(:patient) }
    let(:update_params) do
      {
        patient: {
          first_name: 'Updated',
          last_name: 'Name'
        }
      }
    end
    
    context 'with valid token and parameters' do
      it 'updates the patient' do
        patch "/api/v1/admin/patients/#{patient.id}", params: update_params, headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        
        # Get the updated patient from the response JSON
        json_response = JSON.parse(response.body)
        expect(json_response['patient']['first_name']).to eq('Updated')
        expect(json_response['patient']['last_name']).to eq('Name')
        
        # Reload the patient to verify database was updated
        updated_patient = Patient.find(patient.id)
        # Access the encrypted fields through the class variables
        first_name = Patient.class_variable_get(:@@first_name_store)[updated_patient.id.to_s]
        last_name = Patient.class_variable_get(:@@last_name_store)[updated_patient.id.to_s]
        expect(first_name).to eq('Updated')
        expect(last_name).to eq('Name')
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          patch "/api/v1/admin/patients/#{patient.id}", params: update_params, headers: auth_headers
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#update')
        expect(log.admin_id).to eq(admin.id)
      end
    end
  end
  
  describe 'DELETE /api/v1/admin/patients/:id' do
    let!(:patient) { create(:patient) }
    
    context 'with valid token' do
      it 'deletes the patient' do
        expect {
          delete "/api/v1/admin/patients/#{patient.id}", headers: auth_headers
        }.to change(Patient, :count).by(-1)
        
        expect(response).to have_http_status(:no_content)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          delete "/api/v1/admin/patients/#{patient.id}", headers: auth_headers
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#destroy')
        expect(log.admin_id).to eq(admin.id)
      end
    end
  end
  
  describe 'GET /api/v1/admin/patients/:id/surveys' do
    let!(:patient) { create(:patient) }
    let!(:surveys) { create_list(:survey, 3, patient: patient) }
    
    context 'with valid token' do
      before do
        setup_request_authentication(admin)
      end

      after do
        cleanup_request_authentication
      end
      
      it 'returns the patient\'s surveys' do
        get "/api/v1/admin/patients/#{patient.id}/surveys", headers: auth_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['surveys'].length).to eq(3)
      end
      
      it 'logs the action for HIPAA compliance' do
        expect {
          get "/api/v1/admin/patients/#{patient.id}/surveys", headers: auth_headers
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('patients#surveys')
        expect(log.admin_id).to eq(admin.id)
      end
    end
  end
end
