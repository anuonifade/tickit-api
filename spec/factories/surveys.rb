# frozen_string_literal: true

FactoryBot.define do
  factory :survey do
    feeling { 4 }
    stress_level { 3 }
    sleep_hours { 7.5 }
    symptoms { 'Mild headache' }
    flagged { false }
    
    # Make associations optional for basic testing
    patient { nil }
    survey_workflow { nil }
    
    trait :flagged do
      flagged { true }
      flagged_reason { Faker::Lorem.sentence }
      flagged_at { Time.current }
      association :flagged_by, factory: :admin
    end
    
    trait :with_responses do
      after(:create) do |survey|
        create_list(:response, 3, survey: survey)
      end
    end
    
    trait :with_notes do
      after(:create) do |survey|
        create_list(:survey_note, 2, survey: survey)
      end
    end
  end
end
