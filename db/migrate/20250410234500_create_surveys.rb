# frozen_string_literal: true

class CreateSurveys < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  
  def change
    create_table :surveys do |t|
      t.integer :feeling, null: false
      t.integer :stress_level, null: false
      t.float :sleep_hours, null: false
      t.text :symptoms, null: false
      t.text :symptoms_ciphertext, null: false
      t.string :symptoms_bidx, null: false, index: true

      t.timestamps
    end
  end
end
