class ResponseSerializer
  include JSONAPI::Serializer
  
  attributes :id, :text_value, :numeric_value, :created_at, :updated_at
  
  belongs_to :question
  belongs_to :survey
  
  attribute :question_content do |response|
    response.question&.content
  end
  
  attribute :question_type do |response|
    response.question&.response_type
  end
end
