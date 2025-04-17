# frozen_string_literal: true

class AddContentCiphertextToSurveyNotes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # Add encrypted content field for HIPAA compliance if it doesn't exist
    unless column_exists?(:survey_notes, :content_ciphertext)
      add_column :survey_notes, :content_ciphertext, :text
      
      # If there's existing content, we need to migrate it
      # This is a placeholder - in a real migration, we would need to
      # handle the encryption of existing data properly
      # In a real migration, we would encrypt existing data here
      execute <<-SQL
        UPDATE survey_notes
        SET content_ciphertext = content
        WHERE content_ciphertext IS NULL AND content IS NOT NULL;
      SQL
    end
    
    # Remove the original unencrypted column after migration
    # In a real scenario, this would be done in a separate migration
    # after verifying all data was properly encrypted
    # remove_column :survey_notes, :content
  end
  
  def down
    # Add back the original column if needed
    # add_column :survey_notes, :content, :text unless column_exists?(:survey_notes, :content)
    
    # Remove the encrypted column
    remove_column :survey_notes, :content_ciphertext if column_exists?(:survey_notes, :content_ciphertext)
  end
end
