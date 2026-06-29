import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? hint;
  final String? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const FormTextField({
    super.key,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: AppColours.textboxGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColours.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColours.primaryRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColours.primaryRed,
            width: 1.5,
          ),
        ),
        suffixIcon: suffixIcon != null
            ? Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey[300],
                size: 20,
              )
            : null,
      ),
    );
  }
}
