# frozen_string_literal: true

# Helper module for audit log testing
module AuditLogHelper
  # Enable audit logs for a specific test
  def with_audit_logs
    old_value = ENV['ENABLE_TEST_AUDIT_LOGS']
    ENV['ENABLE_TEST_AUDIT_LOGS'] = 'true'
    yield
  ensure
    ENV['ENABLE_TEST_AUDIT_LOGS'] = old_value
  end
end

RSpec.configure do |config|
  config.include AuditLogHelper
end
