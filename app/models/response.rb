class Response < ApplicationRecord
  # Associations
  belongs_to :survey
  belongs_to :question
  
  # Encrypt sensitive health data
  encrypts :text_value
  encrypts :numeric_value
  
  # Validations
  validates :question_id, presence: true
  validate :validate_response_type
  
  # Scopes
  scope :by_question, ->(question_id) { where(question_id: question_id) }
  scope :by_question_type, ->(type) { joins(:question).where(questions: { response_type: type }) }
  
  private
  
  def validate_response_type
    return unless question
    
    case question.response_type
    when 'numeric_scale'
      errors.add(:numeric_value, "can't be blank for numeric scale questions") if numeric_value.nil?
    when 'text'
      errors.add(:text_value, "can't be blank for text questions") if text_value.blank?
    when 'multiple_choice', 'yes_no'
      errors.add(:text_value, "can't be blank for choice questions") if text_value.blank?
    end
  end
end
