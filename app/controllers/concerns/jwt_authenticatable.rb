# frozen_string_literal: true

# Concern for JWT authentication in admin controllers
module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin_from_token!
  end

  private

  def authenticate_admin_from_token!
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    begin
      decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
      @current_admin = ::Admin.find(decoded['admin_id'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Unauthorized access' }, status: :unauthorized
    end
  end

  def current_admin
    @current_admin
  end

  def admin_signed_in?
    @current_admin.present?
  end

  def authenticate_admin!
    render json: { error: 'Unauthorized access' }, status: :unauthorized unless admin_signed_in?
  end
end
