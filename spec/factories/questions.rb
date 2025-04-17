# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    content { Faker::Lorem.question }
    required { true }
    
    trait :numeric_scale do
      response_type { 'numeric_scale' }
      options { { min: 1, max: 10, min_label: 'Very Poor', max_label: 'Excellent' } }
    end
    
    trait :yes_no do
      response_type { 'yes_no' }
      options { {} }
    end
    
    trait :multiple_choice do
      response_type { 'multiple_choice' }
      options { { choices: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'] } }
    end
    
    trait :text do
      response_type { 'text' }
      options { { max_length: 500 } }
    end
    
    # Default to numeric_scale if no trait is specified
    after(:build) do |question|
      if question.response_type.blank?
        question.response_type = 'numeric_scale'
        question.options = { min: 1, max: 10, min_label: 'Very Poor', max_label: 'Excellent' }
      end
    end
  end
end
