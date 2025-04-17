class CreateQuestionTemplates < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :question_templates do |t|
      t.string :title, null: false
      t.string :content, null: false
      t.string :response_type, null: false
      t.string :category, null: false
      t.jsonb :options, default: {}
      t.boolean :required, default: true
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :question_templates, :category
    add_index :question_templates, :response_type
    add_index :question_templates, :active
  end
end
