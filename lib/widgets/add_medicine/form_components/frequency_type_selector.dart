import 'package:flutter/material.dart';
import 'package:pillpal/models/enums/medication_enums.dart';
import 'package:pillpal/utils/app_colours.dart';

class FrequencyTypeSelector extends StatelessWidget {
  final FrequencyType selectedFrequency;
  final ValueChanged<FrequencyType> onChanged;

  const FrequencyTypeSelector({
    super.key,
    required this.selectedFrequency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FrequencyType.values.map((type) {
        final isSelected = selectedFrequency == type;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColours.tertiaryGreen : Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              type.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColours.primaryGreen : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
