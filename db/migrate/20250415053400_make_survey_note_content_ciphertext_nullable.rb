# frozen_string_literal: true

class MakeSurveyNoteContentCiphertextNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :survey_notes, :content_ciphertext, true
  end
end
