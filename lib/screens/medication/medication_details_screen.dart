import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../models/medication.dart';
import '../../models/adherence_log.dart';
import '../../view_models/history_entry.dart';

import '../../services/medication_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/adherence_log_service.dart';
import '../../utils/app_colours.dart';

import '../../widgets/medication/medication_card.dart';
import '../../widgets/medication_details/detail_info_row.dart';
import '../../widgets/medication_details/ai_summary_card.dart';
import '../../widgets/medication_details/side_effects_card.dart';
import '../../widgets/medication_details/adherence_summary_card.dart';
import '../../widgets/medication_details/recent_history_card.dart';
import 'edit_medication_screen.dart';
import 'medication_diary_screen.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  void _showDeleteDialog(BuildContext context, Medication med) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Medication',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete ${med.name}?'),
          actions: [
            // cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // delete button
            TextButton(
              onPressed: () async {
                try {
                  await NotificationService().cancelForMedication(med);
                  await MedicationService().deleteMedication(med.id);

                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // pop dialog

                  // show success SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${medication.name} deleted successfully'),
                      backgroundColor: AppColours.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // pop dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not delete: $e')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColours.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser!.uid;

    // medication
    return StreamBuilder<List<Medication>>(
      stream: MedicationService().streamMedications(uid),
      builder: (context, snapshot) {
        // find this med in the live list
        final med = snapshot.data?.firstWhereOrNull(
          (m) => m.id == medication.id,
        );

        if (med == null) {
          // deleted while viewing, or still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // medication no longer exists, pop back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        // adherence logs
        return StreamBuilder<List<AdherenceLog>>(
          stream: AdherenceLogService().streamLogsForMedication(med.id),
          builder: (context, logSnap) {
            final medLogs = logSnap.data ?? [];

            // sort recent history to show latest logs first
            medLogs.sort((a, b) => b.date.compareTo(a.date));

            final takenCount = medLogs
                .where((l) => l.status == LogStatus.taken)
                .length;
            final missedCount = medLogs
                .where((l) => l.status == LogStatus.missed)
                .length;

            final historyEntries = medLogs.take(5).map((log) {
              final hour = log.scheduledTime.hour.toString().padLeft(2, '0');
              final minute = log.scheduledTime.minute.toString().padLeft(
                2,
                '0',
              );
              return HistoryEntry(
                time: '$hour:$minute',
                date: DateFormat('MMM d').format(log.date),
                status: log.status,
              );
            }).toList();

            return Scaffold(
              backgroundColor: AppColours.backgroundGreen,

              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColours.primaryGreen,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Text(
                  'Details',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
                actions: [
                  // edit button
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColours.primaryGreen,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditMedicationScreen(
                            medication: med,
                          ), // go thru edit screen for custom app bar
                        ),
                      );
                    },
                  ),

                  // delete button
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColours.primaryRed,
                    ),
                    onPressed: () => _showDeleteDialog(context, med),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // image
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // main info card
                    MedicationCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name
                          Text(
                            med.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // dosage info
                          Text(
                            '${med.dosageAmount} ${med.dosageUnit} (${med.strengthValue} ${med.strengthUnit}) per intake',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // frequency
                          DetailInfoRow(
                            label: 'Frequency',
                            value: med.frequencyDisplay,
                          ),

                          // scheduled time
                          DetailInfoRow(
                            label: 'Schedule',
                            value: med.scheduledTimes.isNotEmpty
                                ? med.scheduledTimes
                                      .map(
                                        (t) =>
                                            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                                      )
                                      .join(', ')
                                : 'Not set',
                          ),

                          // instructions
                          DetailInfoRow(
                            label: 'Instructions',
                            value: med.intakeInstruction.displayName,
                          ),

                          // quantity
                          DetailInfoRow(
                            label: 'Quantity',
                            value: '${med.quantity} ${med.dosageUnit}(s)',
                          ),

                          // expiry date
                          DetailInfoRow(
                            label: 'Expiry Date',
                            value: med.expiryDate != null
                                ? _formatDate(med.expiryDate!)
                                : 'Not set',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    // AI summary
                    if (med.aiSummary != null && med.aiSummary!.isNotEmpty)
                      AiSummaryCard(summaryText: med.aiSummary!),

                    // side effects
                    if (med.sideEffects != null && med.sideEffects!.isNotEmpty)
                      SideEffectsCard(
                        sideEffects: med.sideEffects!,
                        onDiaryPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MedicationDiaryScreen(medication: med),
                            ),
                          );
                        },
                      ),

                    // adherence summary
                    AdherenceSummaryCard(
                      takenCount: takenCount,
                      missedCount: missedCount,
                    ),

                    // recent history
                    if (historyEntries.isNotEmpty)
                      RecentHistoryCard(history: historyEntries),

                    const SizedBox(height: 32), // bottom padding
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
