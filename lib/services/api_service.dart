import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:personal_ai_assistant/hive_adapters/question.dart';

class ApiService {
  static final ApiService _singleton = ApiService._internal();
  factory ApiService() {
    return _singleton;
  }

  ApiService._internal();
  final String apiKey = "AIzaSyBvaEtKxH63xONnASPtRC3I6MByJJCAa8c";
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  Future<Map<String, dynamic>> sendQuestionsAndAnswers(
      List<Question> questions) async {
    try {
      // Prepare the prompt for Gemini
      String prompt =
          "Analizează următoarele întrebări și răspunsuri despre AI și acordă un scor din 100. De asemenea, determină nivelul utilizatorului (Începător, Intermediar, Avansat) pe baza răspunsurilor. Răspunde strict în formatul următor:\n\nScor: XX/100\nNivel: Începător/Intermediar/Avansat\n\n";
      for (int i = 0; i < questions.length; i++) {
        prompt += "Întrebare ${i + 1}: ${questions[i].question}\n";
        prompt += "Răspuns: ${questions[i].answer}\n\n";
      }

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      };

      // Make the API call
      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Extract the score and level from the response
        final String responseText =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        debugPrint("Response: $responseText");
        final Map<String, dynamic> result = extractScoreAndLevel(responseText);
        return result;
      } else {
        throw Exception(
            "Failed to get response from Gemini API: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error during API call: $e");
    }
  }

  Map<String, dynamic> extractScoreAndLevel(String responseText) {
    int score = 0;
    String level = "Necunoscut";

    // Extract the score
    final scoreMatch = RegExp(r"Scor: (\d+)").firstMatch(responseText);
    if (scoreMatch != null) {
      score = int.parse(scoreMatch.group(1)!);
    }

    // Extract the level
    final levelMatch = RegExp(r"Nivel: (Începător|Intermediar|Avansat)")
        .firstMatch(responseText);
    if (levelMatch != null) {
      level = levelMatch.group(1)!;
    }

    return {"score": score, "level": level};
  }
}
