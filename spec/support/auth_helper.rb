# frozen_string_literal: true

# Helper module for authentication in tests
module AuthHelper
  # Generate a valid JWT token for the given admin
  def generate_auth_token(admin)
    payload = { admin_id: admin.id }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
  
  # Set up authentication headers for request specs
  def auth_headers(admin)
    token = generate_auth_token(admin)
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper
end
