# frozen_string_literal: true

FactoryBot.define do
  factory :audit_log do
    action { ['create', 'read', 'update', 'delete', 'login', 'logout'].sample }
    ip_address { Faker::Internet.ip_v4_address }
    details { { timestamp: Time.current.to_i, browser: Faker::Internet.user_agent } }
    
    # Optional associations
    association :admin, factory: :admin, strategy: :build
    
    trait :with_auditable do
      association :auditable, factory: :patient, strategy: :build
    end
    
    trait :for_patient do
      action { 'patient.view' }
      association :auditable, factory: :patient, strategy: :build
    end
    
    trait :for_survey do
      action { 'survey.view' }
      association :auditable, factory: :survey, strategy: :build
    end
    
    trait :for_admin do
      action { 'admin.login' }
    end
  end
end
