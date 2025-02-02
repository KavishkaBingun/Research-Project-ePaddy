import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;

  const CustomTextInput({
    required this.label,
    required this.icon,
    this.obscureText = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: obscureText
            ? Icon(Icons.visibility_off)
            : null, // Show/hide visibility icon for password field
        border: UnderlineInputBorder(), // Only bottom border
      ),
    );
  }
}
