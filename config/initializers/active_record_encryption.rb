# frozen_string_literal: true

# Configure Active Record encryption for HIPAA compliance
# This sets up the necessary encryption keys for protecting sensitive health information

Rails.application.config.active_record.encryption.configure(
  # Primary encryption key
  primary_key: ENV.fetch('ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY', 'fGCt5vPdufbz49rZ4HYlrALQNlttRwB9'),

  # Deterministic encryption key
  deterministic_key: ENV.fetch('ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY', 'nmKDKqLxqBydvQ8jv8kXepkZHUtb4vlA'),

  # Key derivation salt
  key_derivation_salt: ENV.fetch('ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT', 'fmGMKkLk1fUenaZw6T4JC3zlW1S45N8n'),

  # Support both encrypted and unencrypted data
  support_unencrypted_data: true,

  # Store the encryption context in the encrypted message
  store_key_references: true
)
