import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../main_wrapper.dart';
import 'forgot_password_screen.dart';
import '../../widgets/login/auth_text_field.dart';
import '../../widgets/login/auth_scaffold.dart';
import '../../widgets/login/auth_button.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    // empty
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    // check format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    // empty
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    // length check
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // navigate to main wrapper if login successful
      Navigator.pushAndRemoveUntil( // .push but for auth
        context,
        MaterialPageRoute(builder: (context) => const MainWrapper()), // push main wrapper onto stack
        (route) => false, // remove all screens tht came bfr to prevent back btn frm navigating user back to login page
      );
    } on FirebaseAuthException catch (e) {
      String message;
      // Newer Firebase returns 'invalid-credential' for both wrong email
      // AND wrong password (email-enumeration protection). Handle all cases.
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        message = 'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      } else {
        message = 'Login failed. Please try again.';
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
      title: 'Welcome Back',
      errorMessage: _errorMessage,
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
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),

              // password
              AuthTextField(
                label: 'Password',
                hintText: 'Enter your password',
                controller: _passwordController,
                keyboardType: TextInputType.text,
                isPassword: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 32),

              // login button
              AuthButton(
                label: 'Login',
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // forgot password link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColours.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
