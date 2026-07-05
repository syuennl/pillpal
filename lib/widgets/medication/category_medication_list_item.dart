import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../utils/app_colours.dart';

// Single row inside the CategoryMedicationsModal
class CategoryMedicationListItem extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;

  const CategoryMedicationListItem({
    super.key,
    required this.medication,
    required this.onTap,
  });

  String _buildDosageLine() {
    // e.g. "1 tablet (10 mg)"
    final dose =
        '${medication.dosageAmount % 1 == 0 ? medication.dosageAmount.toInt() : medication.dosageAmount} ${medication.dosageUnit}';
    final strength = medication.formattedStrength;
    return strength.isEmpty ? dose : '$dose ($strength)';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),

          child: Row(
            children: [
              // green icon box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColours.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  medication.type.outlinedIcon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // med name
                    Text(
                      medication.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColours.fontBrown,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // med dosage
                    Text(
                      _buildDosageLine(),
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),

                    // med scheduled times
                    if (medication.scheduledTimes.isNotEmpty) ...[
                      // if statement only returns 1 element, so use [], then use ... to return them as 2 children to parent column
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),

                          Flexible(
                            child: Text(
                              medication.scheduledTimes
                                  .map(
                                    (t) =>
                                        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                                  )
                                  .join(', '),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // arrow button
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
