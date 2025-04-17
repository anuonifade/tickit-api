class CreateQuestions < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :questions do |t|
      t.string :content, null: false
      t.string :response_type, null: false
      t.jsonb :options, default: {}
      t.boolean :required, default: true
      t.integer :position

      t.timestamps
    end

    add_index :questions, :response_type
  end
end
