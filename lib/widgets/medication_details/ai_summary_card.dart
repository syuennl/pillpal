import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../medication/medication_card.dart';

class AiSummaryCard extends StatelessWidget {
  final String summaryText;

  const AiSummaryCard({
    super.key,
    required this.summaryText,
  });

  @override
  Widget build(BuildContext context) {
    return MedicationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: AppColours.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),

              Text(
                'AI Summary',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            summaryText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
