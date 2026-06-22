import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class DiaryTipCard extends StatelessWidget {
  final String title;
  final String body;

  const DiaryTipCard({
    super.key,
    this.title = 'Tip for Your Visit',
    this.body =
        'Use these notes to help you remember important questions and experiences to discuss with your doctor during your next appointment. Be as specific as possible about when symptoms occurred.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColours.secondaryGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColours.secondaryGreen),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            body,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
