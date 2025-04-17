# frozen_string_literal: true

# Base controller for API endpoints
class ApplicationController < ActionController::API
  # Error handling
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found
    render json: { error: 'Resource not found' }, status: :not_found
  end

  def bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
