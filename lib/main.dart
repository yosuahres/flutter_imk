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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initializeNotification();
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
      'carbon': (context) => const CarbonTrackingScreen(),
      'recycle': (context) => const RecycleScreen(),
      'profile': (context) => const ProfileScreen(),
    });
  }
}