class QuestionTemplate < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :response_type, presence: true, inclusion: { 
    in: %w(text numeric_scale multiple_choice yes_no), 
    message: "%{value} is not a valid response type" 
  }
  validates :category, presence: true
  
  # Scopes
  scope :by_category, ->(category) { where(category: category) }
  scope :by_response_type, ->(type) { where(response_type: type) }
  scope :active, -> { where(active: true) }
  
  # Instance methods
  def to_question
    Question.new(
      content: content,
      response_type: response_type,
      options: options,
      required: required,
      position: nil # Position will be set when added to a workflow
    )
  end
end
