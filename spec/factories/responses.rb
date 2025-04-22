# frozen_string_literal: true

FactoryBot.define do
  factory :response do
    text_value { Faker::Lorem.sentence }
    numeric_value { rand(1..10) }
    
    association :survey, factory: :survey, strategy: :build
    association :question, factory: :question, strategy: :build
    
    trait :numeric do
      text_value { nil }
      numeric_value { rand(1..10) }
    end
    
    trait :text do
      text_value { Faker::Lorem.paragraph }
      numeric_value { nil }
    end
    
    trait :yes_no do
      text_value { ['Yes', 'No'].sample }
      numeric_value { nil }
    end
  end
end
