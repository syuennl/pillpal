import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class NotificationActionBar extends StatelessWidget {
  final bool showMarkAllRead;
  final VoidCallback onMarkAllRead;
  final VoidCallback onClearAll;

  const NotificationActionBar({
    super.key,
    required this.showMarkAllRead,
    required this.onMarkAllRead,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // mark all read button
        if (showMarkAllRead)
          TextButton(
            onPressed: onMarkAllRead,
            style: TextButton.styleFrom(
              foregroundColor: AppColours.primaryGreen,
              padding: const EdgeInsets.all(8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Mark all read',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        const SizedBox(width: 8),

        TextButton(
          onPressed: onClearAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColours.primaryGreen,
            padding: const EdgeInsets.all(8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Clear',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
