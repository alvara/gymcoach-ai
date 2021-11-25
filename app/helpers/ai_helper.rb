module AiHelper
  # determine the users intention based on their message

  # request AI to generate a generic reply based on user input
  def ai_general_answer(user_message_content)
    if user_message_content.present?
     client = OpenAI::Client.new
     client.files.upload(parameters: { file: 'db/data.jsonl', purpose: 'search' })
     response = client.answers(parameters: {
       documents: ["I bench press 3 sets of 25kg at 8 reps on july 7th, 2020 and it was easy.", "I barbell squat 20kg twice, but failed on the third set on november 1st, 2021. But it was hard."],
       question: user_message_content,
       model: "davinci",
       examples_context: "This is a gym coach, very friendly, and will respond always to keep user in the gym to do their workout",
       examples: [

        # silly
        ["lol", "Whats so funny?"],
        
        # opinions
        ["just think this is cool", "Thanks. How about we workout?"],
        

        # short
        ["yes", "awesome."],
        
         # distractions
         ["Can we eat soon?", "Let's finish a workout first. "],

         # introductions
         ["hello", "hi #{current_user.name}, how you feeling today?"],

         # negative feelings
         ["not yet ready to workout..", "Don't worry. Most important thing is to show up in the gym. Let's do a quick workout then?"],
         ["no!", "It will be ok, let's workout quickly then."],

         # exhaustion
         ["im tired", "You can rest for a bit longer, would you like to continue the workout today?"],
        ],
       max_tokens: 20,
       stop: ['\n', '===', '---']
     })

       ai_hash = JSON.parse response.to_s
       ai_hash["answers"].each do |answer|
        # receive just a basic answer
        Message.create!({
          category: "receive",
          content: answer
          })
        end
      end
    end

  # request AI to generate a new workout card based on user requests
  def ai_create_workout(user_query)
    arr = []
    exercises = ['glute bridge','lying hip abduction','barbell hip thrust','rope cable crunch','wood chops','planks','lying leg curl','sumo deadlift','standard deadlift','romanian deadlift','sumo squat','deadlift rack pull','dumbbell lunges','leg extensions (single leg)','leg extensions (both legs)','standard barbell squat','ass to grass squats','front squat','bulgarian barbell squat','sumo squat','goblin squats','lateral side step squats','jump squats','sitting calf raise','standing calf raise','smith machine barbell row','weighted pullups','standard pullups','hammergrip pullups','chinups','wide grip pullups','pulldown machine - narrow grip attachment','pulldown machine - single bar','pulldown machine - dual static position','row machine- underhand grip','row machine - overhand grip','row machine - hammer grip','Rope machine lat pullover','dumbbell single arm row','dumbbell supinated bicep curls','alternating dumbbell hammerhead curls','incline bench dumbbell curls','EZ bar standing bicep curl','preacher curl machine','spider curl','barbell bentover curl','dumbbell wrist curls','chest fly machine','chest press machine','smith machine bench press','weighted dips','chest fly machine straight arm','standard rope chest flies','Rope machine kneeling chest abductions','rope bench press (long handles)','barbell bench press','barbell incline bench','incline dumbbell bench press','standard pushups','archer pushups','diamond pushups','dumbbell lateral raises','hanging dumbbell lateral raises','side-lying bench lateral raise','single arm dumbbell lateral raise','shoulder shrugs','dumbbell reverse fly','dumbbell front raises','dumbbell shoulder military press','handstand pushups','wide pushups','straight bar pushdown','tricep dumbbell kickbacks','EZ bar skull crusher','close grip bench']

    client = OpenAI::Client.new
    response = client.answers(parameters: {
      documents: exercises,
      question: user_query,
      model: "davinci", 
      examples_context: "find the 3 best exercises for the user to perform for their workout",
      examples: [
        ["I want to work my abs", "ab roller, rope crunches, leg lifts"],
        ["What should I do for a bigger chest?", "bench press, cable flies, fly machine"],
        ["What muscles are used in deadlift?", "hamstrings,glutes,erector spinae"],
        ["I dont want to do dumbbell bench press.", "dumbbell flys,rope chest abduction,chest press machine"],
        ["I want to work on chest. Can you suggest something that only uses dumbbells for today? I dont want to do dumbbell incline bench press", "dumbbell bench press, dumbbell flys, dumbbell supinated bench press"]
      ],
      max_tokens: 25,
      temperature: 0,
      stop: ['\n', '===', '---']
    })

    reply = JSON.parse response.to_s
    reply = reply["answers"].first
    workout = Workout.new(name: 'Workout 1',
      day: Date.today,
      user: current_user)
    # each answer is an exercise name
    reply.split(', ').each_with_index do |exercise_name, index|
      exercise = Exercise.where(name: exercise_name).first # to improve
      3.times do
        WorkoutSet.create(nb_of_reps: 5,
                                      order_index: index,
                                      exercise: exercise,
                                      workout: workout,
                                      weight: 20)
      end
    end
    workout.save
    Message.create!({
      category: "card_workout",
      workout: workout
                    })
  end

   # request AI to get top X exercises based on user needs
   def ai_find_muscles_for_exercise(user_query)
    if true
     arr = []
     muscles = ['hamstrings', 'glutes', 'pecs', 'deltoids', 'quads', 'calves', 'biceps', 'erector spinae' 'triceps', 'forearms', 'shoulders', 'traps', 'abs', 'obliques', 'trapezius', 'lats', 'glutes']

     client = OpenAI::Client.new
     response = client.answers(parameters: {
       documents: muscles,
       question: user_query,
       model: "davinci", #babbage
       examples_context: "identify at maximum 3 muscles used in an exercise",
       examples: [
         ["What muscles are used in bench press?", "pecs,triceps,deltoids"],
         ["What muscles are used in squats?", "quads,glutes,hamstrings"],
         ["What muscles are used in deadlift?", "hamstrings,glutes,erector spinae"],
         ["I want to work my ass", "Do you have preference for any exercise to do?"]
       ],
       max_tokens: 25,
       temperature: 0,
       stop: ['\n', '===', '---']
     })

     reply = JSON.parse response.to_s
     reply = reply["answers"][0]
     raise
     return reply
    end
  end

  def ai_find_exercise_for_muscle(user_query)
    arr = []
    exercises = ['glute bridge','lying hip abduction','barbell hip thrust','rope cable crunch','wood chops','planks','lying leg curl','sumo deadlift','standard deadlift','romanian deadlift','sumo squat','deadlift rack pull','dumbbell lunges','leg extensions (single leg)','leg extensions (both legs)','standard barbell squat','ass to grass squats','front squat','bulgarian barbell squat','sumo squat','goblin squats','lateral side step squats','jump squats','sitting calf raise','standing calf raise','smith machine barbell row','weighted pullups','standard pullups','hammergrip pullups','chinups','wide grip pullups','pulldown machine - narrow grip attachment','pulldown machine - single bar','pulldown machine - dual static position','row machine- underhand grip','row machine - overhand grip','row machine - hammer grip','Rope machine lat pullover','dumbbell single arm row','dumbbell supinated bicep curls','alternating dumbbell hammerhead curls','incline bench dumbbell curls','EZ bar standing bicep curl','preacher curl machine','spider curl','barbell bentover curl','dumbbell wrist curls','chest fly machine','chest press machine','smith machine bench press','weighted dips','chest fly machine straight arm','standard rope chest flies','Rope machine kneeling chest abductions','rope bench press (long handles)','barbell bench press','barbell incline bench','incline dumbbell bench press','standard pushups','archer pushups','diamond pushups','dumbbell lateral raises','hanging dumbbell lateral raises','side-lying bench lateral raise','single arm dumbbell lateral raise','shoulder shrugs','dumbbell reverse fly','dumbbell front raises','dumbbell shoulder military press','handstand pushups','wide pushups','straight bar pushdown','tricep dumbbell kickbacks','EZ bar skull crusher','close grip bench']

    client = OpenAI::Client.new
    response = client.answers(parameters: {
      documents: exercises,
      question: user_query,
      model: "davinci", #babbage
      examples_context: "find only 3 best exercises for the user to perform for their workout",
      examples: [
        ["I want to work my abs", "ab roller, rope crunches, leg lifts"],
        ["What should I do for a bigger chest?", "bench press, cable flies, fly machine"],
        ["What muscles are used in deadlift?", "hamstrings,glutes,erector spinae"],
        ["I dont want to do dumbbell bench press.", "dumbbell flys,rope chest abduction,chest press machine"],
        ["I want to work on chest. Can you suggest something that only uses dumbbells for today? I dont want to do dumbbell incline bench press", "dumbbell bench press, dumbbell flys, dumbbell supinated bench press"]
      ],
      max_tokens: 25,
      temperature: 0,
      stop: ['\n', '===', '---']
    })

    reply = JSON.parse response.to_s
    reply = reply["answers"].first
    workout = Workout.new(name: 'Workout 1',
      day: Date.today,
      user: current_user)
    # each answer is an exercise name
    reply.split(', ').each_with_index do |exercise_name, index|
      exercise = Exercise.where(name: exercise_name).first # to improve
      3.times do
        WorkoutSet.create(nb_of_reps: 5,
                                      order_index: index,
                                      exercise: exercise,
                                      workout: workout,
                                      weight: 20)
      end
    end
    workout.save
    Message.create!({
      category: "card_workout",
      workout: workout
                    })
  end

  # ai will direct user query to appropriate method for intended processing
  def ai_direct_query(user_query)
    possible_queries = ['find_exercise', 'create_workout', 'create_exercise', 'update_set', 'general_answer']

    client = OpenAI::Client.new
    response = client.answers(parameters: {
      documents: possible_queries,
      question: user_query,
      model: "curie", # using curie to get more accurate results and cheaper
      examples_context: "determine the best action based on user query",
      examples: [
        # Patterns to create workouts
        ["I am tired today, can you make this workout easier?", "create_workout"],
        ["Can you remove benchpress from this workout?", "create_workout"],
        ["Can you make my workout shorter today?", "create_workout"],
        ["Give me a good chest exercise", "create_workout"],
        ["I want to work my abs", "create_workout"],
        
        # todo: Patterns to update workout sets
        # ["Someone is using the bench, can you find an alternative to benchpress?", "update_workout_set"],
        # ["Can you change benchpress to another exercise?", "update_workout_set"],
        ["Can you exchange benchpress in this workout?", "update_workout_set"],

        # Patterns to create a new station
        ["I want to try this new machine", "create_station"],
        ["There is a new machine here that I want to use", "create_station"],
        
        # Patterns to find a specific exercise or create it
        ["How can I do the benchpress", "find_exercise"],
        ["what seat level should i do for this exercise?", "find_exercise"],
        
        # Patterns to find a specific exercise or create it
        ["Tell me how to do squats", "find_exercise_for_muscle"],
        ["I want to work my abs, what muscles?", "find_exercise_for_muscle"],
        ["What should I do for a bigger chest?", "find_exercise_for_muscle"],

        # Patterns to find a specific exercise
        ["Hey what time is it?", "general_answer"],
        ["ok this is cool", "general_answer"],
        ["what is your name?", "general_answer"]
      ],
      max_tokens: 25,
      temperature: 0,
      stop: ['\n', '===', '---']
    })

    reply = JSON.parse response.to_s
    return reply["answers"].first
  end
end
