# frozen_string_literal: true

FactoryBot.define do
  factory :response do
    position { 1 }
    text_value { Faker::Lorem.sentence }
    numeric_value { rand(1..10) }
    boolean_value { [true, false].sample }
    
    association :survey, factory: :survey, strategy: :build
    association :question, factory: :question, strategy: :build
    
    trait :numeric do
      text_value { nil }
      numeric_value { rand(1..10) }
      boolean_value { nil }
    end
    
    trait :text do
      text_value { Faker::Lorem.paragraph }
      numeric_value { nil }
      boolean_value { nil }
    end
    
    trait :boolean do
      text_value { nil }
      numeric_value { nil }
      boolean_value { [true, false].sample }
    end
  end
end
