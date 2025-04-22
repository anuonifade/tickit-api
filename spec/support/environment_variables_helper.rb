# frozen_string_literal: true

# Helper module for setting environment variables in tests
module EnvironmentVariablesHelper
  # Set environment variables for testing
  def with_env_vars(vars)
    original = {}
    vars.each do |key, value|
      original[key] = ENV[key]
      ENV[key] = value
    end

    yield
  ensure
    vars.each do |key, _value|
      ENV[key] = original[key]
    end
  end

  # Enable audit logging for tests
  def with_audit_logging
    with_env_vars('ENABLE_AUDIT_LOGS' => 'true') do
      yield
    end
  end

  # Set encryption keys for tests
  def with_encryption_keys
    with_env_vars(
      'LOCKBOX_MASTER_KEY' => '0000000000000000000000000000000000000000000000000000000000000000',
      'BLIND_INDEX_MASTER_KEY' => '0000000000000000000000000000000000000000000000000000000000000000'
    ) do
      yield
    end
  end
end

RSpec.configure do |config|
  config.include EnvironmentVariablesHelper
end
