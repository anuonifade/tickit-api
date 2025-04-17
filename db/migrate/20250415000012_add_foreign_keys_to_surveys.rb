# frozen_string_literal: true

class AddForeignKeysToSurveys < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # Use a safer approach to add foreign keys
    begin
      # Try to add the foreign key to patients
      add_foreign_key :surveys, :patients, validate: false
      validate_foreign_key :surveys, :patients
    rescue ActiveRecord::StatementInvalid => e
      # If it already exists, just log the error and continue
      puts "Foreign key from surveys to patients already exists: #{e.message}"
    end
    
    begin
      # Try to add the foreign key for flagged_by_id
      add_foreign_key :surveys, :admins, column: :flagged_by_id, validate: false
      validate_foreign_key :surveys, :admins, column: :flagged_by_id
    rescue ActiveRecord::StatementInvalid => e
      # If it already exists, just log the error and continue
      puts "Foreign key from surveys.flagged_by_id to admins already exists: #{e.message}"
    end
  end
  
  def down
    begin
      remove_foreign_key :surveys, :patients
    rescue ActiveRecord::StatementInvalid => e
      puts "Error removing foreign key from surveys to patients: #{e.message}"
    end
    
    begin
      remove_foreign_key :surveys, :admins, column: :flagged_by_id
    rescue ActiveRecord::StatementInvalid => e
      puts "Error removing foreign key from surveys.flagged_by_id to admins: #{e.message}"
    end
  end
end
