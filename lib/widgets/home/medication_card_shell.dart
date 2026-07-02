import 'package:flutter/material.dart';
import 'package:pillpal/models/medication.dart';

class MedicationCardShell extends StatelessWidget {
  final Medication medication;
  final TimeOfDay scheduledTime;
  final Color timeColor;
  final Widget child;

  const MedicationCardShell({
    super.key,
    required this.medication,
    required this.scheduledTime,
    this.timeColor = Colors.black54,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // medication info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // name
              Expanded(
                child: Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // scheduled time
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: timeColor),
                  const SizedBox(width: 4),
                  Text(
                    '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}', // or use .format(context)
                    style: TextStyle(
                      color: timeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // dosage & strength
          Text(
            medication.formattedStrength.isEmpty
                ? medication.formattedDosage
                : '${medication.formattedDosage} (${medication.formattedStrength})',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),

          // variant-specific action area
          child,
        ],
      ),
    );
  }
}
