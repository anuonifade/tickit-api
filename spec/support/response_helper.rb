# frozen_string_literal: true

# Helper module for creating mock responses in tests
module ResponseHelper
  # Create a mock response object for testing serializers
  def create_mock_response(survey:, question:, text_value: nil, numeric_value: nil)
    response = double('Response')
    
    # Set up all the methods needed by the serializer
    allow(response).to receive(:id).and_return(rand(1..1000))
    allow(response).to receive(:survey).and_return(survey)
    allow(response).to receive(:survey_id).and_return(survey.id)
    allow(response).to receive(:question).and_return(question)
    allow(response).to receive(:question_id).and_return(question.id)
    allow(response).to receive(:text_value).and_return(text_value)
    allow(response).to receive(:numeric_value).and_return(numeric_value)
    allow(response).to receive(:created_at).and_return(Time.current)
    allow(response).to receive(:updated_at).and_return(Time.current)
    
    response
  end
end

RSpec.configure do |config|
  config.include ResponseHelper
end
