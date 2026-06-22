import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../medication/medication_card.dart';
import 'package:pillpal/models/adherence_log.dart';
import 'package:pillpal/view_models/history_entry.dart';

class RecentHistoryCard extends StatelessWidget {
  final List<HistoryEntry> history;

  const RecentHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return MedicationCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          ...history.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.time,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        entry.date,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  // status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: entry.status == LogStatus.taken
                          ? AppColours.secondaryGreen
                          : AppColours.tertiaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.status.displayName,
                      style: TextStyle(
                        color: entry.status == LogStatus.taken
                            ? AppColours.primaryGreen
                            : AppColours.primaryRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
