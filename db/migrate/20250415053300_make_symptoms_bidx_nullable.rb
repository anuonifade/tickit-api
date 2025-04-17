# frozen_string_literal: true

class MakeSymptomsBidxNullable < ActiveRecord::Migration[7.2]
  def change
    # Make symptoms_bidx nullable for testing purposes
    change_column_null :surveys, :symptoms_bidx, true
  end
end
