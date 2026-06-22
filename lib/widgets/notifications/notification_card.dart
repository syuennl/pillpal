import 'package:flutter/material.dart';
import '../../models/app_notification.dart';
import '../../utils/app_colours.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final type = notification.type;
    final bgColor = notification.read
        ? Colors.white
        : AppColours.secondaryGreen;

    return GestureDetector(
      onTap: onRead,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // icon badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: type.iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(type.icon, color: type.iconColor, size: 20),
            ),
            const SizedBox(width: 12),

            // text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColours.fontBrown,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    notification.message,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  
                  Text(
                    formatRelativeTime(notification.timestamp),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
