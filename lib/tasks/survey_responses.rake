namespace :survey_responses do
  desc "Add sample responses to all surveys that don't have any"
  task add_sample_responses: :environment do
    puts "Adding sample responses to surveys..."
    
    # Get all surveys
    surveys = Survey.all
    puts "Found #{surveys.count} surveys"
    
    # Create questions if none exist
    if Question.count == 0
      puts "No questions found. Creating sample questions..."
      questions = [
        Question.create!(content: 'How are you feeling today?', response_type: 'numeric_scale'),
        Question.create!(content: 'Describe your symptoms', response_type: 'text'),
        Question.create!(content: 'Are you experiencing stress?', response_type: 'yes_no')
      ]
      puts "Created #{questions.count} sample questions"
    else
      questions = Question.limit(3)
      puts "Using #{questions.count} existing questions"
    end
    
    # Add responses to each survey
    surveys_updated = 0
    surveys.each do |survey|
      if survey.responses.empty?
        puts "Adding responses to survey ##{survey.id}"
        
        # Create sample responses for each question
        questions.each do |question|
          case question.response_type
          when 'numeric_scale'
            survey.responses.create!(question: question, numeric_value: rand(1..5))
          when 'text'
            survey.responses.create!(question: question, text_value: 'Sample response text')
          when 'yes_no', 'multiple_choice'
            survey.responses.create!(question: question, text_value: ['Yes', 'No', 'Maybe'].sample)
          end
        end
        
        surveys_updated += 1
      else
        puts "Survey ##{survey.id} already has #{survey.responses.count} responses"
      end
    end
    
    puts "Completed! Added responses to #{surveys_updated} surveys"
  end
end
