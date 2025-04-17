module Api
  module V1
    module Admin
      class SurveyResponsesController < BaseController
        before_action :set_survey, only: [:show, :destroy, :flag, :unflag, :add_note]
        
        # GET /api/v1/admin/survey_responses
        def index
          @surveys = Survey.all.includes(:responses)
          
          # Apply filters if provided
          @surveys = apply_filters(@surveys)
          
          # Apply pagination
          page = (params[:page] || 1).to_i
          per_page = (params[:per_page] || 20).to_i
          @surveys = @surveys.page(page).per(per_page)
          
          render json: SurveyResponseSerializer.new(@surveys, 
            meta: { 
              total: @surveys.total_count,
              pages: @surveys.total_pages,
              page: page
            }
          ).serializable_hash
        end
        
        # GET /api/v1/admin/survey_responses/:id
        def show
          render json: SurveyResponseSerializer.new(@survey, include: [:responses]).serializable_hash
        end
        
        # DELETE /api/v1/admin/survey_responses/:id
        def destroy
          @survey.destroy
          head :no_content
        end
        
        # POST /api/v1/admin/survey_responses/:id/flag
        def flag
          @survey.update(flagged: true, flagged_reason: params[:reason], flagged_at: Time.current, flagged_by_id: current_admin.id)
          
          # Create audit log for HIPAA compliance
          AuditLog.log(
            current_admin, 
            'survey.flag', 
            @survey, 
            request.remote_ip, 
            { reason: params[:reason], patient_id: @survey.patient_id }
          )
          
          render json: { message: 'Survey flagged successfully' }
        end
        
        # POST /api/v1/admin/survey_responses/:id/unflag
        def unflag
          @survey.update(flagged: false, flagged_reason: nil, flagged_at: nil, flagged_by_id: nil)
          
          # Create audit log for HIPAA compliance
          AuditLog.log(
            current_admin, 
            'survey.unflag', 
            @survey, 
            request.remote_ip, 
            { patient_id: @survey.patient_id }
          )
          
          render json: { message: 'Survey unflagged successfully' }
        end
        
        # POST /api/v1/admin/survey_responses/:id/add_note
        def add_note
          # Validate that content is present
          unless params[:content].present?
            render json: { error: "Content can't be blank" }, status: :unprocessable_entity
            return
          end
          
          # Add a note to the survey
          note = @survey.notes.create(
            content: params[:content],
            admin_id: current_admin.id
          )
          
          if note.persisted?
            # Create audit log for HIPAA compliance
            AuditLog.log(
              current_admin, 
              'survey.add_note', 
              @survey, 
              request.remote_ip, 
              { note_id: note.id, patient_id: @survey.patient_id }
            )
            
            render json: { message: 'Note added successfully', note: note }
          else
            render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # GET /api/v1/admin/survey_responses/export
        def export
          @surveys = Survey.all.includes(:responses)
          @surveys = apply_filters(@surveys)
          
          # In a real implementation, this would generate a CSV file
          # For now, we'll just return a message
          render json: { 
            message: 'Export initiated', 
            count: @surveys.count,
            sample: @surveys.limit(2).as_json(only: [:id, :created_at])
          }
        end
        
        private
        
        def set_survey
          @survey = Survey.find(params[:id])
        end
        
        def apply_filters(surveys)
          # Filter by date range
          if params[:start_date].present?
            surveys = surveys.where('created_at >= ?', Date.parse(params[:start_date]).beginning_of_day)
          end
          
          if params[:end_date].present?
            surveys = surveys.where('created_at <= ?', Date.parse(params[:end_date]).end_of_day)
          end
          
          # Filter by workflow
          if params[:workflow_id].present?
            surveys = surveys.where(survey_workflow_id: params[:workflow_id])
          end
          
          # Filter by patient
          if params[:patient_id].present?
            surveys = surveys.where(patient_id: params[:patient_id])
          end
          
          # Filter by flagged status
          if params[:flagged].present?
            surveys = surveys.where(flagged: params[:flagged] == 'true')
          end
          
          # Filter by search term (across responses)
          if params[:search].present?
            surveys = surveys.joins(:responses)
                            .where('responses.text_value ILIKE ?', "%#{params[:search]}%")
                            .distinct
          end
          
          # Sort results
          sort_by = params[:sort_by] || 'created_at'
          sort_direction = params[:sort_direction] || 'desc'
          surveys = surveys.order("#{sort_by} #{sort_direction}")
          
          # Log the search for HIPAA compliance audit
          if action_name == 'index' || action_name == 'export'
            # Create a safe hash of permitted parameters
            filter_params = {}
            filter_params[:start_date] = params[:start_date] if params[:start_date].present?
            filter_params[:end_date] = params[:end_date] if params[:end_date].present?
            filter_params[:workflow_id] = params[:workflow_id] if params[:workflow_id].present?
            filter_params[:patient_id] = params[:patient_id] if params[:patient_id].present?
            filter_params[:flagged] = params[:flagged] if params[:flagged].present?
            filter_params[:search] = params[:search] if params[:search].present?
            
            AuditLog.log(
              current_admin,
              'survey_responses.search',
              nil,
              request.remote_ip,
              { 
                filters: filter_params,
                results_count: surveys.count
              }
            )
          end
          
          surveys
        end
      end
    end
  end
end
