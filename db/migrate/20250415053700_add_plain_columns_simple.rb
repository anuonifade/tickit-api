# frozen_string_literal: true

class AddPlainColumnsSimple < ActiveRecord::Migration[7.1]
  # Disable strong migrations for this migration
  def change
    # Add plain columns for testing
    add_column :patients, :first_name, :string unless column_exists?(:patients, :first_name)
    add_column :patients, :last_name, :string unless column_exists?(:patients, :last_name)
    add_column :patients, :date_of_birth, :date unless column_exists?(:patients, :date_of_birth)
    add_column :patients, :medical_record_number, :string unless column_exists?(:patients, :medical_record_number)
  end
end
