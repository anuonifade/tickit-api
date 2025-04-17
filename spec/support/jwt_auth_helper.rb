# frozen_string_literal: true

# Helper module for JWT authentication in tests
module JwtAuthHelper
  # Generate headers with JWT token for the given admin
  def auth_headers(admin)
    token = admin.generate_jwt
    { 'Authorization' => "Bearer #{token}" }
  end
  
  # Setup controller for authenticated tests
  def authenticate_admin(admin)
    # Bypass the token check
    allow(controller).to receive(:authenticate_admin_from_token!).and_return(true)
    allow(controller).to receive(:current_admin).and_return(admin)
    allow(controller).to receive(:admin_signed_in?).and_return(true)
    
    # Enable audit logging for this test
    Thread.current[:enable_audit_logs] = true
    
    # Clear audit logs before this test
    Thread.current[:clear_audit_logs_before_test] = true
    AuditLog.delete_all
  end
  
  # Setup controller for unauthenticated tests
  def unauthenticate_admin
    # Don't bypass the token check for unauthenticated tests
    allow(controller).to receive(:authenticate_admin_from_token!).and_call_original
    allow(controller).to receive(:current_admin).and_return(nil)
    allow(controller).to receive(:admin_signed_in?).and_return(false)
    
    # Disable audit logging for this test
    Thread.current[:enable_audit_logs] = false
  end
end

RSpec.configure do |config|
  config.include JwtAuthHelper, type: :controller
  config.include JwtAuthHelper, type: :request
end
