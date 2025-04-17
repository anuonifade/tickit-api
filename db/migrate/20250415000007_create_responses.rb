# frozen_string_literal: true

class CreateResponses < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :responses do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :text_value
      t.decimal :numeric_value, precision: 10, scale: 2

      t.timestamps
    end

    add_index :responses, [:survey_id, :question_id], unique: true
  end
end
