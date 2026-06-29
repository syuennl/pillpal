import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../medication/medication_card.dart';

class AiSummaryCard extends StatelessWidget {
  final String summaryText;

  const AiSummaryCard({super.key, required this.summaryText});

  @override
  Widget build(BuildContext context) {
    return MedicationCard(
      backgroundColor: AppColours.secondaryGreen,
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
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.grey[600],
                  size: 12,
                ),
              ),
              Expanded(
                child: Text(
                  'AI-generated summary may contain inaccuracies. \nAlways follow the guidance of your doctor or pharmacist.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
