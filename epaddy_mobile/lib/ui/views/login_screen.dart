import 'package:epaddy_mobile/ui/widgets/button.dart';
import 'package:flutter/material.dart';
import '../widgets/text_input.dart'; // Import the text input widget

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        // title: const Text("Log In"),
        // elevation: 0,
        // backgroundColor: Colors.transparent, // Transparent AppBar
      ),
      body: SingleChildScrollView(  // Make the screen scrollable
        padding: const EdgeInsets.all(20),
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
              'Log In',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please sign in to continue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            
            // Use CustomTextInput for Email
            const CustomTextInput(
              label: 'Email',
              icon: Icons.email,
            ),
            const SizedBox(height: 20),
            
            // Use CustomTextInput for Password
            const CustomTextInput(
              label: 'Password',
              icon: Icons.lock,
              obscureText: true, // Password field with hidden text
            ),
            const SizedBox(height: 10),
            
            // Forgot Password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: const Text(
                  'Forgot Password',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Log In Button
            CustomButton(
                  text: 'Log in',
                  onPressed: () {
                    // Navigate to the next screen
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
            const SizedBox(height: 20),
             // "or sign in with" section
            const Text(
              'or sign in with',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            // Social Login Buttons
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
            const SizedBox(height: 10),
            
            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // Navigate to the sign-up screen
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    
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
