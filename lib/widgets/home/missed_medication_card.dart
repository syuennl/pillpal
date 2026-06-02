import 'package:flutter/material.dart';
import 'package:pillpal/models/medication.dart';
import 'package:pillpal/utils/app_colours.dart';
import 'medication_card_shell.dart';

class MissedMedicationCard extends StatelessWidget {
  final Medication medication;
  final TimeOfDay scheduledTime;

  /// Optional tap handler — e.g. to log a late "taken" or open details.
  final VoidCallback? onTap;

  const MissedMedicationCard({
    super.key,
    required this.medication,
    required this.scheduledTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MedicationCardShell(
      medication: medication,
      scheduledTime: scheduledTime,
      timeColor: AppColours.primaryRed,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColours.secondaryRed,
            disabledBackgroundColor: AppColours.secondaryRed,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Missed',
            style: TextStyle(
              color: AppColours.primaryRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
