import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../../models/adherence_log.dart';
import '../../models/enums/medication_enums.dart';

class HistoryRecordCard extends StatelessWidget {
  final String medicationName;
  final String timeTaken;
  final String? scheduledTime;
  final LogStatus status;
  final MedicationType iconType;

  const HistoryRecordCard({
    super.key,
    required this.medicationName,
    required this.timeTaken,
    this.scheduledTime,
    required this.status,
    required this.iconType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 0,
            offset: const Offset(1, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 0,
            offset: const Offset(-1, 0),
          ),
        ],
      ),

      child: Row(
        children: [
          // icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColours.tertiaryGreen,
            ),
            child: Icon(
              iconType.outlinedIcon,
              color: AppColours.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicationName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeTaken,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (scheduledTime != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '• Scheduled $scheduledTime',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status.icon,
                  size: 14,
                  color: status.contentColor,
                ),
                const SizedBox(width: 4),
                
                Text(
                  status.displayName,
                  style: TextStyle(
                    color: status.contentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
