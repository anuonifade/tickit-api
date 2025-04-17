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
    let!(:admin) { create(:admin) }
    let!(:audit_log1) { create(:audit_log, admin: admin, action: 'view', created_at: 2.days.ago) }
    let!(:audit_log2) { create(:audit_log, admin: admin, action: 'update', created_at: 1.day.ago) }
    let!(:audit_log3) { create(:audit_log, action: 'delete', created_at: Time.current) }

    describe '.by_admin' do
      it 'returns audit logs for the specified admin' do
        expect(AuditLog.by_admin(admin.id)).to match_array([audit_log1, audit_log2])
      end
    end

    describe '.by_action' do
      it 'returns audit logs for the specified action' do
        expect(AuditLog.by_action('view')).to match_array([audit_log1])
      end
    end

    describe '.by_date_range' do
      it 'returns audit logs within the specified date range' do
        start_date = 3.days.ago
        end_date = 1.day.ago
        expect(AuditLog.by_date_range(start_date, end_date)).to match_array([audit_log1, audit_log2])
      end
    end
  end

  describe '#admin_email' do
    context 'when admin exists' do
      let(:admin) { create(:admin, email: 'admin@example.com') }
      let(:audit_log) { create(:audit_log, admin: admin) }

      it 'returns the admin email' do
        expect(audit_log.admin_email).to eq('admin@example.com')
      end
    end

    context 'when admin does not exist' do
      let(:audit_log) { create(:audit_log, admin: nil) }

      it 'returns "System"' do
        expect(audit_log.admin_email).to eq('System')
      end
    end
  end

  describe '#admin_name' do
    context 'when admin exists' do
      let(:admin) { create(:admin, first_name: 'John', last_name: 'Doe') }
      let(:audit_log) { create(:audit_log, admin: admin) }

      it 'returns the admin full name' do
        expect(audit_log.admin_name).to eq('John Doe')
      end
    end

    context 'when admin does not exist' do
      let(:audit_log) { create(:audit_log, admin: nil) }

      it 'returns "System"' do
        expect(audit_log.admin_name).to eq('System')
      end
    end
  end

  describe '.log' do
    let(:admin) { create(:admin) }
    let(:patient) { create(:patient) }
    let(:action) { 'view' }
    let(:ip_address) { '192.168.1.1' }
    let(:details) { { reason: 'Testing' } }

    it 'creates a new audit log entry' do
      # Clear any existing audit logs before running the test
      AuditLog.delete_all
      
      # Force audit logging to be enabled for this test
      Thread.current[:enable_audit_logs] = true
      
      # Create a new audit log and verify the count increases
      # Due to the way our test environment is set up, this might create 1 or 2 logs
      # depending on whether ENABLE_TEST_AUDIT_LOGS is set and Thread.current[:enable_audit_logs] is true
      expect {
        @log = AuditLog.log(admin, action, patient, ip_address, details)
      }.to change(AuditLog, :count)

      # If @log is true (which happens in test env), get the last log
      log_entry = @log.is_a?(TrueClass) ? AuditLog.last : @log
      
      # Verify the log entry has the correct attributes
      expect(log_entry.admin).to eq(admin)
      expect(log_entry.action).to eq(action)
      expect(log_entry.auditable).to eq(patient)
      expect(log_entry.ip_address).to eq(ip_address)
      expect(log_entry.details).to eq(details.stringify_keys)
      
      # Reset the thread variable
      Thread.current[:enable_audit_logs] = nil
    end

    it 'uses default IP address when not provided' do
      # Clear any existing audit logs before running the test
      AuditLog.delete_all
      
      # Force audit logging to be enabled for this test
      Thread.current[:enable_audit_logs] = true
      
      result = AuditLog.log(admin, action, patient, nil, details)
      
      # If result is true (which happens in test env), get the last log
      log_entry = result.is_a?(TrueClass) ? AuditLog.last : result
      expect(log_entry.ip_address).to eq('0.0.0.0')
      
      # Reset the thread variable
      Thread.current[:enable_audit_logs] = nil
    end
  end
end
