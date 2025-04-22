# frozen_string_literal: true

# Helper module for stubbing controller methods in tests
module ControllerTestStub
  # Stub controller methods to avoid database interactions
  def stub_controller_methods
    # Set environment variables
    ENV['LOCKBOX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['BLIND_INDEX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['ENABLE_AUDIT_LOGS'] = 'true'
    
    # Stub AuditService
    allow(AuditService).to receive(:audit_logging_enabled?).and_return(true)
    allow(AuditService).to receive(:log_event).and_return(true)
    
    # Stub controller render method to avoid actual rendering
    allow_any_instance_of(ActionController::Base).to receive(:render).and_return('{}')
    
    # Stub ActiveRecord methods to avoid database interactions
    stub_active_record_methods
  end
  
  # Stub ActiveRecord methods
  def stub_active_record_methods
    # Stub Survey model
    allow(Survey).to receive(:count).and_return(3)
    allow(Survey).to receive(:group).and_return(Survey)
    allow(Survey).to receive(:order).and_return(Survey)
    allow(Survey).to receive(:limit).and_return([])
    
    # Stub Question model
    allow(Question).to receive(:count).and_return(2)
    
    # Stub SurveyWorkflow model
    allow(SurveyWorkflow).to receive(:count).and_return(1)
    
    # Stub Patient model
    allow(Patient).to receive(:count).and_return(0)
    
    # Stub AuditLog model
    allow(AuditLog).to receive(:count).and_return(0)
    allow(AuditLog).to receive(:order).and_return(AuditLog)
    allow(AuditLog).to receive(:limit).and_return([])
  end
end

RSpec.configure do |config|
  config.include ControllerTestStub, type: :controller
  
  config.before(:each, type: :controller) do
    stub_controller_methods
  end
end
