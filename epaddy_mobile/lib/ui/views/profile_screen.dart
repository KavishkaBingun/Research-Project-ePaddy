import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/service/firestore_service.dart';
import '../../core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserModel? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // 🔹 Fetch User Data from Firestore
  Future<void> _fetchUserDetails() async {
    setState(() => _isLoading = true);
    final userData = await _firestoreService.getCurrentUser();
    if (userData != null) {
      setState(() {
        _user = userData;
        _nameController.text = userData.fullName;
        _nicController.text = userData.nic;
      });
    }
    setState(() => _isLoading = false);
  }

  // 🔹 Update Profile (Name & NIC)
  Future<void> _updateProfile() async {
    if (_user == null) return;

    setState(() => _isLoading = true);
    await _firestoreService.updateUserProfile(_nameController.text, _nicController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
    setState(() => _isLoading = false);
  }

  // 🔹 Change Password
  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter password details")));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    setState(() => _isLoading = true);
    final result = await _firestoreService.updateUserPassword(_passwordController.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ?? "Password update failed!")));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔹 User Email (Read-Only)
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        hintText: _user?.email ?? "Loading...",
                      ),
                    ),


                    const SizedBox(height: 20),

                    // 🔹 Editable Fields for Name & NIC
                    _buildTextField("Full Name", _nameController),
                    const SizedBox(height: 10),
                    _buildTextField("NIC", _nicController),

                    const SizedBox(height: 20),

                    // 🔹 Update Profile Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _updateProfile,
                      child: const Text("Update Profile", style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: 30),

                    // 🔹 Change Password Section
                    const Text("Change Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildTextField("New Password", _passwordController, obscureText: true),
                    const SizedBox(height: 10),
                    _buildTextField("Confirm Password", _confirmPasswordController, obscureText: true),

                    const SizedBox(height: 20),

                    // 🔹 Update Password Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _changePassword,
                      child: const Text("Change Password", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // 🔹 Custom Text Field Widget
  Widget _buildTextField(String label, TextEditingController? controller, {bool enabled = true, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
