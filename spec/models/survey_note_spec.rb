# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SurveyNote, type: :model do
  describe 'associations' do
    it { should belong_to(:survey) }
    it { should belong_to(:admin) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe 'encryption' do
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

  describe '#admin_name' do
    context 'when admin exists' do
      let(:admin) { create(:admin, first_name: 'John', last_name: 'Doe') }
      let(:note) { create(:survey_note, admin: admin) }
      
      it 'returns the admin full name' do
        expect(note.admin_name).to eq('John Doe')
      end
    end
    
    context 'when admin does not exist' do
      let(:note) { build(:survey_note, admin: nil) }
      
      it 'returns "Unknown Admin"' do
        note.admin = nil
        expect(note.admin_name).to eq('Unknown Admin')
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      let(:admin) { create(:admin) }
      let(:survey) { create(:survey, patient: create(:patient)) }
      
      it 'logs note creation for HIPAA compliance' do
        # Clear all audit logs before the test
        AuditLog.delete_all
        
        # Create the note
        note = create(:survey_note, admin: admin, survey: survey)
        
        # Verify that a note creation audit log was created
        note_logs = AuditLog.where(action: 'survey_note.create')
        expect(note_logs.count).to eq(1)
        
        # Verify the log details
        log = note_logs.first
        expect(log.action).to eq('survey_note.create')
        expect(log.admin).to eq(admin)
        expect(log.auditable_type).to eq('SurveyNote')
      end
    end
  end
end
