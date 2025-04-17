# HIPAA-Compliant Mental Health Survey API

A secure, HIPAA-compliant Rails API for collecting and analyzing mental health survey data. This API provides endpoints for submitting survey responses and retrieving analytics while ensuring sensitive health data is properly encrypted and protected.

## Ruby Version

- Ruby 3.0.7
- Rails 7.0.8

## System Dependencies

- PostgreSQL
- Bundler

## Key Features

- Secure API endpoints for survey submission and analytics
- HIPAA-compliant encryption of sensitive health data using Lockbox (AES-GCM)
- Blind indexing for searchable encrypted fields
- Comprehensive validation for all survey fields
- Detailed error handling and logging
- Complete test suite with RSpec

## Setup and Configuration

### Database Setup

```bash
# Create and migrate the database
rails db:create db:migrate

# Seed the database with sample data (optional)
rails db:seed
```

### Environment Variables

In production, set the following environment variables:

```
LOCKBOX_MASTER_KEY=your_secure_key_here
BLIND_INDEX_MASTER_KEY=your_secure_key_here
```

## API Endpoints

### Submit a Survey Response

**POST /api/v1/surveys**

Request body:
```json
{
  "survey": {
    "feeling": 4,
    "stress_level": 3,
    "sleep_hours": 7.5,
    "symptoms": "Occasional headaches and mild anxiety"
  }
}
```

### Get Survey Analytics

**GET /api/v1/surveys/analytics**

Response:
```json
{
  "count": 42,
  "average_feeling": 3.5,
  "average_stress_level": 2.8,
  "average_sleep_hours": 6.9
}
```

## HIPAA Compliance Measures

### Data Encryption

- All sensitive health data (symptoms) is encrypted at rest using AES-GCM encryption
- Data is protected in transit using HTTPS/TLS
- Encryption keys are securely managed and not stored in the database

### Access Controls

- API endpoints implement proper authentication and authorization
- Audit logs track data access and modifications

### Data Minimization

- Only necessary information is collected
- Clear data retention policies are implemented

## Running Tests

```bash
rspec
```

## Security Testing

```bash
# Run security scanners
brakeman
bundle audit
ruby_audit
```

## Development Guidelines

- Follow Rails conventions and best practices
- Use snake_case for file names, method names, and variables
- Use CamelCase for class and module names
- Write comprehensive tests for all new features
- Run security scanners before deploying changes
