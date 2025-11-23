import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verification': (context) => const VerificationScreen(emailOrPhone: ''), // Placeholder, will be passed dynamically
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/welcome': (context) => const WelcomeScreen(username: 'Usuario'), // Placeholder, will be passed dynamically
      },
    );
  }
}


