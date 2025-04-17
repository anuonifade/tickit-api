# frozen_string_literal: true

# Admin model for authentication and user management
class Admin < ApplicationRecord
  # Include default devise modules for authentication (HIPAA compliant)
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
         
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin super_admin], message: '%{value} is not a valid role' }
  
  # Scopes
  scope :active, -> { where(active: true) }
  
  # Instance methods
  def full_name
    [first_name, last_name].compact.join(' ')
  end
  
  def active?
    # Default to true if active field doesn't exist
    return true unless respond_to?(:active)
    !!active
  end
  
  # JWT token generation for API authentication
  def generate_jwt
    payload = {
      admin_id: id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
  
  # Check if admin has super admin privileges
  def super_admin?
    role == 'super_admin'
  end
end
