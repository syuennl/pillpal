import 'package:flutter/material.dart';
import '/utils/app_colours.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isPassword;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _showPassword = false; // only used when isPassword == true

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColours.fontBrown.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),

        // field
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? !_showPassword : false,
          validator: widget.validator,
          style: const TextStyle(fontSize: 15),

          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            fillColor: Colors.white,
            filled: true,

            enabledBorder: _border(Colors.grey[300]!, 1.0),
            focusedBorder: _border(AppColours.primaryGreen, 1.5),
            errorBorder: _border(AppColours.primaryRed, 1.0),
            focusedErrorBorder: _border(AppColours.primaryRed, 1.5),
            errorStyle: const TextStyle(
              color: AppColours.primaryRed,
              fontSize: 12,
            ),

            // show/hide toggle only for password fields
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[400],
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
