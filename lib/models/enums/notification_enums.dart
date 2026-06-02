import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

enum NotificationType {
  reminder(
    icon: Icons.notifications,
    iconBgColor: AppColours.primaryGreen,
    iconColor: Colors.white,
  ),
  alert(
    icon: Icons.warning_amber_rounded,
    iconBgColor: AppColours.primaryOrange,
    iconColor: Colors.white,
  ),
  message(
    icon: Icons.mail_outline,
    iconBgColor: AppColours.primaryGreen,
    iconColor: Colors.white,
  ),
  announcement(
    icon: Icons.campaign_outlined,
    iconBgColor: AppColours.primaryGreen,
    iconColor: Colors.white,
  );

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const NotificationType({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

// "x hours ago" / "x days ago" formatter
String formatRelativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);

  // less than a minute
  if (diff.inMinutes < 1) return 'Just now';

  // less than an hour
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
  }

  // less than a day
  if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }

  // 1+ days
  final days = diff.inDays;
  return '$days day${days == 1 ? '' : 's'} ago';
}
