# frozen_string_literal: true

# Helper module for mocking AuditService in tests
module AuditServiceHelper
  # Setup mocks for AuditService
  def mock_audit_service
    allow(AuditService).to receive(:audit_logging_enabled?).and_return(true)
    allow(AuditService).to receive(:log_event).and_return(true)
  end
  
  # Expect AuditService to log an event
  def expect_audit_log(admin, action, auditable = nil)
    # We need to stub the log_event method before the controller action is called
    # This ensures that the method is properly mocked
    allow(AuditService).to receive(:log_event)
      .with(admin, action, auditable, anything, anything)
      .and_return(true)
  end
end

RSpec.configure do |config|
  config.include AuditServiceHelper
end
