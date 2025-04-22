# frozen_string_literal: true

module Api
  module V1
    # Surveys controller handles mental health survey submissions and analytics
    class SurveysController < ApplicationController
      # GET /api/v1/surveys
      def index
        @surveys = Survey.all
        render json: SurveySerializer.new(@surveys).serializable_hash
      end
      
      # GET /api/v1/surveys/analytics
      def analytics
        @analytics = Survey.analytics
        render json: @analytics
      end

      # POST /api/v1/surveys
      def create
        @survey = Survey.new(survey_params)

        if @survey.save
          render json: SurveySerializer.new(@survey).serializable_hash, status: :created
        else
          render json: { errors: @survey.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error("Error creating survey: #{e.message}\n#{e.backtrace.join("\n")}")
        render json: { errors: ["An error occurred while processing your request: #{e.message}"] }, status: :unprocessable_entity
      end

      private

      def survey_params
        params.require(:survey).permit(:feeling, :stress_level, :sleep_hours, :symptoms)
      end
    end
  end
end
