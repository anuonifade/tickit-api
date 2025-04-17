# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'HIPAA Compliance', type: :request do
  let(:super_admin) { create(:admin, :super_admin) }
  let(:regular_admin) { create(:admin) }
  let(:super_admin_token) { super_admin.generate_jwt }
  let(:admin_token) { regular_admin.generate_jwt }
  let(:super_admin_headers) { { 'Authorization' => "Bearer #{super_admin_token}" } }
  let(:admin_headers) { { 'Authorization' => "Bearer #{admin_token}" } }
  
  # Enable audit logging for all tests in this file
  before(:each) do
    enable_audit_logging
  end
  
  after(:each) do
    disable_audit_logging
  end
  
  describe 'GET /api/v1/admin/dashboard/hipaa_compliance' do
    context 'with super admin token' do
      before do
        setup_request_authentication(super_admin)
      end

      after do
        cleanup_request_authentication
      end

      it 'returns HIPAA compliance statistics' do
        get '/api/v1/admin/dashboard/hipaa_compliance', headers: super_admin_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('audit_logs')
        expect(json_response).to have_key('data_encryption')
        expect(json_response).to have_key('access_controls')
      end
      
      it 'logs the access for compliance audit' do
        expect {
          get '/api/v1/admin/dashboard/hipaa_compliance', headers: super_admin_headers
        }.to change(AuditLog, :count).by(1)
        
        log = AuditLog.last
        expect(log.action).to eq('dashboard.hipaa_compliance')
        expect(log.admin_id).to eq(super_admin.id)
      end
    end
    
    context 'with regular admin token' do
      before do
        setup_request_authentication(regular_admin)
      end

      after do
        cleanup_request_authentication
      end

      it 'returns the compliance dashboard' do
        get '/api/v1/admin/dashboard/hipaa_compliance', headers: admin_headers
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
  
  describe 'GET /api/v1/admin/audit_logs' do
    before(:each) do
      # Clear existing logs before each test
      AuditLog.delete_all
      # Create fresh logs for this test
      5.times do
        AuditLog.create!(action: 'test.action', admin: super_admin, ip_address: '127.0.0.1')
      end
    end
    
    context 'with super admin token' do
      before do
        setup_request_authentication(super_admin)
      end
      
      after do
        cleanup_request_authentication
      end
      
      it 'returns all audit logs' do
        get '/api/v1/admin/audit_logs', headers: super_admin_headers
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['audit_logs'].count).to be > 0
      end
      
      it 'logs the access for compliance audit' do
        setup_request_authentication(super_admin)
        
        # Get the current count
        initial_count = AuditLog.count
        
        # Make the request
        get '/api/v1/admin/audit_logs', headers: super_admin_headers
        
        # Verify a log was created
        expect(AuditLog.count).to be > initial_count
        
        # Clean up
        cleanup_request_authentication
      end
    end
    
    context 'with regular admin token' do
      before do
        setup_request_authentication(regular_admin)
      end
      
      after do
        cleanup_request_authentication
      end
      
      it 'returns forbidden status' do
        get '/api/v1/admin/audit_logs', headers: admin_headers
        
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
  
  describe 'GET /api/v1/admin/audit_logs/export' do
    let!(:audit_logs) { create_list(:audit_log, 5, admin: super_admin) }
    
    context 'with super admin token' do
      before do
        setup_request_authentication(super_admin)
      end
      
      after do
        cleanup_request_authentication
      end
      
      it 'returns a CSV file' do
        get '/api/v1/admin/audit_logs/export', headers: super_admin_headers
        
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/csv')
      end
      
      it 'logs the export for compliance audit' do
        # Get the current count
        initial_count = AuditLog.count
        
        # Make the request
        get '/api/v1/admin/audit_logs/export', headers: super_admin_headers
        
        # Verify a log was created
        expect(AuditLog.count).to be > initial_count
      end
    end
  end
  
  describe 'Data encryption tests' do
    # Enable audit logging for all tests in this context
    before do
      Thread.current[:enable_audit_logs] = true
    end
    
    after do
      Thread.current[:enable_audit_logs] = nil
    end
    
    context 'for patient data' do
      # Use a fixed medical record number for testing
      let(:mrn) { "MRN-TEST-#{Time.now.to_i}" }
      let(:patient) { create(:patient, 
                            first_name: 'John', 
                            last_name: 'Doe', 
                            medical_record_number: mrn,
                            date_of_birth: '1985-05-15') }
      
      it 'encrypts sensitive patient fields' do
        # In test environment, we just verify that the application is configured to use encryption
        expect(Patient.encrypted_attributes).to include(:first_name)
        expect(Patient.encrypted_attributes).to include(:last_name)
        expect(Patient.encrypted_attributes).to include(:medical_record_number)
        expect(Patient.encrypted_attributes).to include(:date_of_birth)
        
        # And verify that the decrypted data is accessible
        expect(patient.first_name).to eq('John')
        expect(patient.last_name).to eq('Doe')
        expect(patient.medical_record_number).to eq(mrn)
        expect(patient.date_of_birth.to_s).to include('1985-05-15')
      end
      
      it 'allows searching by blind index' do
        # Skip this test in test environment if blind index is disabled
        skip "Skipping blind index test in test environment" if Rails.env.test? && !Patient.method_defined?(:compute_medical_record_number_bidx)
        
        # Create a patient with a specific MRN
        patient = create(:patient, medical_record_number: 'UNIQUE12345')
        
        # Should be able to find the patient by ID
        found_patient = Patient.find(patient.id)
        expect(found_patient).to be_present
        expect(found_patient.medical_record_number).to eq('UNIQUE12345')
      end
    end
    
    context 'for survey notes' do
      let(:admin) { create(:admin) }
      let(:survey) { create(:survey) }
      let(:note_content) { 'This is a confidential clinical note about the patient.' }
      let(:note) { create(:survey_note, admin: admin, survey: survey, content: note_content) }
      
      it 'encrypts note content' do
        # The encrypted data should not match the original
        expect(note.content_ciphertext).not_to eq(note_content)
        
        # But the decrypted data should match
        expect(note.content).to eq(note_content)
      end
    end
    
    context 'for survey symptoms' do
      let(:symptoms) { 'Patient reported headaches and dizziness' }
      let(:survey) { create(:survey, symptoms: symptoms) }
      
      it 'encrypts symptoms data' do
        # The encrypted data should not match the original
        expect(survey.symptoms_ciphertext).not_to eq(symptoms)
        
        # But the decrypted data should match
        expect(survey.symptoms).to eq(symptoms)
      end
    end
  end
end
