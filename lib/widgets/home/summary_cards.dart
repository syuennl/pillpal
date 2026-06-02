import 'package:flutter/material.dart';
// import 'package:pillpal/models/reminder.dart';
import 'package:pillpal/utils/app_colours.dart';

class SummaryCards extends StatelessWidget {
  final int total;
  final int taken;
  final int missed;
  const SummaryCards({
    super.key,
    required this.total,
    required this.taken,
    required this.missed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCard(
            '$total',
            'Total',
            AppColours.primaryYellow,
            AppColours.fontBrown,
          ),

          const SizedBox(width: 8),
          _buildCard('$taken', 'Taken', AppColours.primaryGreen, Colors.white),

          const SizedBox(width: 8),
          _buildCard(
            '$missed',
            'Missed',
            AppColours.primaryOrange,
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String count, String label, Color color, Color textColor) {
    return Expanded(
      child: Container(
        // margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // count
            Text(
              count,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),

            // label
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
              ), // grey 700
            ),
          ],
        ),
      ),
    );
  }
}
