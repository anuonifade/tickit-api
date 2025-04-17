# frozen_string_literal: true

class MakeSymptomsNullable < ActiveRecord::Migration[7.2]
  def change
    # Make symptoms nullable for testing purposes
    change_column_null :surveys, :symptoms, true
  end
end
