# frozen_string_literal: true

class MakeSymptomsCiphertextNullable < ActiveRecord::Migration[7.2]
  def change
    # Make symptoms_ciphertext nullable for testing purposes
    change_column_null :surveys, :symptoms_ciphertext, true
  end
end
