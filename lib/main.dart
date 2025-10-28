import 'package:flutter/material.dart';
import 'package:languageselector/otpVerify.dart';
import 'package:languageselector/signup.dart';
import 'package:languageselector/welcomeScreen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) => const WelcomePage(), // Initial route
        '/Signup': (context) => const SignUpPage(), // Named route for login
        '/SignIn': (context) => const OtpVerify(), // Named route for login
      },
    );
  }
}
