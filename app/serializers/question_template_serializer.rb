class QuestionTemplateSerializer
  include JSONAPI::Serializer
  
  attributes :id, :title, :content, :response_type, :category, :options, :required, :active, :created_at, :updated_at
end
