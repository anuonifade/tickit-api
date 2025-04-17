module Api
  module V1
    module Admin
      class SurveyWorkflowsController < BaseController
        before_action :set_survey_workflow, only: [:show, :update, :destroy, :add_question, :remove_question, :reorder_questions]
        
        # GET /api/v1/admin/survey_workflows
        def index
          @survey_workflows = SurveyWorkflow.all
          
          if params[:active].present?
            @survey_workflows = @survey_workflows.where(active: params[:active])
          end
          
          render json: SurveyWorkflowSerializer.new(@survey_workflows).serializable_hash
        end
        
        # GET /api/v1/admin/survey_workflows/:id
        def show
          render json: SurveyWorkflowSerializer.new(@survey_workflow, include: [:questions]).serializable_hash
        end
        
        # POST /api/v1/admin/survey_workflows
        def create
          @survey_workflow = SurveyWorkflow.new(survey_workflow_params)
          
          if @survey_workflow.save
            render json: SurveyWorkflowSerializer.new(@survey_workflow).serializable_hash, status: :created
          else
            render json: { errors: @survey_workflow.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # PATCH/PUT /api/v1/admin/survey_workflows/:id
        def update
          if @survey_workflow.update(survey_workflow_params)
            render json: SurveyWorkflowSerializer.new(@survey_workflow).serializable_hash
          else
            render json: { errors: @survey_workflow.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # DELETE /api/v1/admin/survey_workflows/:id
        def destroy
          @survey_workflow.destroy
          head :no_content
        end
        
        # POST /api/v1/admin/survey_workflows/:id/add_question
        def add_question
          question = Question.find(params[:question_id])
          position = params[:position] || @survey_workflow.questions.count + 1
          
          unless @survey_workflow.questions.include?(question)
            @survey_workflow.questions << question
            # Update position in the join table
            @survey_workflow.questions_survey_workflows
              .where(question_id: question.id)
              .update(position: position)
          end
          
          render json: SurveyWorkflowSerializer.new(@survey_workflow, include: [:questions]).serializable_hash
        end
        
        # DELETE /api/v1/admin/survey_workflows/:id/remove_question
        def remove_question
          question = Question.find(params[:question_id])
          @survey_workflow.questions.delete(question)
          
          render json: SurveyWorkflowSerializer.new(@survey_workflow, include: [:questions]).serializable_hash
        end
        
        # PATCH /api/v1/admin/survey_workflows/:id/reorder_questions
        def reorder_questions
          question_order = params[:question_order]
          
          ActiveRecord::Base.transaction do
            question_order.each do |item|
              @survey_workflow.questions_survey_workflows
                .where(question_id: item[:question_id])
                .update(position: item[:position])
            end
          end
          
          render json: SurveyWorkflowSerializer.new(@survey_workflow, include: [:questions]).serializable_hash
        end
        
        private
        
        def set_survey_workflow
          @survey_workflow = SurveyWorkflow.find(params[:id])
        end
        
        def survey_workflow_params
          params.require(:survey_workflow).permit(:name, :description, :active)
        end
      end
    end
  end
end
