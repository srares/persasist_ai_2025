import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:personal_ai_assistant/hive_adapters/module.dart';
import 'package:personal_ai_assistant/hive_adapters/question.dart';
import 'package:personal_ai_assistant/hive_adapters/result.dart'; // Import the Result model
import 'package:personal_ai_assistant/modules_page.dart';
import 'package:personal_ai_assistant/services/api_service.dart';
import 'package:personal_ai_assistant/widgets/common_widgets.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  List<String?> givenAnswers = []; // Store user's answers as strings

  final TextEditingController answerController = TextEditingController();
  final ApiService apiService = ApiService(); // Initialize the API service
  Result? savedResult; // Add a variable to store the saved result

  @override
  void initState() {
    super.initState();
    loadQuestions();
    loadResult(); // Load the result when the page initializes
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
      answerController.clear();
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

  void sendQuestionsToAiStudio() async {
    try {
      final result = await apiService.sendQuestionsAndAnswers(questions);
      final int score = result['score'];
      final String level = result['level'];

      var resultsBox = Hive.box<Result>('results');
      resultsBox.clear();
      resultsBox.add(Result(score: score, level: level));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Rezultatul Testului",
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ai obținut un scor de: $score / 100",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Nivelul tău de cunoștine este: $level",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.red[200]!),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    restartQuiz();
                  },
                  child: const Text("Reîncearcă"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.green[200]!),
                  ),
                  onPressed: () async {
                    await apiService.generateStudyModules(
                        level, questions); // Stochează contextul original
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ModulesPage()));
                  },
                  child: const Text("Am înțeles"),
                ),
              ],
            )
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Eroare"),
          content: Text("A apărut o eroare: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      givenAnswers = List.filled(questions.length, null);
    });
  }

  void loadResult() {
    var resultsBox = Hive.box<Result>('results');
    if (resultsBox.isNotEmpty) {
      setState(() {
        savedResult = resultsBox.getAt(0); // Get the first result
      });
    } else {
      setState(() {
        savedResult = null; // Set savedResult to null if the box is empty
      });
    }
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
    dynamic width = MediaQuery.of(context).size.width;
    dynamic height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar(title: "AI Mentor"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Întrebarea ${currentQuestionIndex + 1}/${questions.length}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.02),
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.1, horizontal: 10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff205781),
                      Color(0xff4F959D),
                      Color(0xff98D2C0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    currentQuestion.question,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Text input for the answer
              TextField(
                controller: answerController,
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
      ),
    );
  }
}
