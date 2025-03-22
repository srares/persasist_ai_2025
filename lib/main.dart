import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_ai_assistant/hive_adapters/question.dart';
import 'quiz_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(QuestionAdapter());
  await Hive.openBox<Question>('questions');

  // Example of adding questions to the box
  var box = Hive.box<Question>('questions');
  // box.clear();
  if (box.isEmpty) {
    // Nivel Începător
    box.add(Question(question: "Ce este AI-ul?"));
    box.add(Question(question: "Dă un exemplu de utilizare a AI."));
    box.add(Question(question: "Ce este Machine Learning?"));
    box.add(Question(
        question: "Numește un limbaj de programare popular pentru AI."));
    box.add(Question(question: "Ce este un dataset în contextul AI?"));

    // Nivel Intermediar
    box.add(Question(question: "Ce este un model de regresie liniară?"));
    box.add(Question(question: "Ce înseamnă „overfitting” într-un model AI?"));
    box.add(Question(
        question:
            "Numește un tip de învățare care NU este considerat învățare AI."));
    box.add(Question(question: "Ce este o rețea neuronală artificială?"));
    box.add(Question(
        question: "Care este diferența dintre AI și Machine Learning?"));

    // Nivel Avansat
    box.add(
        Question(question: "Ce este un transformator (Transformer) în NLP?"));
    box.add(
        Question(question: "Cum funcționează algoritmul Gradient Descent?"));
    box.add(Question(
        question:
            "Care este scopul unei funcții de activare într-o rețea neuronală?"));
    box.add(
        Question(question: "Ce este un GAN (Generative Adversarial Network)?"));
    box.add(Question(
        question: "Cum funcționează Attention Mechanism în modelele de NLP?"));
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QuizPage(),
    );
  }
}
