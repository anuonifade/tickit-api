class SurveyResponseSerializer
  include JSONAPI::Serializer
  
  attributes :id, :created_at, :updated_at, :flagged, :flagged_reason
  
  has_many :responses
  belongs_to :survey_workflow, if: proc { |record| record.survey_workflow.present? }
  
  attribute :response_count do |survey|
    survey.responses.count
  end
  
  attribute :workflow_name do |survey|
    survey.survey_workflow&.name
  end
end
