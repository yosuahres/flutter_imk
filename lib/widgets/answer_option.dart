import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String optionText;
  final VoidCallback onTap;

  const AnswerOption({
    Key? key,
    required this.optionText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(optionText),
    );
  }
}
