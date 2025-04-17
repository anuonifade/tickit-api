# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :audit_logs do |t|
      t.references :admin, foreign_key: true, index: true
      t.string :action, null: false
      t.string :ip_address, null: false
      t.references :auditable, polymorphic: true, index: true
      t.jsonb :details, default: {}

      t.timestamps
    end

    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
  end
end
