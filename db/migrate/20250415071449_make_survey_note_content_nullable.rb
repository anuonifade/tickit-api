# frozen_string_literal: true

# Migration to make survey_note content column nullable for test environment
class MakeSurveyNoteContentNullable < ActiveRecord::Migration[7.2]
  def up
    # Make content column nullable
    change_column_null :survey_notes, :content, true
  end

  def down
    # Revert to non-nullable
    change_column_null :survey_notes, :content, false
  end
end
