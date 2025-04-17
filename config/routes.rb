Rails.application.routes.draw do
  # Temporarily commented out Devise routes until Admin model is properly set up
  # devise_for :admins, skip: [:sessions]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # API routes
  namespace :api do
    namespace :v1 do
      # Public routes
      resources :surveys, only: [:index, :create] do
        collection do
          get :analytics
        end
      end
      
      # Admin-only routes
      namespace :admin do
        # Admin authentication
        post 'login', to: 'sessions#create'
        delete 'logout', to: 'sessions#destroy'
        
        # Admin profile management
        get 'profile', to: 'admins#profile'
        patch 'update_profile', to: 'admins#update_profile'
        post 'change_password', to: 'admins#change_password'
        
        # Dashboard
        get 'dashboard', to: 'dashboard#index'
        get 'dashboard/hipaa_compliance', to: 'dashboard#hipaa_compliance'
        
        # Admin user management
        resources :admins do
          member do
            post :reset_password
          end
        end
        
        # Question templates management
        resources :question_templates do
          collection do
            get :categories
          end
          member do
            post :create_question
          end
        end
        
        # Questions management
        resources :questions
        
        # Survey workflows management
        resources :survey_workflows do
          member do
            post :add_question
            delete :remove_question
            patch :reorder_questions
          end
        end
        
        # Analytics endpoints
        resources :analytics, only: [:index] do
          collection do
            get :surveys_by_workflow
            get :response_trends
            get :demographic_breakdown
            get :export_data
            get :patient_demographics
          end
          member do
            get :question_insights
          end
        end
        
        # Survey response management
        resources :survey_responses do
          collection do
            get :export
          end
          member do
            post :flag
            post :unflag
            post :add_note
          end
        end
        
        # Audit logs for HIPAA compliance
        resources :audit_logs, only: [:index] do
          collection do
            get :export
          end
        end
        
        # Patient management (HIPAA-compliant)
        resources :patients do
          member do
            get :surveys
          end
        end
      end
    end
  end

  # Health check endpoints
  get 'health', to: proc { [200, {}, ['OK']] }
  get 'healthz', to: 'health#healthz'
  root to: proc { [200, {}, ['Tickit API is running']] }
end
