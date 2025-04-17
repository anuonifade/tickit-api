# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { 'admin' }
    
    trait :super_admin do
      role { 'super_admin' }
    end
    
    trait :with_audit_logs do
      after(:create) do |admin|
        create_list(:audit_log, 3, admin: admin)
      end
    end
  end
end
