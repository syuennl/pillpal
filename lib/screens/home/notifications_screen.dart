import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colours.dart';

import '../../models/app_notification.dart';

import '../../widgets/notifications/notification_card.dart';
import '../../widgets/notifications/notification_header.dart';
import '../../widgets/notifications/notification_action_bar.dart';
import '../../widgets/notifications/empty_notifications.dart';

import '../../services/auth_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _markRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update(
      {'read': true},
    );
  }

  Future<void> _markAllRead(List<AppNotification> notifs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var n in notifs) {
      if (!n.read) {
        batch.update(
          FirebaseFirestore.instance.collection('notifications').doc(n.id),
          {'read': true},
        );
      }
    }
    await batch.commit();
  }

  Future<void> _dismiss(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .delete();
  }

  Future<void> _clearAll(List<AppNotification> notifs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var n in notifs) {
      batch.delete(
        FirebaseFirestore.instance.collection('notifications').doc(n.id),
      );
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // prevent phone's notch from clipping content
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StreamBuilder<List<AppNotification>>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: AuthService().currentUser!.uid)
                .snapshots()
                .map((snap) {
                  final list = snap.docs
                      .map((d) => AppNotification.fromMap(d.data(), d.id))
                      .toList();
                  list.sort(
                    (a, b) => b.timestamp.compareTo(a.timestamp),
                  ); // newest first
                  return list;
                }),

            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final notifications = snap.data ?? [];
              final unreadCount = notifications.where((n) => !n.read).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // header
                  NotificationHeader(
                    unreadCount: unreadCount,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 12),

                  // action bar
                  if (notifications.isNotEmpty)
                    NotificationActionBar(
                      showMarkAllRead: unreadCount > 0,
                      onMarkAllRead: () => _markAllRead(notifications),
                      onClearAll: () => _clearAll(notifications),
                    ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: notifications.isEmpty
                        ? const EmptyNotifications()
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final n = notifications[index];
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
              );
            },
          ),
        ),
      ),
    );
  }
}
