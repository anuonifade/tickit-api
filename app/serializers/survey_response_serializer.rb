class SurveyResponseSerializer
  include JSONAPI::Serializer
  
  attributes :id, :created_at, :updated_at, :flagged, :flagged_reason
  
  # Define relationships - explicitly include responses
  has_many :responses, serializer: ResponseSerializer
  belongs_to :survey_workflow, if: proc { |record| record.survey_workflow.present? }
  belongs_to :patient, if: proc { |record| record.patient.present? }
  
  # Add additional attributes
  attribute :response_count do |survey|
    survey.responses.count
  end
  
  attribute :workflow_name do |survey|
    survey.survey_workflow&.name
  end
  
  # Include patient name if admin has access
  attribute :patient_name do |survey, params|
    if survey.patient.present? && params[:admin].present?
      # In a real app, you would check admin permissions here
      "#{survey.patient.first_name} #{survey.patient.last_name}"
    else
      nil
    end
  end
  
  # Include the actual responses data directly in attributes
  attribute :response_data do |survey|
    survey.responses.map do |response|
      {
        id: response.id,
        question_id: response.question_id,
        question_content: response.question&.content,
        question_type: response.question&.response_type,
        text_value: response.text_value,
        numeric_value: response.numeric_value,
        formatted_value: format_response_value(response)
      }
    end
  end
  
  # Helper method to format response values
  def self.format_response_value(response)
    case response.question&.response_type
    when 'numeric_scale'
      response.numeric_value&.to_s
    when 'text', 'multiple_choice', 'yes_no'
      response.text_value
    else
      nil
    end
  end
  
  # Custom method to ensure responses are included
  def self.serializable_hash_with_responses(resource, options = {})
    # Add responses to the included relationships if not already present
    options[:include] ||= []
    options[:include] = [options[:include]] unless options[:include].is_a?(Array)
    options[:include] << :responses unless options[:include].include?(:responses)
    
    # Log what we're doing
    Rails.logger.info("Serializing survey response with options: #{options.inspect}")
    
    # Ensure resource is properly loaded with responses
    if resource.is_a?(Survey)
      # For a single survey, make sure responses are loaded
      Rails.logger.info("Ensuring responses are loaded for survey ##{resource.id}")
      resource.responses.to_a.each do |response|
        # Force load the question to avoid N+1 queries
        response.question
      end
    elsif resource.is_a?(Array)
      # For multiple surveys, make sure responses are loaded for each
      resource.each do |survey|
        Rails.logger.info("Ensuring responses are loaded for survey ##{survey.id}")
        survey.responses.to_a.each do |response|
          # Force load the question to avoid N+1 queries
          response.question
        end
      end
    end
    
    # Create a new instance of the serializer for the resource and return the serialized hash
    result = new(resource, options).serializable_hash
    
    # Log the result structure
    Rails.logger.info("Serialized result keys: #{result.keys.inspect}")
    if result[:data].is_a?(Hash)
      Rails.logger.info("Data attributes keys: #{result[:data][:attributes].keys.inspect}")
      Rails.logger.info("Response data count: #{result[:data][:attributes][:response_data].size}")
    end
    
    result
  end
end
