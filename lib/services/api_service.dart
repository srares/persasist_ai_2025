import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:personal_ai_assistant/hive_adapters/module.dart';
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

  Future<List<Module>> generateStudyModules(
      String level, List<Question> questions) async {
    try {
      int numberOfModules = 0;
      if (level == "Începător") {
        numberOfModules = 3;
      } else if (level == "Intermediar") {
        numberOfModules = 6;
      } else if (level == "Avansat") {
        numberOfModules = 10;
      } else {
        return []; // Return an empty list if the level is unknown
      }

      // Prepare the prompt for Gemini
      String prompt =
          "Generează $numberOfModules module de studiu pentru un utilizator de nivel $level în AI, bazându-te pe următoarele întrebări și răspunsuri:\n\n";
      for (int i = 0; i < questions.length; i++) {
        prompt += "Întrebare ${i + 1}: ${questions[i].question}\n";
        prompt += "Răspuns: ${questions[i].answer}\n\n";
      }
      prompt +=
          "Fiecare modul trebuie să conțină informații detaliate despre un subiect specific din AI. Răspunde strict în format JSON, cu următoarea structură:\n";
      prompt +=
          "```json\n[\n  {\n    \"title\": \"Titlul Modulului 1\",\n    \"information\": \"Informațiile detaliate despre modulul 1\"\n  },\n  {\n    \"title\": \"Titlul Modulului 2\",\n    \"information\": \"Informațiile detaliate despre modulul 2\"\n  },\n  // ... alte module\n]\n```\n";
      prompt += "Nu adăuga text suplimentar în afara JSON-ului.";

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
        final String responseText =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        debugPrint("Response: $responseText");
        // Check if the response is empty or null
        if (responseText.trim().isEmpty) {
          throw Exception("API returned an empty response.");
        }
        return extractModulesFromJson(responseText);
      } else {
        // Log the error response for debugging
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
        throw Exception(
            "Failed to get response from Gemini API: ${response.statusCode}");
      }
    } catch (e) {
      // Log the error for debugging
      debugPrint("Error generating study modules: $e");
      throw Exception("Error generating study modules: $e");
    }
  }

  List<Module> extractModulesFromJson(String responseText) {
    try {
      // First, try to clean up the response by looking for JSON array pattern
      // Using a simpler regex pattern that's valid
      final jsonMatch =
          RegExp(r'\[.*\]', dotAll: true).firstMatch(responseText);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0);
        debugPrint("Extracted JSON String: $jsonString");

        try {
          final List<dynamic> jsonArray = jsonDecode(jsonString!);
          debugPrint(
              "Successfully parsed JSON Array with ${jsonArray.length} items");

          List<Module> modules = jsonArray.map((json) {
            return Module(
              title: json['title'] as String,
              information: json['information'] as String,
            );
          }).toList();

          // Save modules to Hive box
          saveModulesToHive(modules);

          return modules;
        } catch (e) {
          debugPrint("Error parsing extracted JSON: $e");
          // If we can't parse the extracted JSON, create a fallback module
          return createFallbackModules(responseText);
        }
      } else {
        debugPrint("No JSON array pattern found in response");
        // If we can't find a JSON pattern, create a fallback module
        return createFallbackModules(responseText);
      }
    } catch (e) {
      debugPrint("Error in extractModulesFromJson: $e");
      // If any other error occurs, create a fallback module
      return createFallbackModules(responseText);
    }
  }

// Add this method to create fallback modules from the raw text
  List<Module> createFallbackModules(String responseText) {
    try {
      // Try to extract module-like content using regex patterns
      List<Module> modules = [];

      // Look for title-like patterns with simpler regex
      final titleMatches =
          RegExp(r'"title"\s*:\s*"([^"]+)"').allMatches(responseText);
      final infoMatches =
          RegExp(r'"information"\s*:\s*"([^"]+)"').allMatches(responseText);

      if (titleMatches.isNotEmpty && infoMatches.isNotEmpty) {
        // Try to pair titles with information
        final titles = titleMatches.map((m) => m.group(1)!).toList();
        final infos = infoMatches.map((m) => m.group(1)!).toList();

        for (int i = 0; i < titles.length && i < infos.length; i++) {
          modules.add(Module(
            title: titles[i],
            information: infos[i],
          ));
        }
      }

      // If we couldn't extract modules using regex, create a single module with the raw text
      if (modules.isEmpty) {
        // Split the text into chunks to create modules
        final chunks = responseText.split('\n\n');

        for (int i = 0; i < chunks.length; i++) {
          if (chunks[i].trim().isNotEmpty) {
            modules.add(Module(
              title: "Modul ${i + 1}",
              information: chunks[i].trim(),
            ));
          }
        }

        // If we still don't have modules, create one with the entire text
        if (modules.isEmpty) {
          modules.add(Module(
            title: "Conținut Educațional",
            information: responseText,
          ));
        }
      }

      // Save modules to Hive box
      saveModulesToHive(modules);

      return modules;
    } catch (e) {
      debugPrint("Error creating fallback modules: $e");

      // If all else fails, create a single error module
      List<Module> errorModules = [
        Module(
          title: "Eroare la procesarea conținutului",
          information:
              "Nu am putut procesa răspunsul API-ului. Eroare: $e\n\nRăspuns brut:\n$responseText",
        )
      ];

      // Save error modules to Hive box
      saveModulesToHive(errorModules);

      return errorModules;
    }
  }

  Future<void> saveModulesToHive(List<Module> modules) async {
    try {
      // Make sure the box is open
      if (!Hive.isBoxOpen('modules')) {
        await Hive.openBox<Module>('modules');
      }

      var modulesBox = Hive.box<Module>('modules');
      // modulesBox.clear(); // Clear previous modules

      // Add each module to the box
      for (var module in modules) {
        modulesBox.add(module);
      }

      debugPrint("Successfully saved ${modules.length} modules to Hive");
    } catch (e) {
      debugPrint("Error saving modules to Hive: $e");
    }
  }
}
