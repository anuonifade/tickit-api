module Api
  module V1
    module Admin
      class QuestionTemplatesController < BaseController
        before_action :set_question_template, only: [:show, :update, :destroy, :create_question]
        
        # GET /api/v1/admin/question_templates
        def index
          @templates = QuestionTemplate.all
          
          if params[:category].present?
            @templates = @templates.by_category(params[:category])
          end
          
          if params[:response_type].present?
            @templates = @templates.by_response_type(params[:response_type])
          end
          
          if params[:active].present?
            @templates = @templates.where(active: params[:active] == 'true')
          end
          
          render json: QuestionTemplateSerializer.new(@templates).serializable_hash
        end
        
        # GET /api/v1/admin/question_templates/:id
        def show
          render json: QuestionTemplateSerializer.new(@template).serializable_hash
        end
        
        # POST /api/v1/admin/question_templates
        def create
          @template = QuestionTemplate.new(question_template_params)
          
          if @template.save
            render json: QuestionTemplateSerializer.new(@template).serializable_hash, status: :created
          else
            render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # PATCH/PUT /api/v1/admin/question_templates/:id
        def update
          if @template.update(question_template_params)
            render json: QuestionTemplateSerializer.new(@template).serializable_hash
          else
            render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # DELETE /api/v1/admin/question_templates/:id
        def destroy
          @template.destroy
          head :no_content
        end
        
        # POST /api/v1/admin/question_templates/:id/create_question
        def create_question
          question = @template.to_question
          
          if question.save
            render json: QuestionSerializer.new(question).serializable_hash, status: :created
          else
            render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # GET /api/v1/admin/question_templates/categories
        def categories
          categories = QuestionTemplate.distinct.pluck(:category).sort
          render json: { categories: categories }
        end
        
        private
        
        def set_question_template
          @template = QuestionTemplate.find(params[:id])
        end
        
        def question_template_params
          params.require(:question_template).permit(:title, :content, :response_type, :category, :required, :active, options: {})
        end
      end
    end
  end
end
