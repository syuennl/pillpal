import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

enum LogStatus {
  taken(
    displayName: 'Taken',
    icon: Icons.check,
    backgroundColor: AppColours.secondaryGreen,
    contentColor: AppColours.primaryGreen,
  ),
  missed(
    displayName: 'Missed',
    icon: Icons.close,
    backgroundColor: AppColours.tertiaryRed,
    contentColor: AppColours.primaryRed,
  ),
  snoozed(
    displayName: 'Snoozed',
    icon: Icons.access_time,
    backgroundColor: AppColours.secondaryYellow,
    contentColor: AppColours.primaryOrange,
  );

  final String displayName;
  final IconData icon;
  final Color backgroundColor;
  final Color contentColor;

  const LogStatus({
    required this.displayName,
    required this.icon,
    required this.backgroundColor,
    required this.contentColor,
  });
}
