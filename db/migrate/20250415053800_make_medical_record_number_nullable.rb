# frozen_string_literal: true

class MakeMedicalRecordNumberNullable < ActiveRecord::Migration[7.1]
  def change
    # Make medical_record_number nullable
    change_column_null :patients, :medical_record_number, true
  end
end
