source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use the Nokogiri version that's already installed in the container
gem "nokogiri", "~> 1.17.0"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

# Pagination
gem "kaminari", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  # Testing framework
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails", "~> 6.2"
  gem "faker", "~> 3.2"
  gem "shoulda-matchers", "~> 5.3"
  gem "database_cleaner-active_record", "~> 2.1"

  # Security scanning
  gem "brakeman", "~> 6.0"
  gem "bundler-audit", "~> 0.9.1"
  gem "ruby_audit", "~> 2.2"
  gem "strong_migrations", "~> 1.6"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "annotate", "~> 3.2"
  gem "rubocop", "~> 1.57", require: false
  gem "rubocop-rails", "~> 2.22", require: false
  gem "rubocop-rspec", "~> 2.25", require: false
end

# For encryption of sensitive data
gem "lockbox", "~> 1.3"
gem "blind_index", "~> 2.4"

# For API authentication
gem "jwt", "~> 2.7"

gem "devise"

# For API documentation
gem "rswag", "~> 2.11"

# For pagination
gem "pagy", "~> 6.1"

# For JSON serialization
gem "jsonapi-serializer", "~> 2.2"
