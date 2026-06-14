import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/chat/models/chat_message.dart';

class GeminiClient {
  static const String _systemPrompt = '''
You are a highly professional, personalized fitness and wellness coach named "Aegis". 
Your goal is to guide the user in workouts, nutrition, hydration, and general recovery.
You have a special superpower: you can render interactive, functional, and reactive UI cards (GenUI) directly in the chat to help the user track their goals, log workouts, set timers, and calculate metrics.

You MUST ALWAYS respond with a JSON object that matches this schema:
{
  "text": "Your conversational message to the user here. Keep it brief, encouraging, and clear.",
  "widget": {
    "type": "widget_type_string",
    "data": { ... widget specific fields ... }
  } // or null if no widget is needed
}

When deciding to return a widget, choose one of the following exact specifications:

1. Water Tracker ("type": "water_tracker")
   Use when the user mentions drinking water, wanting to track water, or starting a hydration goal.
   Data fields:
   - "targetDailyMl": number (e.g., 2500)
   - "currentMl": number (the amount they just drank or want to start with, e.g., 500)

2. Workout Logger ("type": "workout_logger")
   Use when the user asks for a workout plan, wants to log an exercise, or asks for routines.
   Data fields:
   - "workoutName": string (e.g., "Leg Day Hypertrophy")
   - "exercises": array of objects:
     - "name": string (e.g., "Barbell Squat")
     - "sets": number (e.g., 4)
     - "reps": number (e.g., 10)
     - "weightKg": number (e.g., 60.0)

3. Calorie & Macro Tracker ("type": "macro_tracker")
   Use when the user logs food, asks about meal macros, or wants to check daily calories.
   Data fields:
   - "mealName": string (e.g., "Post-Workout Protein Oats")
   - "calories": number (e.g., 450)
   - "protein": number (in grams, e.g., 30)
   - "carbs": number (in grams, e.g., 55)
   - "fat": number (in grams, e.g., 10)

4. Fitness Timer ("type": "fitness_timer")
   Use when the user mentions rest intervals, planks, tabata, or wanting to set a timer.
   Data fields:
   - "durationSeconds": number (e.g., 90)
   - "label": string (e.g., "Plank Challenge" or "Rest Break")

5. BMI & Health Calculator ("type": "bmi_calculator")
   Use when the user asks for their BMI, body fat estimation, or health stats.
   Data fields:
   - "heightCm": number (e.g., 175.0)
   - "weightKg": number (e.g., 78.0)

6. Progress Chart ("type": "progress_chart")
   Use when the user asks about progress, step count charts, weight history, or calorie logs.
   Data fields:
   - "chartType": string ("weight" | "steps" | "calories")
   - "title": string (e.g., "Weight Trend (Last 7 Days)")
   - "labels": array of strings (e.g., ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
   - "values": array of numbers (e.g., [78.5, 78.2, 78.3, 77.9, 78.0, 77.6, 77.5])

CRITICAL RULES:
1. Always respond in valid JSON. Do not include markdown code block wrapper (like ```json) in your actual response text; return ONLY the raw JSON string.
2. If the user request is just generic conversation, set "widget": null.
3. Be supportive and maintain a fitness coach persona.
''';

  final String apiKey;
  late final GenerativeModel _model;

  GeminiClient({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7,
      ),
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  Future<Map<String, dynamic>> generateResponse(List<ChatMessage> history, String userPrompt) async {
    try {
      final chatContents = <Content>[];

      // Convert history to Gemini API format (limit to last 10 messages to avoid large tokens)
      final recentHistory = history.length > 10 ? history.sublist(history.length - 10) : history;
      for (final msg in recentHistory) {
        if (msg.role == MessageRole.user) {
          chatContents.add(Content.text(msg.text));
        } else {
          // Re-create the JSON structure for assistant messages
          final assistantJson = {
            'text': msg.text,
            'widget': msg.widgetData != null
                ? {
                    'type': msg.widgetData!.type,
                    'data': msg.widgetData!.data,
                  }
                : null
          };
          chatContents.add(Content.model([TextPart(jsonEncode(assistantJson))]));
        }
      }

      // Add the final user prompt
      chatContents.add(Content.text(userPrompt));

      final response = await _model.generateContent(chatContents);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Received empty response from Gemini.');
      }

      // Parse output
      final Map<String, dynamic> parsed = jsonDecode(responseText);
      return parsed;
    } catch (e) {
      // Re-throw or wrap
      throw Exception('Failed to generate response: $e');
    }
  }

  /// High-quality mock system to fallback to when no API key is provided
  /// This keeps the app completely functional and demonstrates all capabilities
  static Map<String, dynamic> mockResponse(String userPrompt) {
    final lowerPrompt = userPrompt.toLowerCase();
    
    if (lowerPrompt.contains('water') || lowerPrompt.contains('drink') || lowerPrompt.contains('hydrate')) {
      int amount = 250;
      if (lowerPrompt.contains('500')) amount = 500;
      if (lowerPrompt.contains('1000') || lowerPrompt.contains('1l')) amount = 1000;
      
      return {
        "text": "Hydration is key to muscle recovery and performance! I've loaded a Water Tracker card for you. You can log water intake directly, and I'll keep your daily progress updated.",
        "widget": {
          "type": "water_tracker",
          "data": {
            "targetDailyMl": 2500,
            "currentMl": amount
          }
        }
      };
    } else if (lowerPrompt.contains('workout') || lowerPrompt.contains('exercise') || lowerPrompt.contains('leg') || lowerPrompt.contains('routine')) {
      String workoutName = "Leg Day Power";
      var exercises = [
        {"name": "Barbell Squats", "sets": 4, "reps": 10, "weightKg": 80.0},
        {"name": "Leg Press", "sets": 3, "reps": 12, "weightKg": 120.0},
        {"name": "Romanian Deadlifts", "sets": 3, "reps": 10, "weightKg": 60.0},
        {"name": "Calf Raises", "sets": 4, "reps": 15, "weightKg": 40.0}
      ];

      if (lowerPrompt.contains('hiit') || lowerPrompt.contains('cardio') || lowerPrompt.contains('quick')) {
        workoutName = "Quick HIIT Blast";
        exercises = [
          {"name": "Jumping Jacks", "sets": 3, "reps": 30, "weightKg": 0.0},
          {"name": "Burpees", "sets": 3, "reps": 10, "weightKg": 0.0},
          {"name": "Bodyweight Squats", "sets": 3, "reps": 20, "weightKg": 0.0},
          {"name": "Mountain Climbers", "sets": 3, "reps": 30, "weightKg": 0.0}
        ];
      } else if (lowerPrompt.contains('chest') || lowerPrompt.contains('push')) {
        workoutName = "Push Day Hypertrophy";
        exercises = [
          {"name": "Incline Dumbbell Press", "sets": 4, "reps": 8, "weightKg": 28.0},
          {"name": "Flat Bench Press", "sets": 3, "reps": 10, "weightKg": 70.0},
          {"name": "Cable Crossovers", "sets": 3, "reps": 12, "weightKg": 15.0},
          {"name": "Tricep Pushdowns", "sets": 4, "reps": 12, "weightKg": 25.0}
        ];
      }

      return {
        "text": "Here is a target-focused workout routine to smash your fitness goals! Use the checklist below to log your sets, adjust weights, and check off completed exercises as you go.",
        "widget": {
          "type": "workout_logger",
          "data": {
            "workoutName": workoutName,
            "exercises": exercises
          }
        }
      };
    } else if (lowerPrompt.contains('eat') ||
        lowerPrompt.contains('meal') ||
        lowerPrompt.contains('food') ||
        lowerPrompt.contains('calorie') ||
        lowerPrompt.contains('macro') ||
        lowerPrompt.contains('shake') ||
        lowerPrompt.contains('protein') ||
        lowerPrompt.contains('portaine')) {
      String mealName = "Meal Tracked";
      int cal = 450;
      int protein = 25;
      int carbs = 50;
      int fat = 15;

      if (lowerPrompt.contains('banana')) {
        mealName = "Fresh Banana";
        cal = 105; protein = 1; carbs = 27; fat = 0;
      } else if (lowerPrompt.contains('shake') ||
          lowerPrompt.contains('protein') ||
          lowerPrompt.contains('portaine')) {
        mealName = "Whey Protein Shake";
        cal = 160; protein = 30; carbs = 3; fat = 2;
      } else if (lowerPrompt.contains('chicken') || lowerPrompt.contains('rice')) {
        mealName = "Chicken Breast & White Rice";
        cal = 550; protein = 45; carbs = 65; fat = 8;
      }

      return {
        "text": "Great! Tracking nutrition is 70% of the battle. I've prepared a Calorie & Macro Tracker card representing your meal. You can see the macronutrient ratios and adjust them dynamically.",
        "widget": {
          "type": "macro_tracker",
          "data": {
            "mealName": mealName,
            "calories": cal,
            "protein": protein,
            "carbs": carbs,
            "fat": fat
          }
        }
      };
    } else if (lowerPrompt.contains('timer') || lowerPrompt.contains('rest') || lowerPrompt.contains('plank')) {
      int duration = 90;
      String label = "Rest Interval";
      if (lowerPrompt.contains('plank')) {
        duration = 60;
        label = "Plank Hold";
      } else if (lowerPrompt.contains('30')) {
        duration = 30;
      } else if (lowerPrompt.contains('60') || lowerPrompt.contains('1 minute')) {
        duration = 60;
      } else if (lowerPrompt.contains('120') || lowerPrompt.contains('2 minute')) {
        duration = 120;
      }

      return {
        "text": "Time under tension and rest management are crucial. I've spun up a custom Fitness Timer widget for you. Adjust the timer or press Play directly within the chat bubble!",
        "widget": {
          "type": "fitness_timer",
          "data": {
            "durationSeconds": duration,
            "label": label
          }
        }
      };
    } else if (lowerPrompt.contains('bmi') || lowerPrompt.contains('weight') && lowerPrompt.contains('height') || lowerPrompt.contains('fat')) {
      return {
        "text": "Let's check your body metrics. Adjust your height and weight on the interactive BMI Calculator below to calculate your body mass index and see your fitness category.",
        "widget": {
          "type": "bmi_calculator",
          "data": {
            "heightCm": 180.0,
            "weightKg": 75.0
          }
        }
      };
    } else if (lowerPrompt.contains('progress') || lowerPrompt.contains('chart') || lowerPrompt.contains('trend') || lowerPrompt.contains('steps')) {
      final isSteps = lowerPrompt.contains('steps');
      return {
        "text": isSteps 
            ? "Here is your steps trend. Keeping your neat (Non-Exercise Activity Thermogenesis) high is incredible for fat loss and cardiovascular health."
            : "Here is your progress chart. Tracking trends rather than day-to-day spikes helps maintain a positive mindset!",
        "widget": {
          "type": "progress_chart",
          "data": {
            "chartType": isSteps ? "steps" : "weight",
            "title": isSteps ? "Weekly Step Count" : "Weight Progress (Last 7 Days)",
            "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
            "values": isSteps 
                ? [8500.0, 10200.0, 9300.0, 11000.0, 7500.0, 12000.0, 10500.0]
                : [81.5, 81.2, 81.4, 80.9, 81.0, 80.7, 80.5]
          }
        }
      };
    } else {
      return {
        "text": "Hello! I'm Aegis, your AI Fitness Coach. I can help you program custom workouts, track macros, set timers, and analyze your metrics. \n\nTry asking me something like:\n• 'I drank 500ml water'\n• 'Give me a leg workout'\n• 'Log my protein shake'\n• 'Set a 1-minute plank timer'\n• 'Show my weight progress chart'",
        "widget": null
      };
    }
  }
}
