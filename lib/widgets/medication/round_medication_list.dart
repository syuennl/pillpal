import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../../models/medication.dart';

class RoundMedicationList extends StatelessWidget {
  final List<Medication> medications;
  final Function(Medication)? onMedicationTap;

  const RoundMedicationList({
    super.key,
    required this.medications,
    this.onMedicationTap,
  });

  Widget _buildPillItem(Medication med) {
    // bool isPill =
    //     med.type ==
    //     MedicationType
    //         .pill; // mayb can sort out in the screen bfr passing into widgets

    return GestureDetector(
      onTap: onMedicationTap != null ? () => onMedicationTap!(med) : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Column(
          children: [
            // med name
            SizedBox(
              width: 76, // fixed width to prevent stretching
              child: Text(
                med.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColours.primaryGreen,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Icon(
                    med.type.filledIcon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              '${med.quantity} ${med.dosageUnit}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: medications.map(_buildPillItem).toList(),
      ),
    );
  }
}
