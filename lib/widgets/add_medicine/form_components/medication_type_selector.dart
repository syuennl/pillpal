import 'package:flutter/material.dart';
import 'package:pillpal/models/enums/medication_enums.dart';
import 'package:pillpal/utils/app_colours.dart';

class MedicationTypeSelector extends StatelessWidget {
  final MedicationType selectedType;
  final ValueChanged<MedicationType> onChanged;

  const MedicationTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MedicationType.values.map((type) {
        final isSelected = selectedType == type;
        final iconData = type.outlinedIcon;

        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            width:
                (MediaQuery.of(context).size.width - 48 - 24) /
                3, // only 3 items max. per row
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColours.tertiaryGreen
                  : AppColours.textboxGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  iconData,
                  color: isSelected
                      ? AppColours.primaryGreen
                      : Colors.grey[700],
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColours.primaryGreen
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
