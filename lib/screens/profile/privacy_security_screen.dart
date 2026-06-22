import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../../widgets/common/custom_app_bar.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Privacy & Security',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColours.secondaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Your medication data is stored securely on your device. We do not share your personal health information with third parties without your explicit consent.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColours.fontBrown,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'What We Collect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColours.fontBrown,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Medication names, dosages, schedules, and adherence records to help you manage your medications effectively.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'How We Use It',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColours.fontBrown,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your data is used solely to provide medication reminders, track adherence, and generate health insights for you and your caregivers.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
