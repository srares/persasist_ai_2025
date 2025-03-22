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
  List<String?> givenAnswers = []; // Store user's answers as strings

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  void loadQuestions() {
    var box = Hive.box<Question>('questions');
    setState(() {
      questions = box.values.toList();
      givenAnswers =
          List.filled(questions.length, null); // Initialize with nulls
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // All questions answered, now save answers to the questions
      saveAnswersToQuestions();
      sendQuestionsToAiStudio();
    }
  }

  void saveAnswersToQuestions() {
    var box = Hive.box<Question>('questions');
    for (int i = 0; i < questions.length; i++) {
      questions[i].answer = givenAnswers[i];
      box.putAt(i, questions[i]); // Use putAt with the index
    }
  }

  void sendQuestionsToAiStudio() {
    // Here you would implement the logic to send the questions and answers to AI Studio
    // For example, you might make an HTTP request to an API endpoint.
    // You can access the questions and answers like this:
    // for (var question in questions) {
    //   print("Question: ${question.question}, Answer: ${question.answer}");
    // }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Întrebările au fost trimise"),
        content: const Text(
            "Întrebările și răspunsurile au fost trimise către AI Studio."),
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
      givenAnswers = List.filled(questions.length, null);
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
            // Text input for the answer
            TextField(
              onChanged: (value) {
                setState(() {
                  givenAnswers[currentQuestionIndex] = value;
                });
              },
              decoration: const InputDecoration(
                hintText: "Scrie răspunsul aici...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: givenAnswers[currentQuestionIndex] == null ||
                      givenAnswers[currentQuestionIndex]!.isEmpty
                  ? null
                  : nextQuestion,
              child: Text(
                currentQuestionIndex == questions.length - 1
                    ? "Trimite la AI Studio"
                    : "Următoarea întrebare",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
