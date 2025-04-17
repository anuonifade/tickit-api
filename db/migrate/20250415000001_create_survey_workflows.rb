class CreateSurveyWorkflows < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :survey_workflows do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :survey_workflows, :name, unique: true
  end
end
