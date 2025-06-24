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
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      child: Text(optionText),
    );
  }
}
