# frozen_string_literal: true

# Helper module for controller tests
module ControllerHelpers
  # Setup authentication for controller tests
  def sign_in_admin(admin = nil)
    admin ||= create(:admin)
    
    # Only stub authentication methods if the controller responds to them
    # This allows us to test controllers that don't require authentication
    if controller.respond_to?(:authenticate_admin_from_token!)
      allow(controller).to receive(:authenticate_admin_from_token!).and_return(true)
    end
    
    if controller.respond_to?(:current_admin)
      allow(controller).to receive(:current_admin).and_return(admin)
    end
    
    if controller.respond_to?(:admin_signed_in?)
      allow(controller).to receive(:admin_signed_in?).and_return(true)
    end
    
    # Don't set ENV['ENABLE_TEST_AUDIT_LOGS'] here as it can cause duplicate logs
    # The controller's log_analytics_access method will handle audit logging
    
    # Return the admin for further use
    admin
  end
  
  # Create a test admin
  def create_test_admin
    Admin.find_or_create_by(email: 'test@example.com') do |admin|
      admin.password = 'password'
      admin.first_name = 'Test'
      admin.last_name = 'Admin'
      admin.role = 'admin'
    end
  end
  
  # Create a test super admin
  def create_test_super_admin
    Admin.find_or_create_by(email: 'super@example.com') do |admin|
      admin.password = 'password'
      admin.first_name = 'Super'
      admin.last_name = 'Admin'
      admin.role = 'super_admin'
    end
  end
  
  # Setup for testing unauthorized access
  def setup_unauthorized_access
    # Clear any existing admin from thread
    Thread.current[:current_admin] = nil
    # Set flag to force unauthorized response
    Thread.current[:test_unauthorized_access] = true
    
    # For controller specs
    if defined?(controller) && controller
      allow(controller).to receive(:current_admin).and_return(nil)
      allow(controller).to receive(:admin_signed_in?).and_return(false)
      allow(controller).to receive(:authenticate_admin_from_token!).and_return(false)
    end
    
    # Return nil to indicate no admin is signed in
    nil
  end
  
  # Setup authentication for request specs
  def setup_request_authentication(admin)
    # Set the current admin in thread for the test
    Thread.current[:current_admin] = admin
    Thread.current[:enable_audit_logs] = true
    # Ensure we're not in unauthorized test mode
    Thread.current[:test_unauthorized_access] = false
    # Set TEST_ADMIN_ID for JWT authentication
    ENV['TEST_ADMIN_ID'] = admin.id.to_s
  end
  
  # Clean up authentication for request specs
  def cleanup_request_authentication
    # Clean up thread variables and environment
    Thread.current[:current_admin] = nil
    Thread.current[:enable_audit_logs] = nil
    Thread.current[:test_unauthorized_access] = nil
    ENV.delete('TEST_ADMIN_ID')
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
  config.include ControllerHelpers, type: :request
  
  # Set up authentication for controller tests
  config.before(:each, type: :controller) do
    # Skip authentication for controllers that don't need it
    next if controller.class.name == 'Api::V1::SurveysController'
    
    # Create a test admin by default
    @admin = create_test_admin
    
    # Sign in the admin
    sign_in_admin(@admin)
  end
  
  # Clean up after controller tests
  config.after(:each, type: :controller) do
    # Disable audit logs after the test
    ENV['ENABLE_TEST_AUDIT_LOGS'] = nil
  end
end
