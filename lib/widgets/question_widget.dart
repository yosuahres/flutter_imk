import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final String imagePath;
  final String questionText;

  const QuestionWidget({
    Key? key,
    required this.imagePath,
    required this.questionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imagePath, height: 200),
        SizedBox(height: 20),
        Text(
          questionText,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
