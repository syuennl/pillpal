import 'package:flutter/material.dart';
import '../../models/medication.dart';
import 'horizontal_medication_item.dart';

/// A reusable vertical list column that maps medication items to
/// [HorizontalMedicationItem] tiles with standard layout padding and onTap events.
class MedicationColumn extends StatelessWidget {
  final List<Medication> medications;
  final ValueChanged<Medication> onMedicationTap;

  const MedicationColumn({
    super.key,
    required this.medications,
    required this.onMedicationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: medications
          .map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: HorizontalMedicationItem(
                medName: m.name,
                medQuantity: '${m.formattedQuantity} ${m.dosageUnit}',
                medIcon: m.type.filledIcon,
                onTap: () => onMedicationTap(m),
              ),
            ),
          )
          .toList(),
    );
  }
}
