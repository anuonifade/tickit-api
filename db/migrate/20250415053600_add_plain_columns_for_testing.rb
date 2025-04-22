# frozen_string_literal: true

class AddPlainColumnsForTesting < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # Add plain columns for testing
    add_column :patients, :first_name, :string
    add_column :patients, :last_name, :string
    add_column :patients, :date_of_birth, :date
    add_column :patients, :medical_record_number, :string
    
    # Make sure the column exists before creating the index
    # We need to do this in a separate transaction
    if ENV['SKIP_DB_INDEXES'] != 'true'
      execute "ALTER TABLE patients ALTER COLUMN medical_record_number SET NOT NULL"
    end
    
    # Add index on medical_record_number (only if not skipping indexes)
    unless ENV['SKIP_DB_INDEXES'] == 'true'
      add_index :patients, :medical_record_number, unique: true, algorithm: :concurrently
    end
  end
  
  def down
    remove_index :patients, :medical_record_number if index_exists?(:patients, :medical_record_number)
    remove_column :patients, :medical_record_number
    remove_column :patients, :date_of_birth
    remove_column :patients, :last_name
    remove_column :patients, :first_name
  end
end
