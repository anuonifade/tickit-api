# frozen_string_literal: true

class AddFieldsToAdmins < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    # Skip adding fields that are already in the Devise migration
    unless column_exists?(:admins, :active)
      add_column :admins, :active, :boolean, default: true
    end
  end
end
