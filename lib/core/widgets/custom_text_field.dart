import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? value;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }
}
