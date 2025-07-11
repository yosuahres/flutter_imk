import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF2E7D6E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, size: 60, color: Theme.of(context).iconTheme.color),
              SizedBox(height: 20),
              Text(
                'Welcome to Help & Support!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              SizedBox(height: 10),
              Text(
                'Find answers to common questions or contact our support team here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
