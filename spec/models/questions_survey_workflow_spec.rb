# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionsSurveyWorkflow, type: :model do
  describe 'associations' do
    it { should belong_to(:question) }
    it { should belong_to(:survey_workflow) }
  end

  describe 'validations' do
    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than(0) }
    
    describe 'uniqueness of position within a workflow' do
      subject { create(:questions_survey_workflow) }
      it { should validate_uniqueness_of(:position).scoped_to(:survey_workflow_id) }
    end
  end

  describe 'callbacks' do
    describe 'before_validation on create' do
      context 'when position is not specified' do
        let(:workflow) { create(:survey_workflow) }
        let!(:existing_question) { create(:questions_survey_workflow, survey_workflow: workflow, position: 1) }
        
        it 'sets position to the next available position' do
          new_join = build(:questions_survey_workflow, survey_workflow: workflow, position: nil)
          expect(new_join).to be_valid
          expect(new_join.position).to eq(2)
        end
      end
      
      context 'when there are no existing questions' do
        let(:workflow) { create(:survey_workflow) }
        
        it 'sets position to 1' do
          new_join = build(:questions_survey_workflow, survey_workflow: workflow, position: nil)
          expect(new_join).to be_valid
          expect(new_join.position).to eq(1)
        end
      end
      
      context 'when position is already specified' do
        let(:workflow) { create(:survey_workflow) }
        
        it 'does not change the position' do
          new_join = build(:questions_survey_workflow, survey_workflow: workflow, position: 5)
          expect(new_join).to be_valid
          expect(new_join.position).to eq(5)
        end
      end
    end
  end
end
