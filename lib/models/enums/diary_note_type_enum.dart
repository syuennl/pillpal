import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

enum DiaryNoteType {
  sideEffect(
    displayName: 'Side Effects',
    backgroundColor: AppColours.secondaryYellow,
    foregroundColor: AppColours.primaryOrange,
  ),
  symptom(
    displayName: 'Symptoms',
    backgroundColor: AppColours.tertiaryRed,
    foregroundColor: AppColours.primaryRed,
  ),
  others(
    displayName: 'Others',
    backgroundColor: AppColours.secondaryGreen,
    foregroundColor: AppColours.primaryGreen,
  );

  final String displayName;
  final Color backgroundColor;
  final Color foregroundColor;

  const DiaryNoteType({
    required this.displayName,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}
