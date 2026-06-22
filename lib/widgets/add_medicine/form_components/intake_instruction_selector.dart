import 'package:flutter/material.dart';
import 'package:pillpal/models/enums/medication_enums.dart';
import 'package:pillpal/utils/app_colours.dart';

class IntakeInstructionSelector extends StatelessWidget {
  final IntakeInstruction selectedInstruction;
  final ValueChanged<IntakeInstruction> onChanged;

  const IntakeInstructionSelector({
    super.key,
    required this.selectedInstruction,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: IntakeInstruction.values.map((instruction) {
        final isSelected = selectedInstruction == instruction;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(instruction),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColours.tertiaryGreen : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  instruction.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColours.primaryGreen
                        : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
