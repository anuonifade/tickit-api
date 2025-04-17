# Use an official Ruby runtime as a parent image
FROM ruby:3.2-slim

# Set environment variables
ENV RAILS_ENV=development
ENV RAILS_LOG_TO_STDOUT=true
ENV BUNDLE_PATH=/usr/local/bundle
ENV GEM_HOME=/usr/local/bundle

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    git \
    netcat-openbsd \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy only Gemfile and Gemfile.lock first
COPY Gemfile ./
COPY Gemfile.lock ./

# Install gems - this will also generate Gemfile.lock inside the image
# Add --jobs for parallel installation and --retry for robustness
RUN bundle install --jobs $(nproc) --retry 3

# Copy the main application code
COPY . .

# Make the entrypoint script executable
RUN chmod +x /app/docker-entrypoint.sh

# Define the entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# Expose port 3001 for the Rails app
EXPOSE 3001

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
