//lib
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fp_imk/service/notification_service.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:fp_imk/providers/theme_provider.dart'; // Import theme provider

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
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          initialRoute: 'login',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF609966),
              foregroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF0F2F0),
            cardColor: const Color(0xFFC5E1A5),
            // Define other light theme properties
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF386641),
              foregroundColor: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFF333333),
            cardColor: const Color(0xFF4F4F4F),
            // Define other dark theme properties
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
      },
    );
  }
}
