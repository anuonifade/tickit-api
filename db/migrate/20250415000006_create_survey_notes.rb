# frozen_string_literal: true

class CreateSurveyNotes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :survey_notes do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
