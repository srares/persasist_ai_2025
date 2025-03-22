import 'package:flutter/material.dart';
import 'quiz_page.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Imaginea
              Image.asset(
                'images/onboarding_image.png',
                height: 200,
              ),
              const SizedBox(height: 20),

              // Titlul
              const Text(
                'AI Mentor',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),

              // Textul descriptiv
              const Text(
                'Pregătește-te de un test rapid, de doar 15 întrebări, care ne va ajuta să înțelegem mai bine nivelul tău actual de cunoștințe.\n\n'
                    'În urma testului, vei fi încadrat într-un nivel specific, iar aplicația îți va recomanda conținut personalizat, adaptat nevoilor tale de învățare.\n\n'
                    'Pregătește-te să-ți testezi cunoștințele și să descoperi noi orizonturi!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 60),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }