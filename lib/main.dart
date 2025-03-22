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
  if (box.isEmpty) {
    // Nivel Începător
    box.add(Question(
        question:
            "Ce înseamnă AI (Inteligență Artificială)?\n- A) Un tip de hardware\n- B) Sisteme care pot învăța și lua decizii\n- C) O bază de date mare\n- D) Un limbaj de programare"));
    box.add(Question(
        question:
            "Care dintre următoarele este un exemplu de AI?\n- A) Un motor de căutare precum Google\n- B) O foaie de calcul Excel\n- C) Un program care adună două numere"));
    box.add(Question(
        question:
            "Ce este Machine Learning?\n- A) Un sistem care învață din date pentru a face predicții\n- B) O metodă de stocare a datelor\n- C) Un limbaj de programare pentru AI"));
    box.add(Question(
        question:
            "Care dintre următoarele este un limbaj popular pentru AI?\n- A) Python\n- B) JavaScript\n- C) HTML"));
    box.add(Question(
        question:
            "Ce este un dataset în AI?\n- A) O colecție de date folosite pentru antrenarea unui model\n- B) Un fișier text\n- C) Un software AI"));

    // Nivel Intermediar
    box.add(Question(
        question:
            "Ce este un model de regresie liniară?\n- A) Un model care face predicții folosind o linie dreaptă\n- B) Un algoritm de clasificare\n- C) Un model non-liniar"));
    box.add(Question(
        question:
            "Ce este „overfitting” într-un model AI?\n- A) Modelul învață prea bine datele de antrenament și nu generalizează corect\n- B) Modelul nu învață bine și are performanțe slabe\n- C) Modelul învață doar o parte din date"));
    box.add(Question(
        question:
            "Care dintre următoarele NU este un tip de învățare AI?\n- A) Învățare supervizată\n- B) Învățare nesupervizată\n- C) Învățare biologică"));
    box.add(Question(
        question:
            "Ce este o rețea neuronală artificială?\n- A) O simulare a neuronilor biologici folosită în AI\n- B) O bază de date pentru AI\n- C) Un algoritm de sortare"));
    box.add(Question(
        question:
            "Care este diferența dintre AI și Machine Learning?\n- A) AI este un concept mai larg, iar Machine Learning este o subcategorie\n- B) Machine Learning este mai avansat decât AI\n- C) Machine Learning se bazează doar pe programare manuală"));

    // Nivel Avansat
    box.add(Question(
        question:
            "Ce este un transformator (Transformer) în NLP?\n- A) Un model de rețea neuronală folosit în procesarea limbajului natural\n- B) Un algoritm de clasificare\n- C) Un model de învățare nesupervizată"));
    box.add(Question(
        question:
            "Cum funcționează algoritmul Gradient Descent?\n- A) Minimizează eroarea ajustând treptat coeficienții modelului\n- B) Crește performanța modelului prin adăugarea de date\n- C) Găsește caracteristici importante în imagini"));
    box.add(Question(
        question:
            "Care este scopul unei funcții de activare într-o rețea neuronală?\n- A) Introduce non-liniaritate în model\n- B) Normalizează datele de intrare\n- C) Reduce dimensiunea datelor"));
    box.add(Question(
        question:
            "Ce este un GAN (Generative Adversarial Network)?\n- A) O tehnică folosită pentru a genera date noi similare cu datele de antrenament\n- B) Un algoritm de sortare rapidă\n- C) Un model de învățare nesupervizată"));
    box.add(Question(
        question:
            "Cum funcționează Attention Mechanism în modelele de NLP?\n- A) Permite modelului să se concentreze pe părți relevante ale intrării\n- B) Crește viteza de antrenare a modelului\n- C) Elimină datele irelevante automat"));
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
