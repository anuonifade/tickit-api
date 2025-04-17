# frozen_string_literal: true

# Serializer for AuditLog model
class AuditLogSerializer
  include JSONAPI::Serializer
  
  attributes :id, :action, :ip_address, :details, :created_at, :updated_at
  
  attribute :admin do |audit_log|
    {
      id: audit_log.admin&.id,
      email: audit_log.admin&.email,
      name: audit_log.admin&.full_name
    }
  end
  
  attribute :auditable do |audit_log|
    if audit_log.auditable
      {
        id: audit_log.auditable_id,
        type: audit_log.auditable_type
      }
    else
      nil
    end
  end
  
  attribute :formatted_date do |audit_log|
    audit_log.created_at.strftime('%Y-%m-%d %H:%M:%S')
  end
end
