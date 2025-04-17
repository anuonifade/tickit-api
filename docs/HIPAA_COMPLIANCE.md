# HIPAA Compliance Documentation

This document outlines the HIPAA compliance measures implemented in the Tickit Mental Health Survey API.

## Overview

The Tickit API handles Protected Health Information (PHI) and is designed to comply with the Health Insurance Portability and Accountability Act (HIPAA). This document describes the technical measures implemented to ensure compliance.

## Data Encryption

### Encryption at Rest

All PHI is encrypted at rest using AES-256 encryption via the Lockbox gem:

- **Patient Information**: First name, last name, date of birth, and medical record numbers are encrypted
- **Survey Data**: Symptoms and other health-related information are encrypted
- **Clinical Notes**: All notes added by healthcare providers are encrypted

### Blind Indexing

To enable searching on encrypted fields while maintaining security, we use blind indexing:

- **Medical Record Numbers**: Can be searched securely without compromising the encrypted data
- **Symptoms**: Can be searched without exposing the raw data

### Key Management

- **Master Keys**: Rails credentials system is used for secure key management
- **Key Rotation**: The system supports key rotation procedures
- **Environment Variables**: Encryption keys are stored as environment variables and not in the codebase

## Access Controls

### Authentication

- **JWT Authentication**: JSON Web Tokens are used for secure API authentication
- **Devise Integration**: Admin authentication is handled through Devise with secure password policies
- **Token Expiration**: JWTs have a configurable expiration time

### Authorization

- **Role-Based Access**: Super admins and regular admins have different access levels
- **Restricted Access**: Only authenticated admins can access PHI
- **Audit Log Access**: Only super admins can access the complete audit logs

## Audit Logging

### Comprehensive Audit Trail

- **All PHI Access**: Every access to patient data is logged
- **Admin Actions**: All admin actions are logged
- **Survey Flagging**: Flagging and unflagging of surveys for clinical review is logged
- **Data Exports**: All data exports are logged

### Audit Log Information

Each audit log entry includes:
- Who performed the action (admin ID and information)
- What action was performed
- When the action occurred (timestamp)
- IP address of the request
- Additional context-specific details

### Audit Log Security

- **Immutable Logs**: Audit logs cannot be modified or deleted
- **Log Exports**: Logs can be exported for compliance reporting
- **Access Controls**: Only super admins can view the complete audit trail

## Data Minimization

- **Necessary Information**: Only necessary PHI is collected
- **Anonymized Analytics**: Analytics features use anonymized data where possible
- **Age Groups**: Patient ages are grouped into ranges for analytics to minimize identifiable information

## Security Measures

### API Security

- **HTTPS/TLS**: All API communications use secure transport
- **CSRF Protection**: Cross-Site Request Forgery protection is implemented
- **XSS Prevention**: Cross-Site Scripting prevention measures are in place
- **SQL Injection Protection**: ActiveRecord parameterization prevents SQL injection

### Testing

- **Automated Tests**: Comprehensive test suite ensures security measures work as expected
- **Integration Tests**: HIPAA compliance integration tests verify the system as a whole
- **Model Tests**: Encryption and access controls are tested at the model level
- **Controller Tests**: Authorization and authentication are tested at the controller level

## Compliance Dashboard

A HIPAA compliance dashboard is available to administrators, providing:

- Audit log statistics
- Encryption status
- Access control information
- Data security metrics

## Incident Response

In case of a security incident:

1. The system logs all unauthorized access attempts
2. Administrators are notified of suspicious activities
3. Comprehensive audit logs help in forensic analysis

## Regular Testing

The HIPAA compliance features are regularly tested through:

- Automated test suite
- Security scanning (Brakeman, Bundler Audit)
- Code reviews

## Implementation Details

### Models with Encrypted Fields

- `Patient`: Stores patient information with encrypted PHI
- `Survey`: Contains encrypted symptoms and health data
- `SurveyNote`: Stores encrypted clinical notes

### Controllers with Audit Logging

- `BaseController`: Implements logging for all admin actions
- `PatientsController`: Manages patient data with proper authorization
- `SurveyResponsesController`: Handles survey data with HIPAA-compliant logging
- `AuditLogsController`: Provides secure access to audit logs

### HIPAA Compliance Features

- `AuditLog` model: Tracks all system activities
- Encryption initializers: Configure secure encryption
- Authentication system: Ensures proper access controls

## Conclusion

The Tickit Mental Health Survey API implements comprehensive HIPAA compliance measures to protect patient data. These measures are continuously monitored and improved to maintain the highest standards of security and privacy.
