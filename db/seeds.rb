# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default admin users
puts 'Creating admin users...'

# Create a super admin user
super_admin = Admin.find_or_initialize_by(email: 'super@example.com')
super_admin.assign_attributes(
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Super',
  last_name: 'Admin',
  role: 'super_admin'
)
super_admin.save!
puts '- Created super admin: super@example.com / password123'

# Create a regular admin user
admin = Admin.find_or_initialize_by(email: 'admin@example.com')
admin.assign_attributes(
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Regular',
  last_name: 'Admin',
  role: 'admin'
)
admin.save!
puts '- Created regular admin: admin@example.com / password123'

# Create question templates
puts '\nCreating question templates...'

# Mental health question templates
mental_health_templates = [
  {
    title: 'Mood Assessment',
    content: 'How would you rate your mood today?',
    response_type: 'numeric_scale',
    category: 'Mental Health',
    options: { min: 1, max: 10, min_label: 'Very Poor', max_label: 'Excellent' },
    required: true,
    active: true
  },
  {
    title: 'Anxiety Level',
    content: 'Have you experienced anxiety in the past week?',
    response_type: 'yes_no',
    category: 'Mental Health',
    options: {},
    required: true,
    active: true
  },
  {
    title: 'Depression Screening',
    content: 'How often have you felt down or depressed in the last two weeks?',
    response_type: 'multiple_choice',
    category: 'Mental Health',
    options: { choices: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'] },
    required: true,
    active: true
  }
]

mental_health_templates.each do |template_attrs|
  template = QuestionTemplate.find_or_initialize_by(
    title: template_attrs[:title],
    category: template_attrs[:category]
  )
  template.assign_attributes(template_attrs)
  template.save!
  puts "- Created template: #{template.title}"
end

# Create a default survey workflow
puts '\nCreating default survey workflow...'
workflow = SurveyWorkflow.find_or_initialize_by(name: 'Mental Health Assessment')
workflow.assign_attributes(
  description: 'Standard mental health assessment with mood, anxiety, and depression screening',
  active: true
)
workflow.save!
puts "- Created workflow: #{workflow.name}"

# Add questions to the workflow
puts '\nAdding questions to workflow...'
QuestionTemplate.where(category: 'Mental Health').each_with_index do |template, index|
  question = template.to_question
  question.save!
  
  unless workflow.questions.include?(question)
    # Add the question to the workflow with position using the model method
    workflow.add_question(question, index + 1)
    puts "- Added question: #{question.content} (position: #{index + 1})"
  end
end

# Create sample patients for testing (with encrypted fields for HIPAA compliance)
puts '\nCreating sample patients...'

sample_patients = [
  {
    first_name: 'John',
    last_name: 'Doe',
    email: 'john.doe@example.com',
    phone_number: '555-123-4567',
    date_of_birth: '1985-05-15',
    gender: 'male',
    medical_record_number: 'MRN12345',
    status: 'active'
  },
  {
    first_name: 'Jane',
    last_name: 'Smith',
    email: 'jane.smith@example.com',
    phone_number: '555-987-6543',
    date_of_birth: '1990-10-20',
    gender: 'female',
    medical_record_number: 'MRN67890',
    status: 'active'
  },
  {
    first_name: 'Alex',
    last_name: 'Johnson',
    email: 'alex.johnson@example.com',
    phone_number: '555-456-7890',
    date_of_birth: '1978-03-25',
    gender: 'non-binary',
    medical_record_number: 'MRN54321',
    status: 'active'
  }
]

sample_patients.each do |patient_attrs|
  patient = Patient.find_or_initialize_by(email: patient_attrs[:email])
  patient.assign_attributes(patient_attrs)
  patient.save!
  puts "- Created patient: #{patient.full_name}"
end

# Create sample surveys with HIPAA-compliant data
puts '\nCreating sample surveys...'

# Get the first patient
patient = Patient.first

# Create a survey for the patient using the workflow
survey = Survey.create!(
  patient: patient,
  survey_workflow: workflow,
  feeling: 3,
  stress_level: 4,
  sleep_hours: 6,
  symptoms: 'Occasional headaches, trouble sleeping'
)

# Flag one survey for testing
survey.update!(
  flagged: true,
  flagged_reason: 'Potential risk factors identified',
  flagged_at: Time.current,
  flagged_by_id: super_admin.id
)

puts "- Created survey for #{patient.full_name} (flagged: #{survey.flagged})"

# Create an audit log entry for HIPAA compliance demonstration
AuditLog.create!(
  admin: super_admin,
  action: 'patient.view',
  auditable: patient,
  ip_address: '127.0.0.1',
  details: { reason: 'Initial patient assessment' }
)

puts "- Created audit log entry for HIPAA compliance demonstration"

puts "\nAPI Testing Instructions:"
puts "1. Login as admin using POST /api/v1/admin/login with:"
puts "   { \"admin\": { \"email\": \"admin@example.com\", \"password\": \"password123\" } }"
puts "2. Use the returned JWT token in the Authorization header for subsequent requests:"
puts "   Authorization: Bearer <token>"
puts "3. Test the admin endpoints as documented in the API documentation"
