# frozen_string_literal: true

# Configure BlindIndex for searchable encrypted fields
# This is used for HIPAA-compliant searchable encryption

# Keys must be exactly 32 bytes (64 hex characters)
dev_key = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'

# Set the master key based on environment
if Rails.env.test?
  BlindIndex.master_key = dev_key
else
  BlindIndex.master_key = ENV['BLIND_INDEX_MASTER_KEY'].presence || dev_key
end
