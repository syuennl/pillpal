import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/profile/help_support_card_shell.dart';
import '../../utils/faq_constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      appBar: const CustomAppBar(title: 'Help & Support', showBackButton: true),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // contact support
              HelpSupportCardShell(
                icon: Icons.mail_outline,
                title: 'Contact Support',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        'Email us at:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 8),

                      Text(
                        'support@medapp.com',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColours.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FAQs
              HelpSupportCardShell(
                icon: Icons.quiz_outlined,
                title: 'Frequently Asked Questions',
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faqConstants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final faq = faqConstants[index];
                    return Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: ExpansionTile(
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColours.fontBrown,
                            ),
                          ),

                          iconColor: Colors.grey,
                          collapsedIconColor: Colors.grey,
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              faq['answer']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
