import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/service/auth_service.dart';
import '../../core/service/firestore_service.dart';
import '../../core/models/user_model.dart';
import '../widgets/text_input.dart';
import '../widgets/button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    _showLoadingDialog();

    User? user = await _authService.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _fullNameController.text.trim(),
      _nicController.text.trim(),
    );

    Navigator.pop(context); // Close loading dialog

    if (user != null) {
      await _firestoreService.saveUser(
        UserModel(
          uid: user.uid,
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          nic: _nicController.text.trim(),
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error signing up. Please try again.")),
      );
    }
  }

  Future<void> _signUpWithGoogle() async {
    _showLoadingDialog();
    User? user = await _authService.signInWithGoogle();
    Navigator.pop(context);

    if (user != null) {
      await _firestoreService.saveUser(
        UserModel(
          uid: user.uid,
          fullName: user.displayName ?? 'No Name',
          email: user.email ?? '',
          nic: 'Not set',
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error signing up with Google.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 10, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo or Illustration
              Image.asset(
                'assets/images/loginScreen.png',
                height: 180,
                width: 180,
              ),
              const SizedBox(height: 5),

              // Title
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 30,
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
              const SizedBox(height: 30),

              // Full Name
              CustomTextInput(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 15),

              // NIC
              CustomTextInput(
                controller: _nicController,
                label: 'NIC',
                icon: Icons.perm_identity,
                validator: (value) => value!.isEmpty ? 'Enter your NIC' : null,
              ),
              const SizedBox(height: 15),

              // Email
              CustomTextInput(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter your email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password
              CustomTextInput(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 15),

              // Confirm Password
              CustomTextInput(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Confirm your password';
                  if (value != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              CustomButton(
                text: 'Sign Up',
                onPressed: _signUp,
              ),
              const SizedBox(height: 20),

              // OR Divider
              const Text(
                'or sign up with',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),

              // Google Sign-In Button
              IconButton(
                iconSize: 40,
                onPressed: _signUpWithGoogle,
                icon: const Icon(Icons.g_mobiledata, color: Colors.red),
              ),
              const SizedBox(height: 20),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
