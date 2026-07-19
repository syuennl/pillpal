import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

/// Handles Firebase Cloud Messaging (cross-device push)
/// - saves this device's FCM token to the user's Firestore doc
///   (the Cloud Function reads it to know where to send caregiver alerts)
/// - shows incoming pushes while the app is open
class FcmService {
  // singleton, whole app shares one initialised plugin (fcm service) no matter how many times it's called
  static final FcmService _instance = FcmService._internal();

  // constructor ppl call when they write FcmService(), returns the single instance
  factory FcmService() => _instance;

  // private constructor that can create new instance
  FcmService._internal();

  final _fcm = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  bool _isSetup = false;

  // call after the user logged in
  Future<void> setup(String uid) async {
    if (_isSetup)
      return; // prevent duplicate listeners if called multiple times
    _isSetup = true;

    // 1. permission (Android 13+ / iOS), safe to call even if already granted.
    await _fcm.requestPermission();

    // 2. get device's token and save on user doc
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveToken(uid, token);
    }

    // 3. tokens rotate, keep stored token current
    _fcm.onTokenRefresh.listen((newToken) {
      // dynamically fetch the current user's UID to handle account switching
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null) {
        _saveToken(currentUid, newToken);
      }
    });

    // 4. show noti pushes that arrive while the app is in the FOREGROUND (user using app)
    // (Android doesn't auto-display these, must catch and show them ourselves via local notifications service)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message
          .notification; // when msg arrives, checks if contains noti payload (title & body)
      if (notification != null) {
        // route to the matching channel so foreground alerts show under the
        // same category (and importance) the sender intended
        final channelId = notification.android?.channelId;
        final channel = channelId == 'caregiver_alerts'
            ? NotificationService.caregiverChannel
            : null;

        NotificationService().showRawNotification(
          // manually triggering local noti service to create a sys noti
          title: notification.title ?? 'PillPal',
          body: notification.body ?? '',
          channel: channel ?? NotificationService.defaultChannel,
        );
      }
    });

    // 5. handle a tap that opened the app from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Push opened the app: ${message.data}');
      // (optional) navigate to the caregiver dashboard here
    });
  }

  // save token
  Future<void> _saveToken(String uid, String token) async {
    // wait bfr first try to give Firestore's internal connection time to sync auth state
    // prevents IDE debugger from pausing on transient permission-denied exceptions bfr catch block can handle it
    await Future.delayed(const Duration(milliseconds: 800));

    // retry up to 3 times to avoid race conditions where Firestore hasn't registered the new auth token yet right after login
    for (int i = 0; i < 3; i++) {
      try {
        await _db.collection('users').doc(uid).set(
          {'fcmToken': token},
          SetOptions(
            merge: true,
          ), // only update the fcmToken field of this record
        );
        break; // success, exit loop
      } catch (e) {
        if (i == 2) {
          debugPrint('Failed to save FCM token after 3 attempts: $e');
        } else {
          await Future.delayed(
            const Duration(milliseconds: 800),
          ); // wait and retry
        }
      }
    }
  }

  // clear token on sign-out so this device stops receiving the previous user's alerts
  Future<void> clearToken(String uid) async {
    await _db.collection('users').doc(uid).set({
      'fcmToken': '',
    }, SetOptions(merge: true));
    await _fcm.deleteToken();
  }
}
