import 'package:flutter/material.dart';
import 'package:pillpal/models/medication.dart';
import 'package:pillpal/utils/app_colours.dart';
import 'medication_card_shell.dart';

class TakenMedicationCard extends StatelessWidget {
  final Medication medication;
  final TimeOfDay scheduledTime;

  final VoidCallback? onTap;

  const TakenMedicationCard({
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

      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColours.secondaryGreen,
            disabledBackgroundColor: AppColours.secondaryGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Taken',
            style: TextStyle(
              color: AppColours.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
