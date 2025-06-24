import 'package:flutter/material.dart';

class FunFactScreen extends StatelessWidget {
  final String funFact;
  final VoidCallback onNext;

  const FunFactScreen({
    Key? key,
    required this.funFact,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Did You Know?')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              funFact,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onNext,
              child: const Text('Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}
