# frozen_string_literal: true

# Serializer for Survey model
class SurveySerializer
  include JSONAPI::Serializer

  attributes :id, :feeling, :stress_level, :sleep_hours, :symptoms, :created_at

  attribute :created_at do |object|
    object.created_at.iso8601
  end
end
