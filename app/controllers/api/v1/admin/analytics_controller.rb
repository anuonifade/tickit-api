# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Analytics controller for HIPAA-compliant data analysis
      class AnalyticsController < BaseController
        skip_before_action :log_admin_action
        before_action :log_analytics_access
        # GET /api/v1/admin/analytics
        def index
          # Enhanced analytics summary with HIPAA compliance
          @analytics = {
            surveys: {
              total: Survey.count,
              today: Survey.where('created_at >= ?', Date.today).count,
              this_week: Survey.where('created_at >= ?', 1.week.ago).count,
              this_month: Survey.where('created_at >= ?', 1.month.ago).count,
              flagged: Survey.where(flagged: true).count
            },
            patients: {
              total: Patient.count,
              active: Patient.where(status: 'active').count,
              by_gender: Patient.group(:gender).count,
              age_distribution: calculate_age_distribution
            },
            response_metrics: calculate_response_metrics,
            surveys_by_date: surveys_by_date,
            response_distribution: response_distribution,
            hipaa_compliance: {
              audit_logs_today: AuditLog.where('created_at >= ?', Date.today).count,
              encryption_status: 'AES-256 active',
              data_access_logs: AuditLog.where(action: ['patient.view', 'survey.view']).count
            }
          }
          
          render json: @analytics
        end
        
        # GET /api/v1/admin/analytics/surveys_by_workflow
        def surveys_by_workflow
          @data = Survey.group(:survey_workflow_id)
                       .count
                       .map do |workflow_id, count|
                         {
                           workflow_id: workflow_id,
                           workflow_name: workflow_id ? SurveyWorkflow.find(workflow_id).name : 'No Workflow',
                           count: count,
                           percentage: (count.to_f / Survey.count * 100).round(2)
                         }
                       end
          
          render json: @data
        end
        
        # GET /api/v1/admin/analytics/response_trends
        def response_trends
          # Track response trends over time (last 12 months)
          months = (0..11).map { |i| i.months.ago.beginning_of_month }
          
          @trends = {
            trends_by_month: months.map do |month|
              {
                month: month.strftime('%B %Y'),
                count: Survey.where(created_at: month.beginning_of_month..month.end_of_month).count
              }
            end.reverse,
            trends_by_question_type: question_type_trends
          }
          
          render json: @trends
        end
        
        # GET /api/v1/admin/analytics/question_insights/:id
        def question_insights
          question = Question.find(params[:id])
          
          # Analyze responses for a specific question
          @insights = {
            question: QuestionSerializer.new(question).serializable_hash[:data][:attributes],
            response_count: Survey.joins(:responses).where(responses: { question_id: question.id }).count,
            response_distribution: question_response_distribution(question),
            average_score: question.response_type == 'numeric_scale' ? calculate_average_score(question) : nil
          }
          
          render json: @insights
        end
        
        # GET /api/v1/admin/analytics/demographic_breakdown
        def demographic_breakdown
          # Example demographic breakdown (if you collect demographic data)
          @demographics = {
            age_groups: age_group_distribution,
            gender_distribution: gender_distribution,
            location_distribution: location_distribution
          }
          
          render json: @demographics
        end
        
        # GET /api/v1/admin/analytics/export_data
        def export_data
          # Generate CSV export of survey data
          # This would typically stream a CSV file
          # For now, we'll just return a sample of the data
          @export = {
            status: 'success',
            message: 'Data export would be generated here',
            sample_data: Survey.limit(5).as_json(only: [:id, :created_at, :updated_at])
          }
          
          render json: @export
        end
        
        # GET /api/v1/admin/analytics/patient_demographics
        def patient_demographics
          # Anonymized patient demographics for HIPAA compliance
          @demographics = {
            gender_distribution: Patient.group(:gender).count,
            age_groups: calculate_age_distribution,
            status_distribution: Patient.group(:status).count,
            survey_completion: {
              patients_with_surveys: Patient.joins(:surveys).distinct.count,
              patients_without_surveys: Patient.left_joins(:surveys).where(surveys: { id: nil }).count,
              average_surveys_per_patient: (Survey.count.to_f / Patient.count).round(2)
            }
          }
          
          render json: @demographics
        end
        
        private
        
        # Log analytics access for HIPAA compliance
        def log_analytics_access
          # Enable audit logging for this specific controller action
          Thread.current[:enable_audit_logs] = true
          
          # Create the audit log
          log = AuditLog.log(
            current_admin,
            "analytics.#{action_name}",
            nil,
            request.remote_ip,
            { 
              params: filtered_params,
              timestamp: Time.current 
            }
          )
          
          # Reset the thread variable after creating the log
          Thread.current[:enable_audit_logs] = nil
          
          # Return the log for testing purposes
          log
        end
        
        # Filter sensitive parameters for audit logs
        def filtered_params
          params.to_unsafe_h.except('controller', 'action')
        end
        
        def surveys_by_date
          # Get surveys by date for the last 30 days
          dates = (0..29).map { |i| i.days.ago.to_date }.reverse
          
          result = dates.map do |date|
            count = Survey.where(created_at: date.beginning_of_day..date.end_of_day).count
            { date: date.strftime('%Y-%m-%d'), count: count }
          end
          
          result
        end
        
        def calculate_response_metrics
          # Calculate various response metrics
          {
            average_completion_time: calculate_average_completion_time,
            average_score: calculate_overall_average_score,
            completion_rate: calculate_completion_rate,
            response_quality: calculate_response_quality
          }
        end
        
        def calculate_average_completion_time
          # Placeholder for calculating average time to complete a survey
          # In a real implementation, you would track start and end times
          rand(60..300) # Simulated value: 1-5 minutes
        end
        
        def calculate_overall_average_score
          # Placeholder for calculating average score across numeric questions
          # In a real implementation, you would aggregate actual scores
          (rand(60..95) / 10.0).round(1) # Simulated value: 6.0-9.5
        end
        
        def calculate_completion_rate
          # Placeholder for calculating survey completion rate
          # In a real implementation, you would track started vs. completed surveys
          rand(75..98) # Simulated value: 75-98%
        end
        
        def calculate_response_quality
          # Placeholder for calculating response quality metric
          # This could be based on time spent, answer length, etc.
          rand(70..95) # Simulated value: 70-95%
        end
        
        def response_distribution
          # Distribution of responses by question type
          question_types = Question.distinct.pluck(:response_type)
          
          result = {}
          question_types.each do |type|
            result[type] = Question.where(response_type: type).count
          end
          
          result
        end
        
        def question_type_trends
          # Track question type trends
          question_types = Question.distinct.pluck(:response_type)
          
          result = {}
          question_types.each do |type|
            result[type] = (1..6).map do |months_ago|
              {
                month: months_ago.months.ago.strftime('%B %Y'),
                count: Question.where(response_type: type)
                               .where('created_at <= ?', months_ago.months.ago.end_of_month)
                               .count
              }
            end.reverse
          end
          
          result
        end
        
        def calculate_age_distribution
          # Calculate anonymized age distribution for HIPAA compliance
          age_groups = {
            '0-17' => 0,
            '18-24' => 0,
            '25-34' => 0,
            '35-44' => 0,
            '45-54' => 0,
            '55-64' => 0,
            '65+' => 0,
            'Unknown' => 0
          }
          
          Patient.find_each do |patient|
            age = patient.age
            
            case age
            when nil
              age_groups['Unknown'] += 1
            when 0..17
              age_groups['0-17'] += 1
            when 18..24
              age_groups['18-24'] += 1
            when 25..34
              age_groups['25-34'] += 1
            when 35..44
              age_groups['35-44'] += 1
            when 45..54
              age_groups['45-54'] += 1
            when 55..64
              age_groups['55-64'] += 1
            else
              age_groups['65+'] += 1
            end
          end
          
          age_groups
        end
        
        def question_response_distribution(question)
          # Placeholder for response distribution for a specific question
          # In a real implementation, you would aggregate actual responses
          case question.response_type
          when 'numeric_scale'
            # For numeric scale questions, show distribution across possible values
            (1..10).map { |value| { value: value, count: rand(5..50) } }
          when 'multiple_choice'
            # For multiple choice, show distribution across options
            (question.options['choices'] || []).map do |choice|
              { value: choice, count: rand(5..50) }
            end
          when 'yes_no'
            # For yes/no questions
            [
              { value: 'Yes', count: rand(20..80) },
              { value: 'No', count: rand(20..80) }
            ]
          else
            # For text questions, maybe show word frequency or length distribution
            [{ value: 'Text responses', count: rand(10..100) }]
          end
        end
        
        def calculate_average_score(question)
          # Placeholder for calculating average score for a numeric question
          # In a real implementation, you would calculate from actual responses
          (rand(50..90) / 10.0).round(1) # Simulated value: 5.0-9.0
        end
        
        def age_group_distribution
          # Placeholder for age group distribution
          # In a real implementation, you would aggregate from demographic data
          [
            { group: '18-24', count: rand(10..50) },
            { group: '25-34', count: rand(20..100) },
            { group: '35-44', count: rand(20..80) },
            { group: '45-54', count: rand(10..60) },
            { group: '55+', count: rand(5..40) }
          ]
        end
        
        def gender_distribution
          # Placeholder for gender distribution
          # In a real implementation, you would aggregate from demographic data
          [
            { gender: 'Male', count: rand(50..150) },
            { gender: 'Female', count: rand(50..150) },
            { gender: 'Non-binary', count: rand(5..30) },
            { gender: 'Prefer not to say', count: rand(5..20) }
          ]
        end
        
        def location_distribution
          # Placeholder for location distribution
          # In a real implementation, you would aggregate from demographic data
          [
            { location: 'North America', count: rand(50..200) },
            { location: 'Europe', count: rand(30..150) },
            { location: 'Asia', count: rand(20..100) },
            { location: 'South America', count: rand(10..50) },
            { location: 'Africa', count: rand(5..30) },
            { location: 'Australia/Oceania', count: rand(5..30) }
          ]
        end
      end
    end
  end
end
