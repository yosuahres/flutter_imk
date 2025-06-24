import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fp_imk/screens/edupage/quiz_screen.dart';


class ResultScreen extends StatefulWidget {
  final int score;

  const ResultScreen({Key? key, required this.score}) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    String feedback;
    if (widget.score == 50) {
      feedback = 'Perfect! You know your climate facts!';
    } else if (widget.score >= 30) {
      feedback = 'Nice work! You have a good understanding of climate issues.';
    } else {
      feedback = 'Keep going! Every bit of knowledge helps the planet.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your Score: ${widget.score}', style: TextStyle(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 10),
              Text('High Score: $_highScore', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Text(feedback, style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('Retake Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
