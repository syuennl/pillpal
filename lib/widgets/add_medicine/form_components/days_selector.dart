import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class DaysSelector extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<int> onDayToggled;

  const DaysSelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayIndex = index + 1; // 1 to 7
        final isSelected = selectedDays.contains(dayIndex);
        return GestureDetector(
          onTap: () => onDayToggled(dayIndex),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColours.tertiaryGreen : Colors.grey[100],
            ),
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  color: isSelected ? AppColours.primaryGreen : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
