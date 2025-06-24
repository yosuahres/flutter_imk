//lib
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fp_imk/service/notification_service.dart';

//pages
import 'package:fp_imk/screens/home.dart';
import 'package:fp_imk/screens/auth/login.dart';
import 'package:fp_imk/screens/auth/register.dart';
import 'package:fp_imk/screens/weather_page.dart';
import 'package:fp_imk/screens/carbonpage/carbon_tracking_page.dart';
import 'package:fp_imk/screens/recyclepage/recycle.dart';
import 'package:fp_imk/screens/profile.dart';
import 'package:fp_imk/screens/edupage/quiz_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initializeNotification();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'login',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF609966),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F2F0),
        cardColor: const Color(0xFFC5E1A5),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        // Define other light theme properties
      ),
      routes: {
        'home': (context) => const HomeScreen(),
        'weather': (context) => const WeatherPage(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'carbon': (context) => const CarbonTrackingScreen(),
        'recycle': (context) => const RecycleScreen(),
        'profile': (context) => const ProfileScreen(),
        'education': (context) => const QuizScreen(),
      },
    );
  }
}
