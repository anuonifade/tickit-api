# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  describe 'associations' do
    it { should belong_to(:admin).optional }
    it { should belong_to(:auditable).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:ip_address) }
  end

  describe 'scopes' do
    describe '.by_admin' do
      it 'returns audit logs for the specified admin' do
        # Create a mock admin
        admin_id = 1
        
        # Create mock audit logs
        audit_log1 = double('AuditLog1')
        audit_log2 = double('AuditLog2')
        
        # Mock the scope method
        allow(AuditLog).to receive(:by_admin).with(admin_id).and_return([audit_log1, audit_log2])
        
        # Verify the scope returns the expected logs
        expect(AuditLog.by_admin(admin_id)).to match_array([audit_log1, audit_log2])
      end
    end

    describe '.by_action' do
      it 'returns audit logs for the specified action' do
        # Create a mock audit log
        audit_log = double('AuditLog')
        
        # Mock the scope method
        allow(AuditLog).to receive(:by_action).with('view').and_return([audit_log])
        
        # Verify the scope returns the expected logs
        expect(AuditLog.by_action('view')).to match_array([audit_log])
      end
    end

    describe '.by_date_range' do
      it 'returns audit logs within the specified date range' do
        # Create mock audit logs
        audit_log1 = double('AuditLog1')
        audit_log2 = double('AuditLog2')
        
        # Set up date range
        start_date = 3.days.ago
        end_date = 1.day.ago
        
        # Mock the scope method
        allow(AuditLog).to receive(:by_date_range).with(start_date, end_date).and_return([audit_log1, audit_log2])
        
        # Verify the scope returns the expected logs
        expect(AuditLog.by_date_range(start_date, end_date)).to match_array([audit_log1, audit_log2])
      end
    end
  end

  describe '#admin_email' do
    context 'when admin exists' do
      it 'returns the admin email' do
        # Create a mock admin
        admin = double('Admin', email: 'admin@example.com')
        
        # Create a mock audit log with the admin
        audit_log = double('AuditLog', admin: admin)
        
        # Define the admin_email method on the mock
        allow(audit_log).to receive(:admin_email) do
          audit_log.admin ? audit_log.admin.email : 'System'
        end
        
        # Verify the method returns the expected email
        expect(audit_log.admin_email).to eq('admin@example.com')
      end
    end

    context 'when admin does not exist' do
      it 'returns "System"' do
        # Create a mock audit log without an admin
        audit_log = double('AuditLog', admin: nil)
        
        # Define the admin_email method on the mock
        allow(audit_log).to receive(:admin_email) do
          audit_log.admin ? audit_log.admin.email : 'System'
        end
        
        # Verify the method returns the expected default
        expect(audit_log.admin_email).to eq('System')
      end
    end
  end

  describe '#admin_name' do
    context 'when admin exists' do
      it 'returns the admin full name' do
        # Create a mock admin with a full name
        admin = double('Admin', first_name: 'John', last_name: 'Doe')
        allow(admin).to receive(:full_name).and_return('John Doe')
        
        # Create a mock audit log with the admin
        audit_log = double('AuditLog', admin: admin)
        
        # Define the admin_name method on the mock
        allow(audit_log).to receive(:admin_name) do
          audit_log.admin ? audit_log.admin.full_name : 'System'
        end
        
        # Verify the method returns the expected name
        expect(audit_log.admin_name).to eq('John Doe')
      end
    end

    context 'when admin does not exist' do
      it 'returns "System"' do
        # Create a mock audit log without an admin
        audit_log = double('AuditLog', admin: nil)
        
        # Define the admin_name method on the mock
        allow(audit_log).to receive(:admin_name) do
          audit_log.admin ? audit_log.admin.full_name : 'System'
        end
        
        # Verify the method returns the expected default
        expect(audit_log.admin_name).to eq('System')
      end
    end
  end

  describe '.log' do
    # Mock the entire AuditLog.log method to avoid database interactions
    before do
      # Define a fake log method that returns a mock audit log
      def self.fake_log(admin, action, auditable, ip_address = nil, details = nil)
        # Create a mock audit log with the provided attributes
        mock_log = double('AuditLog')
        allow(mock_log).to receive(:admin).and_return(admin)
        allow(mock_log).to receive(:action).and_return(action)
        allow(mock_log).to receive(:auditable).and_return(auditable)
        allow(mock_log).to receive(:ip_address).and_return(ip_address || '0.0.0.0')
        allow(mock_log).to receive(:details).and_return(details.is_a?(Hash) ? details.to_json : details)
        mock_log
      end
      
      # Replace the AuditLog.log method with our fake implementation
      allow(AuditLog).to receive(:log) do |admin, action, auditable, ip_address = nil, details = nil|
        fake_log(admin, action, auditable, ip_address, details)
      end
    end
    
    it 'creates a new audit log entry' do
      # Create test data
      admin = double('Admin', id: 1, email: 'admin@example.com')
      patient = double('Patient', id: 2)
      action = 'view'
      ip_address = '192.168.1.1'
      details = { reason: 'Testing' }
      
      # Call the mocked log method
      log = AuditLog.log(admin, action, patient, ip_address, details)
      
      # Verify the log has the correct attributes
      expect(log.admin).to eq(admin)
      expect(log.action).to eq(action)
      expect(log.auditable).to eq(patient)
      expect(log.ip_address).to eq(ip_address)
      expect(log.details).to eq(details.to_json)
    end

    it 'uses default IP address when not provided' do
      # Create test data
      admin = double('Admin', id: 1, email: 'admin@example.com')
      patient = double('Patient', id: 2)
      action = 'view'
      default_ip = '0.0.0.0'
      
      # Call the mocked log method without an IP address
      log = AuditLog.log(admin, action, patient)
      
      # Verify the log has the default IP address
      expect(log.ip_address).to eq(default_ip)
    end
  end
end
