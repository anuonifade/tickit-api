class CreateJoinTableSurveyWorkflowsQuestions < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_join_table :survey_workflows, :questions do |t|
      t.index [:survey_workflow_id, :question_id]
      t.index [:question_id, :survey_workflow_id]
      t.integer :position
    end
  end
end
