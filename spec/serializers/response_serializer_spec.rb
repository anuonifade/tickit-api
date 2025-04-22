# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResponseSerializer do
  # Use doubles instead of actual database objects
  let(:numeric_question) do
    double('Question', 
      id: 1, 
      content: 'Rate your pain', 
      response_type: 'numeric_scale'
    )
  end
  
  let(:text_question) do
    double('Question', 
      id: 2, 
      content: 'Describe your symptoms', 
      response_type: 'text'
    )
  end
  
  let(:yes_no_question) do
    double('Question', 
      id: 3, 
      content: 'Are you feeling better?', 
      response_type: 'yes_no'
    )
  end
  
  let(:survey) do
    double('Survey', 
      id: 1
    )
  end
  
  let(:numeric_response) { create_mock_response(survey: survey, question: numeric_question, numeric_value: 3) }
  let(:text_response) { create_mock_response(survey: survey, question: text_question, text_value: 'Headache and fatigue') }
  let(:yes_no_response) { create_mock_response(survey: survey, question: yes_no_question, text_value: 'Yes') }

  describe 'serialization' do
    it 'includes the correct attributes for a numeric response' do
      serialized = ResponseSerializer.new(numeric_response).serializable_hash
      
      # Check that the basic attributes are included
      expect(serialized[:data][:attributes]).to include(
        :id,
        :text_value,
        :numeric_value,
        :created_at,
        :updated_at
      )
      
      # Check that the question-related attributes are included
      expect(serialized[:data][:attributes]).to include(
        :question_content,
        :question_type,
        :formatted_value
      )
      
      # Check the specific values
      expect(serialized[:data][:attributes][:question_content]).to eq('Rate your pain')
      expect(serialized[:data][:attributes][:question_type]).to eq('numeric_scale')
      expect(serialized[:data][:attributes][:numeric_value]).to eq(3)
      expect(serialized[:data][:attributes][:formatted_value]).to eq('3')
    end
    
    it 'includes the correct attributes for a text response' do
      serialized = ResponseSerializer.new(text_response).serializable_hash
      
      # Check the specific values for a text response
      expect(serialized[:data][:attributes][:question_content]).to eq('Describe your symptoms')
      expect(serialized[:data][:attributes][:question_type]).to eq('text')
      expect(serialized[:data][:attributes][:text_value]).to eq('Headache and fatigue')
      expect(serialized[:data][:attributes][:formatted_value]).to eq('Headache and fatigue')
    end
    
    it 'includes the correct attributes for a yes/no response' do
      serialized = ResponseSerializer.new(yes_no_response).serializable_hash
      
      # Check the specific values for a yes/no response
      expect(serialized[:data][:attributes][:question_content]).to eq('Are you feeling better?')
      expect(serialized[:data][:attributes][:question_type]).to eq('yes_no')
      expect(serialized[:data][:attributes][:text_value]).to eq('Yes')
      expect(serialized[:data][:attributes][:formatted_value]).to eq('Yes')
    end
    
    it 'handles missing question gracefully' do
      # Create a completely custom mock for this specific test case
      response_without_question = double('Response')
      
      # Set up all the methods needed by the serializer
      allow(response_without_question).to receive(:id).and_return(999)
      allow(response_without_question).to receive(:survey).and_return(survey)
      allow(response_without_question).to receive(:survey_id).and_return(survey.id)
      allow(response_without_question).to receive(:question).and_return(nil)
      allow(response_without_question).to receive(:question_id).and_return(nil)
      allow(response_without_question).to receive(:text_value).and_return('No question')
      allow(response_without_question).to receive(:numeric_value).and_return(nil)
      allow(response_without_question).to receive(:created_at).and_return(Time.current)
      allow(response_without_question).to receive(:updated_at).and_return(Time.current)
      
      serialized = ResponseSerializer.new(response_without_question).serializable_hash
      
      # Even with a nil question, these attributes should exist but be nil
      expect(serialized[:data][:attributes]).to include(:question_content, :question_type, :formatted_value)
      expect(serialized[:data][:attributes][:question_content]).to be_nil
      expect(serialized[:data][:attributes][:question_type]).to be_nil
      expect(serialized[:data][:attributes][:formatted_value]).to be_nil
    end
  end
end
