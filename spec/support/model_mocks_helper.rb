# frozen_string_literal: true

# Helper module for mocking models in tests
module ModelMocksHelper
  # Setup mocks for Survey model
  def mock_survey_model
    survey_class = class_double('Survey').as_stubbed_const
    allow(survey_class).to receive(:count).and_return(3)
    allow(survey_class).to receive(:analytics).and_return({
      count: 3,
      average_feeling: 4.0,
      average_stress_level: 2.5,
      average_sleep_hours: 7.2
    })
    allow(survey_class).to receive(:group_by_workflow).and_return([
      { workflow_name: 'Test Workflow', count: 1 },
      { workflow_name: 'No Workflow', count: 1 }
    ])
    survey_class
  end
  
  # Setup mocks for Patient model
  def mock_patient_model
    patient_class = class_double('Patient').as_stubbed_const
    allow(patient_class).to receive(:count).and_return(2)
    allow(patient_class).to receive(:gender_distribution).and_return({
      'male' => 1,
      'female' => 1,
      'other' => 0,
      'prefer_not_to_say' => 0
    })
    allow(patient_class).to receive(:age_groups).and_return({
      '18-24' => 1,
      '25-34' => 1,
      '35-44' => 0,
      '45-54' => 0,
      '55+' => 0
    })
    allow(patient_class).to receive(:status_distribution).and_return({
      'active' => 2,
      'inactive' => 0
    })
    allow(patient_class).to receive(:survey_completion).and_return({
      'completed' => 1,
      'not_completed' => 1
    })
    patient_class
  end
  
  # Setup mocks for Question model
  def mock_question_model
    question_class = class_double('Question').as_stubbed_const
    allow(question_class).to receive(:count).and_return(2)
    question_class
  end
  
  # Setup mocks for SurveyWorkflow model
  def mock_survey_workflow_model
    workflow_class = class_double('SurveyWorkflow').as_stubbed_const
    allow(workflow_class).to receive(:count).and_return(1)
    workflow_class
  end
  
  # Setup mocks for Admin model
  def mock_admin_model
    admin_class = class_double('Admin').as_stubbed_const
    allow(admin_class).to receive(:super_admins).and_return([])
    admin_class
  end
end

RSpec.configure do |config|
  config.include ModelMocksHelper
end
