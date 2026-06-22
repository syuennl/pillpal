import 'package:flutter/material.dart';
import '../../../utils/app_colours.dart';

class TodayStatusCard extends StatelessWidget {
  final int takenToday;
  final int missedToday;

  const TodayStatusCard({
    super.key,
    required this.takenToday,
    required this.missedToday,
  });

  Widget _buildStatusBox(
    String label,
    int count,
    Color valueColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusBox(
              'Taken Today',
              takenToday,
              AppColours.primaryGreen,
              AppColours.secondaryGreen,
            ),
            const SizedBox(width: 16),

            _buildStatusBox(
              'Missed Today',
              missedToday,
              AppColours.primaryRed,
              AppColours.tertiaryRed,
            ),
          ],
        ),
      ],
    );
  }
}
