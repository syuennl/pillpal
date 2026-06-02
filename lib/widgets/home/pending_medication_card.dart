import 'package:flutter/material.dart';
import 'package:pillpal/models/medication.dart';
import 'package:pillpal/utils/app_colours.dart';
import 'medication_card_shell.dart';

class PendingMedicationCard extends StatelessWidget {
  final Medication medication;
  final TimeOfDay scheduledTime;

  final VoidCallback onTaken;
  final VoidCallback onSnooze;
  final VoidCallback onSkip;

  const PendingMedicationCard({
    super.key,
    required this.medication,
    required this.scheduledTime,
    required this.onTaken,
    required this.onSnooze,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return MedicationCardShell(
      medication: medication,
      scheduledTime: scheduledTime,
      child: Column(
        children: [
          // taken + snooze row
          Row(
            children: [
              // taken
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onTaken,
                  icon: const Icon(Icons.check, size: 16, color: Colors.white),
                  label: const Text(
                    'Mark as Taken',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // snooze
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: onSnooze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.primaryOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Snooze',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // skip
          SizedBox(
            width: double.infinity, // width: 100%
            child: ElevatedButton(
              onPressed: onSkip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.buttonGrey,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
