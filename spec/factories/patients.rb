# frozen_string_literal: true

FactoryBot.define do
  factory :patient do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    gender { ['male', 'female', 'non-binary', 'prefer not to say'].sample }
    sequence(:medical_record_number) { |n| "MRN#{Time.now.to_i}-#{n}-#{SecureRandom.hex(4)}" }
    status { 'active' }
    
    trait :inactive do
      status { 'inactive' }
    end
    
    trait :with_surveys do
      after(:create) do |patient|
        create_list(:survey, 2, patient: patient)
      end
    end
  end
end
