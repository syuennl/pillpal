import 'package:flutter/material.dart';
import 'package:pillpal/services/auth_service.dart';
import 'package:pillpal/utils/app_colours.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/login/auth_text_field.dart';
import '../../widgets/login/auth_scaffold.dart';
import '../../widgets/login/auth_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleSendCode() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().sendPasswordResetEmail(_emailController.text.trim());
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent'),
          backgroundColor: AppColours.primaryGreen,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else {
        message = 'Could not send reset email. Please try again.';
      }
      setState(() => _errorMessage = message);
    } catch (e) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot Password',
      errorMessage: _errorMessage,
      subtitle: 'Enter your email to receive a verification code',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // email
              AuthTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 32),

              // send code button
              AuthButton(
                label: 'Send Verification Email',
                onPressed: _handleSendCode,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
