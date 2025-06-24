import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../widgets/question_widget.dart';
import '../../widgets/answer_option.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> _questions = [
    Question(
      imagePath: 'assets/deforestation.jpg',
      questionText: 'What environmental issue is depicted in this image?',
      options: ['Deforestation', 'Urbanization', 'Desertification', 'Flooding'],
      correctOptionIndex: 0,
    ),
    Question(
      imagePath: 'assets/coral_bleaching.jpg',
      questionText: 'What environmental issue is depicted in this image?',
      options: ['Overfishing', 'Ocean Acidification', 'Flooding', 'Coral Bleaching'],
      correctOptionIndex: 3,
    ),
    // Add more questions here
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == _questions[_currentQuestionIndex].correctOptionIndex) {
      _score += 10;
    }

    setState(() {
      _currentQuestionIndex++;
    });

    if (_currentQuestionIndex >= _questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: _score),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Climate Education Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            QuestionWidget(
              imagePath: currentQuestion.imagePath,
              questionText: currentQuestion.questionText,
            ),
            const SizedBox(height: 20),
            ...currentQuestion.options.asMap().entries.map((entry) {
              int idx = entry.key;
              String text = entry.value;
              return AnswerOption(
                optionText: text,
                onTap: () => _answerQuestion(idx),
              );
            }),
          ],
        ),
      ),
    );
  }
}
