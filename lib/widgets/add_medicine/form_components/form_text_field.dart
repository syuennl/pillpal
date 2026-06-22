import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final String? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const FormTextField({
    super.key,
    required this.controller,
    this.hint,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.textboxGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[900]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[300],
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }
}
