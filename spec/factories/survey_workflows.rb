# frozen_string_literal: true

FactoryBot.define do
  factory :survey_workflow do
    name { Faker::Lorem.words(number: 2).join(' ').titleize }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    active { true }
    
    trait :inactive do
      active { false }
    end
    
    trait :with_questions do
      after(:create) do |workflow|
        questions = create_list(:question, 3)
        questions.each_with_index do |question, index|
          create(:questions_survey_workflow, 
                 survey_workflow: workflow, 
                 question: question, 
                 position: index + 1)
        end
      end
    end
  end
end
