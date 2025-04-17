# This migration adds fields to the surveys table
class AddFieldsToSurveys < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # First, add the columns without indexes
    add_column :surveys, :flagged, :boolean, default: false
    add_column :surveys, :flagged_reason, :string
    add_column :surveys, :survey_workflow_id, :bigint

    # Skip adding indexes for now to avoid migration issues
    # We'll add them in a separate migration if needed
  end

  def down
    remove_column :surveys, :flagged
    remove_column :surveys, :flagged_reason
    remove_column :surveys, :survey_workflow_id
  end
end
