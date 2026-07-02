import 'package:flutter/material.dart';
import '../../../models/medication.dart';
import '../../../models/adherence_log.dart';
import '../../../services/adherence_log_service.dart';
import '../../../utils/app_colours.dart';

class CurrentMedicationsCard extends StatelessWidget {
  final List<Medication> medications;

  const CurrentMedicationsCard({super.key, required this.medications});

  Widget _buildMedicationItem(Medication med, List<AdherenceLog> logs) {
    final name = med.name;
    final dosage = med.formattedDosage;
    final frequency = med.frequencyDisplay;
    final timeStr = med.scheduledTimes.isNotEmpty
        ? med.scheduledTimes
              .map(
                (t) =>
                    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
              )
              .join(', ')
        : 'As needed';

    // calculate dynamic snooze count from logs database for today
    final snoozeCount = logs
        .where((log) => log.medicationId == med.id)
        .map((log) => log.snoozeCount)
        .fold(0, (sum, count) => sum + count);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // snooze count badge
              if (snoozeCount >= 3) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColours.secondaryOrange,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColours.primaryRed.withOpacity(0.4),
                        blurRadius: 1,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColours.primaryRed,
                        size: 12,
                      ),
                      const SizedBox(width: 4),

                      Text(
                        'Snoozed $snoozeCount×',
                        style: const TextStyle(
                          color: AppColours.primaryRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          Text(
            '$dosage • $frequency',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey[500], size: 16),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) return const SizedBox.shrink();

    final userId = medications.first.userId;

    return StreamBuilder<List<AdherenceLog>>(
      stream: AdherenceLogService().streamLogsForDate(userId, DateTime.now()),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: medications
              .map((med) => _buildMedicationItem(med, logs))
              .toList(),
        );
      },
    );
  }
}
