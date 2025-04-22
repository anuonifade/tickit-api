# frozen_string_literal: true

# Helper module for controller tests
module ControllerTestHelper
  # Setup the controller for testing
  def setup_controller_test
    # Set environment variables for encryption
    ENV['LOCKBOX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['BLIND_INDEX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['ENABLE_AUDIT_LOGS'] = 'true'
    
    # Mock AuditService to avoid database interactions
    allow(AuditService).to receive(:audit_logging_enabled?).and_return(true)
    allow(AuditService).to receive(:log_event).and_return(true)
  end
end

RSpec.configure do |config|
  config.include ControllerTestHelper, type: :controller
  
  config.before(:each, type: :controller) do
    setup_controller_test
  end
end
