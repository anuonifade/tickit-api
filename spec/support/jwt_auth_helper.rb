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
    
    # Set environment variables for this test
    ENV['ENABLE_AUDIT_LOGS'] = 'true'
    ENV['LOCKBOX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    ENV['BLIND_INDEX_MASTER_KEY'] = '0000000000000000000000000000000000000000000000000000000000000000'
    
    # Allow the controller to render responses
    allow(controller).to receive(:render).and_call_original
    
    # Mock database-dependent models
    mock_models
    
    # Mock AuditService
    mock_audit_service(admin)
  end
  
  # Setup controller for unauthenticated tests
  def unauthenticate_admin
    # Don't bypass the token check for unauthenticated tests
    allow(controller).to receive(:authenticate_admin_from_token!).and_call_original
    allow(controller).to receive(:current_admin).and_return(nil)
    allow(controller).to receive(:admin_signed_in?).and_return(false)
    
    # Disable audit logging for this test
    ENV['ENABLE_AUDIT_LOGS'] = nil
  end
  
  private
  
  # Mock AuditService to avoid database interactions
  def mock_audit_service(admin)
    # Create a fake audit log for testing
    fake_audit_log = double('AuditLog', 
      admin: admin,
      action: 'test.action',
      ip_address: '127.0.0.1',
      created_at: Time.now
    )
    
    # Mock AuditService class methods
    allow(AuditService).to receive(:audit_logging_enabled?).and_return(true)
    allow(AuditService).to receive(:log_event).and_return(fake_audit_log)
  end
  
  # Mock models to avoid database interactions
  def mock_models
    # Mock Survey class
    allow(Survey).to receive_message_chain(:count).and_return(3)
    allow(Survey).to receive_message_chain(:group, :count).and_return({})
    
    # Mock Patient class
    allow(Patient).to receive_message_chain(:count).and_return(2)
    allow(Patient).to receive_message_chain(:group, :count).and_return({})
    
    # Mock Question class
    allow(Question).to receive_message_chain(:count).and_return(5)
    
    # Mock SurveyWorkflow class
    allow(SurveyWorkflow).to receive_message_chain(:count).and_return(1)
    
    # Mock AuditLog class
    allow(AuditLog).to receive_message_chain(:count).and_return(10)
    allow(AuditLog).to receive_message_chain(:order, :limit).and_return([])
  end
end

RSpec.configure do |config|
  config.include JwtAuthHelper, type: :controller
  config.include JwtAuthHelper, type: :request
end
