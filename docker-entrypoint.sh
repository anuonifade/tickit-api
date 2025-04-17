#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid
rm -f /app/tmp/pids/server.pid

# Wait for database
until nc -z -v -w30 db 5432; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done
echo "Database is ready!"

# Run migrations or setup if needed
bundle exec rails db:migrate 2>/dev/null || bundle exec rails db:create db:migrate

# Start the server
exec "$@"
