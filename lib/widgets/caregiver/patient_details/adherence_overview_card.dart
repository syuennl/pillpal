import 'package:flutter/material.dart';
import '../../../utils/app_colours.dart';

class AdherenceOverviewCard extends StatelessWidget {
  final int adherenceRate;
  final int taken;
  final int missed;
  final int snoozed;

  const AdherenceOverviewCard({
    super.key,
    required this.adherenceRate,
    required this.taken,
    required this.missed,
    required this.snoozed,
  });

  Widget _buildStatBox(
    String label,
    int count,
    Color valueColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700], //valueColor
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color barColor = adherenceRate >= 80
        ? AppColours.primaryGreen
        : adherenceRate > 50
        ? AppColours.primaryOrange
        : AppColours.primaryRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // adherence percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Adherence Rate',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$adherenceRate%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: adherenceRate / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
        const SizedBox(height: 24),

        // stat boxes
        Row(
          children: [
            _buildStatBox(
              'Taken',
              taken,
              AppColours.primaryGreen,
              AppColours.secondaryGreen,
            ),
            const SizedBox(width: 12),

            _buildStatBox(
              'Missed',
              missed,
              AppColours.primaryRed,
              AppColours.tertiaryRed,
            ),
            const SizedBox(width: 12),

            _buildStatBox(
              'Snoozed',
              snoozed,
              AppColours.primaryOrange,
              AppColours.secondaryYellow,
            ),
          ],
        ),
      ],
    );
  }
}
