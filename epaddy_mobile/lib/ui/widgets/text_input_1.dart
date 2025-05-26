import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator; // Add validator parameter ✅

  const CustomTextInput({
    Key? key,
    required this.controller,
    required this.label,
    this.icon = Icons.text_fields,
    this.obscureText = false,
    this.validator, // Accept validator function ✅
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator, // Use validator in TextFormField ✅
    );
  }
}
