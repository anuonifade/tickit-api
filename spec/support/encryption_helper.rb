# frozen_string_literal: true

# Set up encryption keys for testing
module EncryptionHelper
  # Configure BlindIndex for testing
  def setup_blind_index_master_key
    BlindIndex.master_key = 'test_master_key_that_is_32_bytes_!' # 32-byte test key
  end
end

RSpec.configure do |config|
  config.include EncryptionHelper
  
  config.before(:suite) do
    # Set up encryption keys for the entire test suite
    BlindIndex.master_key = 'test_master_key_that_is_32_bytes_!'
  end
end
