# frozen_string_literal: true

class AddPatientIdToSurveys < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # Add patient reference with concurrent index if it doesn't exist
    unless column_exists?(:surveys, :patient_id)
      add_reference :surveys, :patient, index: { algorithm: :concurrently }
    end
    
    # Add fields for HIPAA compliance and flagging if they don't exist
    add_column :surveys, :flagged, :boolean, default: false unless column_exists?(:surveys, :flagged)
    add_column :surveys, :flagged_reason, :string unless column_exists?(:surveys, :flagged_reason)
    add_column :surveys, :flagged_at, :datetime unless column_exists?(:surveys, :flagged_at)
    add_column :surveys, :flagged_by_id, :bigint unless column_exists?(:surveys, :flagged_by_id)
    
    # Add index if it doesn't exist
    unless index_exists?(:surveys, :flagged)
      add_index :surveys, :flagged, algorithm: :concurrently
    end
    # Foreign keys will be added in a separate migration
  end
  
  def down
    remove_index :surveys, :flagged if index_exists?(:surveys, :flagged)
    
    remove_column :surveys, :flagged_by_id if column_exists?(:surveys, :flagged_by_id)
    remove_column :surveys, :flagged_at if column_exists?(:surveys, :flagged_at)
    remove_column :surveys, :flagged_reason if column_exists?(:surveys, :flagged_reason)
    remove_column :surveys, :flagged if column_exists?(:surveys, :flagged)
    
    remove_reference :surveys, :patient if column_exists?(:surveys, :patient_id)
  end
end
