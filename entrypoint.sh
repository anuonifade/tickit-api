#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready
until nc -z -v -w30 db 5432
do
  echo "Waiting for PostgreSQL database connection..."
  sleep 5
done
echo "Database is ready!"

# Directly patch the ActiveSupport logger file if it exists
LOGGER_FILE=$(find /usr/local/bundle -name logger_thread_safe_level.rb)
if [ -n "$LOGGER_FILE" ]; then
  echo "Patching ActiveSupport logger at $LOGGER_FILE"
  # Add require logger at the top of the file
  grep -q "require 'logger'" "$LOGGER_FILE" || sed -i '1s/^/require "logger"\n/' "$LOGGER_FILE"
  # Add Logger constant definition
  grep -q "Logger = ::Logger" "$LOGGER_FILE" || sed -i '/module LoggerThreadSafeLevel/a\  Logger = ::Logger unless defined?(Logger)' "$LOGGER_FILE"
fi

# Create initializer as a backup approach
mkdir -p /app/config/initializers
cat > /app/config/initializers/logger_fix.rb << 'EOL'
# Fix for uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger error
require 'logger'

module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger unless defined?(Logger)
  end
end
EOL

# If the database exists, migrate. Otherwise, setup (create and migrate)
bundle exec rails db:migrate 2>/dev/null || bundle exec rails db:setup

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"
