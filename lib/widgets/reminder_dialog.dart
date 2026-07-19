import 'package:flutter/material.dart';
import '../utils/app_colours.dart';
import '../models/medication.dart';
import '../services/adherence_log_service.dart';
import '../services/notification_service.dart';

// called when the user taps a reminder notification while (or by) opening the app
// the Taken/Snooze/Skip btns write to AdherenceLogService, same methods home screen use
void showReminderDialog(BuildContext context, Medication med) {
  // which scheduled time is this reminder for? use the closest one to "now".
  final now = TimeOfDay.now();
  final nowMin = now.hour * 60 + now.minute;
  final scheduledTime = med.scheduledTimes.isEmpty
      ? now
      : med.scheduledTimes.reduce((a, b) {
          final da = ((a.hour * 60 + a.minute) - nowMin).abs();
          final db = ((b.hour * 60 + b.minute) - nowMin).abs();
          return da <= db ? a : b;
        });

  final logService = AdherenceLogService();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // green header
              Container(
                width: double.infinity,
                color: AppColours.primaryGreen,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // icon
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),

                        // title
                        const Text(
                          'Medication Reminder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),

                        // close button
                        GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // time
                    Text(
                      '${scheduledTime.hour.toString().padLeft(2, '0')}:'
                      '${scheduledTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),

              // body
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // med name
                    Text(
                      med.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // med dosage
                    Text(
                      med.formattedDosage,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),

                    // instruction + summary card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.intakeInstruction.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          if (med.aiSummary != null &&
                              med.aiSummary!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              med.aiSummary!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // taken
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await logService.logTaken(
                            medicationId: med.id,
                            userId: med.userId,
                            scheduledTime: scheduledTime,
                          );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "✓ I've Taken It",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // snooze
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await logService.logSnoozed(
                                medicationId: med.id,
                                userId: med.userId,
                                scheduledTime: scheduledTime,
                              );
                              // re-remind in 10 minutes
                              await NotificationService()
                                  .scheduleSnoozeReminder(med, scheduledTime);
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColours.secondaryOrange,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Snooze 10 min',
                              style: TextStyle(
                                color: AppColours.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // skip
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await logService.logMissed(
                                medicationId: med.id,
                                userId: med.userId,
                                scheduledTime: scheduledTime,
                              );
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColours.buttonGrey,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
