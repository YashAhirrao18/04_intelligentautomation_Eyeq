// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:cashmate/firebase_options.dart';
import 'package:cashmate/screens/auth/login_screen.dart';
import 'package:cashmate/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cashmate/widgets/splash_screen.dart';
import 'package:cashmate/screens/auth/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobMates',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(), // Default route
        '/signup': (context) => SignUpScreen(), // Route for the signup screen
        '/login': (context) => LoginScreen(), // Route for the login screen
        '/dashboard': (context) => DashboardScreen(
              employeeName: '',
            )
      },
    );
  }
}
