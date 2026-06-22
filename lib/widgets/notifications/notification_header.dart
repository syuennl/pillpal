import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class NotificationHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onBack;

  const NotificationHeader({
    super.key,
    required this.unreadCount,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // back button
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          color: AppColours.fontBrown,
          onPressed: onBack,
        ),
        const SizedBox(width: 4),

        // title
        const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColours.fontBrown,
          ),
        ),
        const SizedBox(width: 12),

        // unread count badge
        if (unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColours.primaryGreen,
              borderRadius: BorderRadius.circular(999),
            ),

            child: Text(
              '$unreadCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
