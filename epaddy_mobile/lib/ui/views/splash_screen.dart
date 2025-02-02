import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/splashScreen.png', // Correct image path
            fit: BoxFit.cover,
          ),
          // Black Overlay with some opacity
          Container(
            color: Colors.black.withOpacity(0.5), // Adjust opacity for better text visibility
          ),
          // Overlay for Title and Button
          Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center title vertically
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title Section (Centered)
               SizedBox(height: 200),
              Column(
                children: [
                  Text(
                    'WELCOME',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  SizedBox(height: 10), // Space between title lines
                  Text(
                    'ePaddy',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                    ),
                  ),
                ],
              ),
              // Add more space between the title and button
              SizedBox(height: 300), // This increases the space between the title and button
              // Button at the bottom
              Padding(
                padding: const EdgeInsets.all(20.0), // Padding for button
                child: CustomButton(
                  text: 'Get Started',
                  onPressed: () {
                    // Navigate to the next screen
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
