# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_15_071449) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role", default: "admin"
    t.datetime "last_sign_in_at"
    t.integer "sign_in_count", default: 0
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "admin_id"
    t.string "action", null: false
    t.string "ip_address", null: false
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.jsonb "details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["admin_id"], name: "index_audit_logs_on_admin_id"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
  end

  create_table "patients", force: :cascade do |t|
    t.text "first_name_ciphertext"
    t.text "last_name_ciphertext"
    t.text "date_of_birth_ciphertext"
    t.text "medical_record_number_ciphertext"
    t.string "medical_record_number_bidx"
    t.string "email", null: false
    t.string "phone_number"
    t.string "gender"
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.string "medical_record_number"
    t.index ["email"], name: "index_patients_on_email", unique: true
    t.index ["medical_record_number_bidx"], name: "index_patients_on_medical_record_number_bidx", unique: true
    t.index ["status"], name: "index_patients_on_status"
  end

  create_table "question_templates", force: :cascade do |t|
    t.string "title", null: false
    t.string "content", null: false
    t.string "response_type", null: false
    t.string "category", null: false
    t.jsonb "options", default: {}
    t.boolean "required", default: true
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_question_templates_on_active"
    t.index ["category"], name: "index_question_templates_on_category"
    t.index ["response_type"], name: "index_question_templates_on_response_type"
  end

  create_table "questions", force: :cascade do |t|
    t.string "content", null: false
    t.string "response_type", null: false
    t.jsonb "options", default: {}
    t.boolean "required", default: true
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["response_type"], name: "index_questions_on_response_type"
  end

  create_table "questions_survey_workflows", id: false, force: :cascade do |t|
    t.bigint "survey_workflow_id", null: false
    t.bigint "question_id", null: false
    t.integer "position"
    t.index ["question_id", "survey_workflow_id"], name: "idx_on_question_id_survey_workflow_id_4b52443693"
    t.index ["survey_workflow_id", "question_id"], name: "idx_on_survey_workflow_id_question_id_bf7c100f9f"
  end

  create_table "responses", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.bigint "question_id", null: false
    t.text "text_value"
    t.decimal "numeric_value", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["survey_id", "question_id"], name: "index_responses_on_survey_id_and_question_id", unique: true
    t.index ["survey_id"], name: "index_responses_on_survey_id"
  end

  create_table "survey_notes", force: :cascade do |t|
    t.bigint "survey_id", null: false
    t.bigint "admin_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content_ciphertext"
    t.index ["admin_id"], name: "index_survey_notes_on_admin_id"
    t.index ["survey_id"], name: "index_survey_notes_on_survey_id"
  end

  create_table "survey_workflows", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_survey_workflows_on_name", unique: true
  end

  create_table "surveys", force: :cascade do |t|
    t.integer "feeling", null: false
    t.integer "stress_level", null: false
    t.float "sleep_hours", null: false
    t.text "symptoms"
    t.text "symptoms_ciphertext"
    t.string "symptoms_bidx"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "flagged", default: false
    t.string "flagged_reason"
    t.bigint "survey_workflow_id"
    t.bigint "patient_id"
    t.datetime "flagged_at"
    t.bigint "flagged_by_id"
    t.index ["flagged"], name: "index_surveys_on_flagged"
    t.index ["patient_id"], name: "index_surveys_on_patient_id"
    t.index ["symptoms_bidx"], name: "index_surveys_on_symptoms_bidx"
  end

  add_foreign_key "audit_logs", "admins"
  add_foreign_key "responses", "questions"
  add_foreign_key "responses", "surveys"
  add_foreign_key "survey_notes", "admins"
  add_foreign_key "survey_notes", "surveys"
  add_foreign_key "surveys", "admins", column: "flagged_by_id"
  add_foreign_key "surveys", "patients"
end
