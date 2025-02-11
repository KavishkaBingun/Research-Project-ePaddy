import 'package:flutter/material.dart';
import '../widgets/text_input.dart'; // Import the text input widget
import '../widgets/button.dart'; // Import the button widget

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        //elevation: 0,
        // backgroundColor: Colors.transparent, // Transparent AppBar
      ),
      body: SingleChildScrollView(  // Make the screen scrollable
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add image at the top of the screen
            Image.asset(
              'assets/images/loginScreen.png', // Path to your image
              height: 200, // Adjust the height of the image
              width: 200, // Adjust the width of the image
            ),
            const SizedBox(height: 5),
            // Title and Subtitle
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create an account to continue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

            // Full Name TextField
            const CustomTextInput(
              label: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            // NIC TextField
            const CustomTextInput(
              label: 'NIC',
              icon: Icons.perm_identity,
            ),
            const SizedBox(height: 20),

            // Email TextField
            const CustomTextInput(
              label: 'Email',
              icon: Icons.email,
            ),
            const SizedBox(height: 20),

            // Password TextField
            const CustomTextInput(
              label: 'Password',
              icon: Icons.lock,
              obscureText: true, // Password field with hidden text
            ),
            const SizedBox(height: 20),

            // Confirm Password TextField
            const CustomTextInput(
              label: 'Confirm password',
              icon: Icons.lock,
              obscureText: true, // Password field with hidden text
            ),
            const SizedBox(height: 20),

            // Sign Up Button
            CustomButton(
              text: 'Sign Up',
              onPressed: () {
                // Handle Sign Up action
              },
            ),
            const SizedBox(height: 20),

            // "or sign up with" section
            const Text(
              'or sign up with',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // Social Login Buttons (Facebook & Google)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    // Handle Facebook login
                  },
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                ),
                IconButton(
                  onPressed: () {
                    // Handle Google login
                  },
                  icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Already have an account? Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    // Navigate to the login screen
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Log in',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
