import 'package:fp_imk/screens/home.dart';
import 'package:fp_imk/screens/login.dart';
import 'package:fp_imk/screens/register.dart';
import 'package:fp_imk/pages/weather_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: 'login', routes: {
      'home': (context) => const HomeScreen(),
      'weather': (context) => const WeatherPage(),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
    });
  }
}