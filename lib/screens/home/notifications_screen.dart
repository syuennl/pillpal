import 'package:flutter/material.dart';
import '../../models/app_notification.dart';
import '../../mock/app_notification.dart';
import '../../widgets/notifications/notification_card.dart';
import '../../widgets/notifications/notification_header.dart';
import '../../widgets/notifications/notification_action_bar.dart';
import '../../widgets/notifications/empty_notifications.dart';
import '../../utils/app_colours.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // local copy so we can mutate (dismiss, mark read, clear)
  // TODO: when backend lands, swap this with a service / stream
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(mockNotifications);
  }

  void _markRead(String id) {
    setState(() {
      _notifications = _notifications
          .map((n) => n.id == id ? n.copyWith(read: true) : n)
          .toList();
    });

    final index = mockNotifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    mockNotifications[index] = mockNotifications[index].copyWith(read: true);
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.read ? n : n.copyWith(read: true))
          .toList();

      for (var i = 0; i < mockNotifications.length; i++) {
        if (!mockNotifications[i].read) {
          mockNotifications[i] = mockNotifications[i].copyWith(read: true);
        }
      }
    });
  }

  void _dismiss(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
      mockNotifications.removeWhere((n) => n.id == id);
    });
  }

  void _clearAll() {
    setState(() {
      _notifications = [];
      mockNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // prevent phone's notch from clipping content
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // why sizedbox?
              // header
              NotificationHeader(
                unreadCount: unreadCount,
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),

              // action bar
              if (_notifications.isNotEmpty)
                NotificationActionBar(
                  showMarkAllRead: unreadCount > 0,
                  onMarkAllRead: _markAllRead,
                  onClearAll: _clearAll,
                ),
              const SizedBox(height: 8),

              Expanded(
                child: _notifications.isEmpty
                    ? const EmptyNotifications()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return Dismissible(
                            key: Key(n.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) => _dismiss(n.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              decoration: BoxDecoration(
                                color: AppColours.primaryRed,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            child: NotificationCard(
                              notification: n,
                              onRead: () => _markRead(n.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
