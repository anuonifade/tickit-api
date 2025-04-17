class SurveyWorkflowSerializer
  include JSONAPI::Serializer
  
  attributes :id, :name, :description, :active, :created_at, :updated_at
  
  has_many :questions
  
  attribute :question_count do |workflow|
    workflow.questions.count
  end
end
