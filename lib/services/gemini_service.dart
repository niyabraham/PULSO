import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/session_context.dart';
import '../models/ecg_summary.dart';

class GeminiService {
  // TODO: Replace with your actual key or use --dart-define=GEMINI_API_KEY=...
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''); 

  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<String> generateConsultation(
    SessionContext context,
    EcgSummary summary,
  ) async {
    if (_apiKey.isEmpty) {
      return "Error: Gemini API Key is missing. Please provide it via --dart-define=GEMINI_API_KEY=YOUR_KEY or hardcode it in gemini_service.dart.";
    }

    final prompt = _buildPrompt(context, summary);
    
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Unable to generate insights at this time.";
    } catch (e) {
      return "Error generating insights: $e";
    }
  }

  String _buildPrompt(SessionContext context, EcgSummary summary) {
    return '''
You are an expert cardiologist AI assistant named "Pulso AI".
Analyze the following ECG session data and user context to provide a brief, professional, and empathetic consultation report.

USER CONTEXT:
- Time of Day: ${context.timeOfDay}
- Activity Level: ${context.activityLevel.toString().split('.').last}
- Stress Level (1-5): ${context.stressScore}
- Recent Stimulants: ${context.stimulants ? "Yes" : "No"}
- Recent Nicotine: ${context.nicotine ? "Yes" : "No"}

ECG SESSION METRICS:
- Average Heart Rate: ${summary.averageHeartRate.toStringAsFixed(1)} BPM
- Total Beats (R-Peaks): ${summary.totalRPeaks}
- Duration: ${summary.durationSeconds} seconds

INSTRUCTIONS:
1. Provide a "Heart Rate Analysis": Is the HR normal for the given activity/stress/stimulants?
2. Provide a "stress & Lifestyle Impact" section: How might the reported stress/stimulants be affecting the heart rate?
3. Provide "Recommendations": 1-2 actionable tips based on the data.
4. If the HR is abnormally high (>100 resting) or low (<60 active), kindly suggest consulting a doctor, but disclaim you are an AI.
5. Keep the tone supportive and professional.
6. Return the response in Markdown format.
''';
  }
}
