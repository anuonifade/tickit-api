# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Controller for managing patients with HIPAA compliance
      class PatientsController < BaseController
        skip_before_action :log_admin_action
        
        # Set current admin in thread-local variable for HIPAA audit logging
        before_action :set_current_admin_in_thread
        before_action :set_patient, only: [:show, :update, :destroy, :surveys]
        before_action :log_patient_action
        
        # Clear thread-local variable after action
        after_action :clear_current_admin_in_thread
        
        # GET /api/v1/admin/patients
        def index
          @patients = Patient.all.order(created_at: :desc)
          
          # Apply filters if provided
          @patients = @patients.where('email ILIKE ?', "%#{params[:email]}%") if params[:email].present?
          @patients = @patients.where(status: params[:status]) if params[:status].present?
          
          # Paginate results
          @patients = @patients.page(params[:page] || 1).per(params[:per_page] || 25)
          
          render json: {
            patients: @patients.map { |patient| patient_json(patient) },
            meta: {
              total_count: @patients.total_count,
              total_pages: @patients.total_pages,
              current_page: @patients.current_page
            }
          }
        end
        
        # GET /api/v1/admin/patients/:id
        def show
          render json: { patient: patient_json(@patient) }
        end
        
        # POST /api/v1/admin/patients
        def create
          @patient = Patient.new(patient_params)
          
          if @patient.save
            render json: { patient: patient_json(@patient) }, status: :created
          else
            render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # PATCH/PUT /api/v1/admin/patients/:id
        def update
          if @patient.update(patient_params)
            render json: { patient: patient_json(@patient) }
          else
            render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
          end
        end
        
        # DELETE /api/v1/admin/patients/:id
        def destroy
          @patient.destroy
          head :no_content
        end
        
        # GET /api/v1/admin/patients/:id/surveys
        def surveys
          @surveys = @patient.surveys.order(created_at: :desc)
          
          # Paginate results
          @surveys = @surveys.page(params[:page] || 1).per(params[:per_page] || 10)
          
          render json: {
            surveys: @surveys.map { |survey| survey_json(survey) },
            meta: {
              total_count: @surveys.total_count,
              total_pages: @surveys.total_pages,
              current_page: @surveys.current_page
            }
          }
        end
        
        private
        
        # Log patient actions for HIPAA compliance audit trail
        def log_patient_action
          # Skip logging if not signed in, but allow test environment with thread variable
          return unless admin_signed_in? || Thread.current[:enable_audit_logs]
          
          # Extract the relevant information for the audit log
          action = "patients##{action_name}"
          ip_address = request.remote_ip
          auditable = @patient if @patient.present?
          details = {
            params: filtered_params,
            user_agent: request.user_agent,
            referer: request.referer,
            timestamp: Time.current
          }
          
          # Create the audit log entry
          AuditLog.log(Thread.current[:current_admin], action, auditable, ip_address, details)
        end
        
        def set_current_admin_in_thread
          Thread.current[:current_admin] = current_admin if admin_signed_in?
          Thread.current[:enable_audit_logs] = true
        end
        
        def clear_current_admin_in_thread
          Thread.current[:current_admin] = nil
        end
        
        def set_patient
          @patient = Patient.find(params[:id])
        end
        
        def patient_params
          params.require(:patient).permit(
            :first_name, :last_name, :email, :phone_number, 
            :date_of_birth, :gender, :medical_record_number, :status
          )
        end
        
        def patient_json(patient)
          {
            id: patient.id,
            first_name: patient.first_name,
            last_name: patient.last_name,
            full_name: patient.full_name,
            email: patient.email,
            phone_number: patient.phone_number,
            date_of_birth: patient.date_of_birth,
            age: patient.age,
            gender: patient.gender,
            medical_record_number: patient.medical_record_number,
            status: patient.status,
            created_at: patient.created_at,
            updated_at: patient.updated_at
          }
        end
        
        def survey_json(survey)
          {
            id: survey.id,
            feeling: survey.feeling,
            stress_level: survey.stress_level,
            sleep_hours: survey.sleep_hours,
            symptoms: survey.symptoms,
            flagged: survey.flagged,
            flagged_reason: survey.flagged_reason,
            created_at: survey.created_at
          }
        end
      end
    end
  end
end
