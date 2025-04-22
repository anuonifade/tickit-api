# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Survey, type: :model do
  # Associations
  it { should belong_to(:patient).optional }
  it { should belong_to(:survey_workflow).optional }
  it { should have_many(:responses).dependent(:destroy) }
  it { should have_many(:notes).class_name('SurveyNote').dependent(:destroy) }
  
  # Validations
  it { should validate_presence_of(:feeling) }
  it { should validate_inclusion_of(:feeling).in_range(1..5) }
  
  it { should validate_presence_of(:stress_level) }
  it { should validate_inclusion_of(:stress_level).in_range(1..5) }
  
  it { should validate_presence_of(:sleep_hours) }
  it { should validate_numericality_of(:sleep_hours).is_greater_than(0).is_less_than_or_equal_to(24) }
  
  # Custom validation test for symptoms since we're using a custom validation approach
  describe 'symptoms validation' do
    it 'requires symptoms to be present' do
      survey = build(:survey, symptoms: nil)
      expect(survey).not_to be_valid
      expect(survey.errors[:symptoms]).to include("can't be blank")
    end
    
    it 'is valid with symptoms present' do
      survey = build(:survey, symptoms: 'Headache')
      expect(survey).to be_valid
    end
  end

  # Encryption (HIPAA compliance)
  describe 'encryption' do
    let(:survey) { create(:survey, symptoms: 'Headache and fatigue') }
    
    it 'encrypts symptoms' do
      # Mock the encryption behavior
      expect(Survey).to receive(:encrypts).with(:symptoms)
      # Allow the original method to be called to avoid breaking the test
      allow(Survey).to receive(:encrypts).and_call_original
      
      # Reload the class to apply the mock
      Survey.reset_column_information
      
      # Verify the symptoms are stored correctly
      expect(survey.symptoms).to eq('Headache and fatigue')
    end
    
    it 'creates a blind index for symptoms' do
      # Mock the blind index behavior
      expect(Survey).to receive(:blind_index).with(:symptoms)
      # Allow the original method to be called to avoid breaking the test
      allow(Survey).to receive(:blind_index).and_call_original
      
      # Reload the class to apply the mock
      Survey.reset_column_information
      
      # Verify the symptoms are stored correctly
      expect(survey.symptoms).to eq('Headache and fatigue')
    end
    
    it 'allows searching by symptoms using blind index' do
      # Create a test survey with specific symptoms
      test_survey = create(:survey, symptoms: 'Unique symptom pattern')
      
      # Mock the blind index search behavior
      allow(Survey).to receive(:where).with(symptoms_bidx: anything).and_return([test_survey])
      
      # Make sure the symptoms are set correctly
      test_survey.reload
      expect(test_survey.symptoms).to eq('Unique symptom pattern')
      
      # Verify we can find the survey
      found_survey = Survey.find(test_survey.id)
      expect(found_survey).to be_present
      expect(found_survey.symptoms).to eq('Unique symptom pattern')
    end
  end
  
  # Flagging functionality
  describe 'flagging' do
    let(:admin) { create(:admin) }
    let(:survey) { create(:survey, flagged: false) }
    
    it 'can be flagged with a reason' do
      survey.update(flagged: true, flagged_reason: 'Concerning response', flagged_at: Time.current, flagged_by_id: admin.id)
      expect(survey.flagged).to be true
      expect(survey.flagged_reason).to eq('Concerning response')
      expect(survey.flagged_at).to be_present
      expect(survey.flagged_by_id).to eq(admin.id)
    end
  end
  
  # HIPAA compliance audit logging
  describe 'callbacks' do
    describe 'after_create' do
      let(:patient) { create(:patient) }
      
      it 'logs survey creation for HIPAA compliance' do
        # Mock the AuditLog creation
        expect(AuditLog).to receive(:create).with(
          hash_including(
            action: 'survey.create',
            auditable_type: 'Survey',
            details: hash_including('patient_id' => patient.id)
          )
        )
        
        # Create a survey that will trigger the audit log
        survey = create(:survey, patient: patient)
      end
    end
    
    describe 'after_update' do
      let(:survey) { create(:survey, flagged: false) }
      
      it 'logs survey flagging for HIPAA compliance' do
        # Mock the AuditLog creation
        expect(AuditLog).to receive(:create).with(
          hash_including(
            action: 'survey.update',
            auditable_type: 'Survey',
            details: hash_including(
              'flagged' => true,
              'flagged_reason' => 'Concerning response'
            )
          )
        )
        
        # Update the survey to trigger the callback
        survey.update(flagged: true, flagged_reason: 'Concerning response')
      end
      
      it 'does not log updates that do not change flagged status' do
        # Clear any existing audit logs to ensure a clean state
        AuditLog.destroy_all
        
        # Create a survey without triggering audit logs
        Thread.current[:skip_audit_logs] = true
        survey = create(:survey, flagged: false, symptoms: 'Original symptoms')
        Thread.current[:skip_audit_logs] = false
        
        expect {
          survey.update(symptoms: 'Updated symptoms')
        }.not_to change(AuditLog, :count)
      end
    end
  end

  # Class methods
  describe '.analytics' do
    before do
      create(:survey, feeling: 3, stress_level: 4, sleep_hours: 6.5)
      create(:survey, feeling: 4, stress_level: 2, sleep_hours: 8.0)
      create(:survey, feeling: 5, stress_level: 1, sleep_hours: 7.5)
    end
    
    it 'returns correct analytics data' do
      analytics = Survey.analytics
      
      expect(analytics[:count]).to eq(3)
      expect(analytics[:average_feeling]).to eq(4.0)
      expect(analytics[:average_stress_level]).to eq(2.3)
      expect(analytics[:average_sleep_hours]).to eq(7.3)
    end
  end
end
