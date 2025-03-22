import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:personal_ai_assistant/hive_adapters/question.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  List<int?> selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() {
    var box = Hive.box<Question>('questions');
    setState(() {
      questions = box.values.toList();
      selectedAnswers = List.filled(questions.length, null);
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      calculateScore();
    }
  }

  void calculateScore() {
    int totalScore = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctAnswerIndex) {
        totalScore++;
      }
    }
    setState(() {
      score = totalScore;
    });
    showScoreDialog();
  }

  void showScoreDialog() {
    String level;
    if (score <= 5) {
      level = "Începător";
    } else if (score <= 10) {
      level = "Intermediar";
    } else {
      level = "Avansat";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Scor final: $score / ${questions.length}"),
        content: Text("Nivelul tău: $level"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              restartQuiz();
            },
            child: const Text("Reîncearcă"),
          ),
        ],
      ),
    );
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      selectedAnswers = List.filled(questions.length, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Test AI")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    Question currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Test AI")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Întrebarea ${currentQuestionIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(
                currentQuestion.options.length,
                (index) => RadioListTile<int>(
                  title: Text(currentQuestion.options[index]),
                  value: index,
                  groupValue: selectedAnswers[currentQuestionIndex],
                  onChanged: (value) {
                    setState(() {
                      selectedAnswers[currentQuestionIndex] = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedAnswers[currentQuestionIndex] == null
                  ? null
                  : nextQuestion,
              child: Text(
                currentQuestionIndex == questions.length - 1
                    ? "Finalizează Testul"
                    : "Următoarea întrebare",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
