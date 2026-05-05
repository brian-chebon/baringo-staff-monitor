import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final String? initialValue;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.onSaved,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.initialValue,
    this.keyboardType,
    this.controller,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: controller == null ? initialValue : null,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
    );
  }
}
