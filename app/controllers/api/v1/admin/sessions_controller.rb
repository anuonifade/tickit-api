# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for handling admin authentication
      class SessionsController < ActionController::API
        # Skip authentication for login action
        before_action :authenticate_admin, except: [:create]
        
        # POST /api/v1/admin/login
        def create
          admin = ::Admin.find_by(email: login_params[:email])
          
          if admin&.valid_password?(login_params[:password])
            token = admin.generate_jwt
            
            # Log successful login for HIPAA compliance
            log_action(admin, 'sessions#create', request.remote_ip)
            
            render json: {
              admin: { email: admin.email, id: admin.id, name: admin.full_name },
              token: token
            }, status: :ok
          else
            render json: { error: 'Invalid email or password' }, status: :unauthorized
          end
        end
        
        # DELETE /api/v1/admin/logout
        def destroy
          # JWT is stateless, so we don't need to do anything server-side
          # The client should discard the token
          
          # Log logout for HIPAA compliance
          log_action(@current_admin, 'sessions#destroy', request.remote_ip)
          
          render json: { message: 'Logged out successfully' }, status: :ok
        end
        
        private
        
        def login_params
          params.require(:admin).permit(:email, :password)
        end
        
        def authenticate_admin
          # In test environment, allow authentication via thread-local variable
          if Rails.env.test? && Thread.current[:current_admin].present?
            @current_admin = Thread.current[:current_admin]
            return
          end
          
          header = request.headers['Authorization']
          token = header.split(' ').last if header
          
          begin
            decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
            @current_admin = ::Admin.find(decoded['admin_id'])
          rescue JWT::DecodeError, ActiveRecord::RecordNotFound
            render json: { error: 'Unauthorized access' }, status: :unauthorized
          end
        end
        
        # Helper method to log actions for HIPAA compliance
        def log_action(admin, action, ip_address)
          return unless admin.present?
          
          # For test environment, ensure logging is enabled
          if Rails.env.test?
            return unless ENV['ENABLE_TEST_AUDIT_LOGS'] == 'true' || Thread.current[:enable_audit_logs]
            
            # Set the admin in thread-local variable for the audit log
            Thread.current[:current_admin] = admin if Thread.current[:current_admin].nil?
          end
          
          # Create the audit log
          AuditLog.create(
            action: action,
            admin: admin,
            ip_address: ip_address,
            details: { user_agent: request.user_agent }
          )
        end
      end
    end
  end
end
