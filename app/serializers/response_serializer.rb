class ResponseSerializer
  include JSONAPI::Serializer
  
  attributes :id, :text_value, :numeric_value, :created_at, :updated_at
  
  # Define relationships with explicit serializers
  belongs_to :question
  belongs_to :survey
  
  # Include question data directly in the response for convenience
  attribute :question_content do |response|
    response.question&.content
  end
  
  attribute :question_type do |response|
    response.question&.response_type
  end
  
  # Format the value based on the question type
  attribute :formatted_value do |response|
    case response.question&.response_type
    when 'numeric_scale'
      response.numeric_value&.to_s
    when 'text', 'multiple_choice', 'yes_no'
      response.text_value
    else
      nil
    end
  end
end
