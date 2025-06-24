import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/question_model.dart';
import '../../widgets/question_widget.dart';
import '../../widgets/answer_option.dart';
import 'result_screen.dart';
import 'fun_fact_screen.dart';

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
      funFact: 'Deforestation contributes to habitat loss and accelerates climate change.',
    ),
    Question(
      imagePath: 'assets/coral_bleaching.jpg',
      questionText: 'What environmental issue is depicted in this image?',
      options: ['Overfishing', 'Ocean Acidification', 'Flooding', 'Coral Bleaching'],
      correctOptionIndex: 3,
      funFact: 'Coral bleaching happens when ocean temperatures rise and corals lose their color.',
    ),
    Question(
      imagePath: 'assets/plastic_pollution.jpg',
      questionText: 'What type of pollution is shown in this image?',
      options: ['Air Pollution', 'Plastic Pollution', 'Light Pollution', 'Thermal Pollution'],
      correctOptionIndex: 1,
      funFact: 'Plastic pollution kills marine animals and contaminates food chains.',
    ),
    Question(
      imagePath: 'assets/melting_ice.jpg',
      questionText: 'What environmental phenomenon is depicted in this image?',
      options: ['Rising Sea Levels', 'Earthquakes', 'Melting Ice Caps', 'Volcanic Eruption'],
      correctOptionIndex: 2,
      funFact: 'Melting ice caps driven primarily by rising global temperatures due to climate change. It contributes to rising sea levels and climate disruption.',
    ),
    Question(
      imagePath: 'assets/smog_city.jpg',
      questionText: 'Which environmental issue does this city suffer from?',
      options: ['Smog', 'Flooding', 'Drought', 'Tornado'],
      correctOptionIndex: 0,
      funFact: 'Smog is caused by pollutants from vehicles and industries and affects human health.',
    ),
    // Add more questions here
  ];

  // final List<String> _funFacts = [
  //   'Deforestation leads to the loss of trees, which are crucial for absorbing CO2.',
  //   'Coral bleaching happens when ocean temperatures rise and corals lose their color.',
  //   'Plastic pollution kills marine animals and contaminates food chains.',
  //   'Melting ice caps contribute to rising sea levels and climate disruption.',
  //   'Smog is caused by pollutants from vehicles and industries and affects human health.',
  //   // Match fun facts to your other questions in order
  // ];

  int _currentQuestionIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _questions.shuffle();
  }

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == _questions[_currentQuestionIndex].correctOptionIndex) {
      _score += 10;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FunFactScreen(
          funFact: _questions[_currentQuestionIndex].funFact,
          onNext: () {
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
            } else {
              Navigator.pop(context); // go back to QuizScreen for next question
            }
          },
        ),
      ),
    );
  }

  void _checkAndNavigateToResult() async {  // unused
    final prefs = await SharedPreferences.getInstance();
    final highScore = prefs.getInt('highScore') ?? 0;

    if (_score > highScore) {
      await prefs.setInt('highScore', _score);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(score: _score),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= _questions.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Climate Education Quiz')),
      body: Stack(
        children: [
          Padding(
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
          Positioned(
            bottom: 16,
            right: 16,
            child: Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
