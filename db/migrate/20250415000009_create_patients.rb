# frozen_string_literal: true

class CreatePatients < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :patients do |t|
      # Encrypted fields for HIPAA compliance
      t.text :first_name_ciphertext
      t.text :last_name_ciphertext
      t.text :date_of_birth_ciphertext
      t.text :medical_record_number_ciphertext
      
      # Blind index for searching encrypted fields
      t.string :medical_record_number_bidx, index: { unique: true }
      
      # Non-encrypted fields
      t.string :email, null: false
      t.string :phone_number
      t.string :gender
      t.string :status, default: 'active'

      t.timestamps
    end

    add_index :patients, :email, unique: true
    add_index :patients, :status
  end
end
