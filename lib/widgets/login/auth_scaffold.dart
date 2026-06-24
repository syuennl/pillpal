import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String? subtitle; // null on login/register, set on forgot/reset
  final String? errorMessage;
  final List<Widget> children; // the fields + buttons specific to each screen

  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.errorMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      body: SafeArea(
        child: Stack(
          children: [
            // back button
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColours.fontBrown,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColours.fontBrown,
                      ),
                    ),

                    if (subtitle != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18), 
                    
                    // error message
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColours.tertiaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColours.primaryRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),

                    ...children,
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
