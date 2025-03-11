import 'package:epaddy_mobile/ui/views/login_screen.dart';
import 'package:epaddy_mobile/ui/views/signup_screen.dart';
import 'package:flutter/material.dart';
import 'ui/views/splash_screen.dart'; // Add the path for Splash Screen
import 'ui/views/home_screen.dart';   // Add the path for Home Screen
import 'ui/theme/colors.dart';        // Add the path for colors

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ePaddy App',
      theme: ThemeData(
        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        useMaterial3: true,
      ),
      // Set SplashScreen as the initial screen
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(), // Define your home screen route
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen()
      },
    );
  }
}
