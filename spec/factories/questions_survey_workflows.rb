# frozen_string_literal: true

FactoryBot.define do
  factory :questions_survey_workflow do
    position { 1 }
    
    association :question, factory: :question, strategy: :build
    association :survey_workflow, factory: :survey_workflow, strategy: :build
  end
end
