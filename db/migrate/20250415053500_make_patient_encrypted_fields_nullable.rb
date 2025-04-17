# frozen_string_literal: true

class MakePatientEncryptedFieldsNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :patients, :first_name_ciphertext, true
    change_column_null :patients, :last_name_ciphertext, true
    change_column_null :patients, :date_of_birth_ciphertext, true
    change_column_null :patients, :medical_record_number_ciphertext, true
    change_column_null :patients, :medical_record_number_bidx, true
  end
end
