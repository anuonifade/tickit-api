module Api
  module V1
    module Admin
      class QuestionsController < BaseController
        before_action :set_question, only: [:show, :update, :destroy]
        
        # GET /api/v1/admin/questions
        def index
          @questions = Question.all
          
          if params[:response_type].present?
            @questions = @questions.by_response_type(params[:response_type])
          end
          
          render json: QuestionSerializer.new(@questions).serializable_hash
        end
        
        # GET /api/v1/admin/questions/:id
        def show
          render json: QuestionSerializer.new(@question).serializable_hash
        end
        
        # POST /api/v1/admin/questions
        def create
          @question = Question.new(question_params)
          
          if @question.save
            render json: QuestionSerializer.new(@question).serializable_hash, status: :created
          else
            render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # PATCH/PUT /api/v1/admin/questions/:id
        def update
          if @question.update(question_params)
            render json: QuestionSerializer.new(@question).serializable_hash
          else
            render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # DELETE /api/v1/admin/questions/:id
        def destroy
          @question.destroy
          head :no_content
        end
        
        private
        
        def set_question
          @question = Question.find(params[:id])
        end
        
        def question_params
          params.require(:question).permit(:content, :response_type, :required, :position, options: {})
        end
      end
    end
  end
end
