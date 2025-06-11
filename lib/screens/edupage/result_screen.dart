import 'package:flutter/material.dart';
import 'package:fp_imk/screens/edupage/quiz_screen.dart';


class ResultScreen extends StatelessWidget {
  final int score;

  const ResultScreen({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String feedback;
    if (score == 100) {
      feedback = 'Excellent! You have a great understanding of climate issues.';
    } else if (score >= 70) {
      feedback = 'Good job! You have a solid grasp of climate topics.';
    } else {
      feedback = 'Keep learning! Climate education is vital for our planet.';
    }

    return Scaffold(
      appBar: AppBar(title: Text('Quiz Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Your Score: $score',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                feedback,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => QuizScreen()),
                  );
                },
                child: Text('Retake Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
