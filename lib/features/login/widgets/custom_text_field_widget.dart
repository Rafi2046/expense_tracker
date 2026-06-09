import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final String? email;
  final String? password;
  final String? label;
  final String? hintText;

  const CustomTextFieldWidget({
    super.key,
    this.label,
    this.hintText,
    this.email,
    this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: email ?? '',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: password ?? '',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
