# frozen_string_literal: true

# Service class for handling audit logging
class AuditService
  class << self
    # Enable audit logging based on environment variable
    def audit_logging_enabled?
      ENV['ENABLE_AUDIT_LOGS'] == 'true'
    end
    
    # Log an audit event
    def log_event(admin, action, auditable = nil, ip_address = nil, details = {})
      return unless audit_logging_enabled? || admin.present?
      
      AuditLog.create(
        admin: admin,
        action: action,
        auditable: auditable,
        ip_address: ip_address || '127.0.0.1',
        details: details || {}
      )
    end
  end
end
