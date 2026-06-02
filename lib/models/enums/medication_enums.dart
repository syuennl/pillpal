import 'package:flutter/material.dart';

// medication type
enum MedicationType {
  pill(
    displayName: 'Pill',
    outlinedIcon: Icons.circle_outlined,
    filledIcon: Icons.circle,
  ),
  capsule(
    displayName: 'Capsule',
    outlinedIcon: Icons.medication_liquid_outlined,
    filledIcon: Icons.medication_liquid,
  ),
  syrup(
    displayName: 'Syrup',
    outlinedIcon: Icons.water_drop_outlined,
    filledIcon: Icons.water_drop,
  ),
  injection(
    displayName: 'Injection',
    outlinedIcon: Icons.vaccines_outlined,
    filledIcon: Icons.vaccines,
  ),
  others(
    displayName: 'Others',
    outlinedIcon: Icons.inventory_2_outlined,
    filledIcon: Icons.inventory_2,
  );

  final String displayName;
  final IconData outlinedIcon;
  final IconData filledIcon;

  const MedicationType({
    required this.displayName,
    required this.outlinedIcon,
    required this.filledIcon,
  });
}

// intake instruction
enum IntakeInstruction {
  beforeFood(displayName: 'Before Food'),
  afterFood(displayName: 'After Food'),
  anytime(displayName: 'Anytime');

  final String displayName;

  const IntakeInstruction({required this.displayName});
}

// frequency type
enum FrequencyType {
  daily(displayName: 'Daily'),
  specificDays(displayName: 'Specific Days'),
  interval(displayName: 'Every X Days'),
  asNeeded(displayName: 'As Needed');

  final String displayName;

  const FrequencyType({required this.displayName});
}
