class QuestionSerializer
  include JSONAPI::Serializer
  
  attributes :id, :content, :response_type, :options, :required, :position, :created_at, :updated_at
  
  has_many :survey_workflows
end
