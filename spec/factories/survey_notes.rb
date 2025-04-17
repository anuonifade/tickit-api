# frozen_string_literal: true

FactoryBot.define do
  factory :survey_note do
    content { Faker::Lorem.paragraph(sentence_count: 2) }
    
    association :survey, factory: :survey, strategy: :build
    association :admin, factory: :admin, strategy: :build
  end
end
