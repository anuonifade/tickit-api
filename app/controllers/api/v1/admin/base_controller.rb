# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Base controller for all admin API endpoints
      class BaseController < ActionController::API
        include JwtAuthenticatable
        
        before_action :log_admin_action
        
        rescue_from ActiveRecord::RecordNotFound, with: :not_found
        rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
        rescue_from ActionController::ParameterMissing, with: :parameter_missing
        
        private
        
        # Log admin actions for HIPAA compliance audit trail
        def log_admin_action
          # Skip logging if not signed in and audit logging is not enabled
          return unless admin_signed_in? || AuditService.audit_logging_enabled?
          
          # Extract the relevant information for the audit log
          action = "#{controller_name}##{action_name}"
          ip_address = request.remote_ip
          details = {
            params: filtered_params,
            user_agent: request.user_agent,
            referer: request.referer
          }
          
          # Create the audit log entry using the AuditService
          AuditService.log_event(current_admin, action, nil, ip_address, details)
        end
        
        # Filter sensitive parameters for the audit log
        def filtered_params
          # Handle ActionController::Parameters in test environment
          begin
            params.to_unsafe_h.except('password', 'password_confirmation')
          rescue
            # In test environment, params might not be convertible to hash
            params.permit!.to_h.except('password', 'password_confirmation')
          end
        end
        
        def not_found
          render json: { error: 'Resource not found' }, status: :not_found
        end
        
        def unprocessable_entity(exception)
          render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
        end
        
        def parameter_missing(exception)
          render json: { error: exception.message }, status: :bad_request
        end
      end
    end
  end
end
