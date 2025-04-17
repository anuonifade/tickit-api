class AdminSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :first_name, :last_name, :role, :created_at, :updated_at
  
  attribute :full_name do |admin|
    [admin.first_name, admin.last_name].compact.join(' ')
  end
  
  # Don't include sensitive information like password
end
