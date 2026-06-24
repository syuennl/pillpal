import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_wrapper.dart';
import '../../services/auth_service.dart';
import '../../widgets/login/auth_text_field.dart';
import '../../widgets/login/auth_scaffold.dart';
import '../../widgets/login/auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    return null;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please create a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (!mounted) return;

      // navigate to main wrapper
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('REGISTER ERROR CODE: ${e.code}');
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Try logging in.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else {
        message = 'Registration failed. Please try again.';
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
      title: "Create Account",
      errorMessage: _errorMessage,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // name
              AuthTextField(
                label: 'Full Name',
                hintText: 'Enter your full name',
                controller: _nameController,
                keyboardType: TextInputType.text,
                validator: _validateName,
              ),
              const SizedBox(height: 32),

              // email
              AuthTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 32),

              // password
              AuthTextField(
                label: 'Password',
                hintText: 'Create a password',
                controller: _passwordController,
                keyboardType: TextInputType.text,
                isPassword: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 32),

              // confirm password
              AuthTextField(
                label: 'Confirm Password',
                hintText: 'Confirm your password',
                controller: _confirmPasswordController,
                keyboardType: TextInputType.text,
                isPassword: true,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 32),

              // sign up button
              AuthButton(
                label: 'Create Account',
                onPressed: _handleRegister,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // terms agreement
              const Text(
                'By creating an account, you agree to our Terms & Conditions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
