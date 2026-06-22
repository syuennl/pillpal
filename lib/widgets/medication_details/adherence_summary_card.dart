import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../medication/medication_card.dart';

class AdherenceSummaryCard extends StatelessWidget {
  final int takenCount;
  final int missedCount;

  const AdherenceSummaryCard({
    super.key,
    required this.takenCount,
    required this.missedCount,
  });

  @override
  Widget build(BuildContext context) {
    int total = takenCount + missedCount;
    double rate = total == 0 ? 0 : takenCount / total;
    int ratePercentage = (rate * 100).round();

    return MedicationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adherence Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // rate row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adherence Rate',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                '$ratePercentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // progress bar
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: rate,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColours.primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // stats
          Row(
            children: [
              // taken
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColours.secondaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        takenCount.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColours.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Taken',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // missed
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColours.tertiaryRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        missedCount.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColours.primaryRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Missed',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
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
