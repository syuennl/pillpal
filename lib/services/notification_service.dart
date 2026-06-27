import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication.dart';
import '../models/enums/medication_enums.dart';

// wraps flutter_local_notifications
// handles setup, permissions, scheduling, cancelling local reminders
class NotificationService {
  // singleton, whole app shares one initialised plugin (noti service) no matter how many times notiservice() called
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() =>
      _instance; // constructor ppl call when they write NotificationService(), returns the single instance
  NotificationService._internal(); // private constructor tht can create new instance

  final _plugin =
      FlutterLocalNotificationsPlugin(); // holds state (initialised, pending notis, channels registered etc.)
  bool _initialised = false; // ensures init runs setup once only

  // call once at app startup (in main, after Firebase.initializeApp)
  Future<void> init() async {
    if (_initialised) return;

    // setup the timezone db and point it at the device's zone,
    // so scheduled times are interpreted correctly (e.g. Asia/Kuala_Lumpur)
    try {
      tz.initializeTimeZones();
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone));
    } catch (e) {
      debugPrint(
        'Warning: Timezone initialization failed: $e. Falling back to UTC.',
      );
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    // platform init settings
    // noti icon must exist in android/app/src/main/res/mipmap — '@mipmap/ic_launcher' = default app icon
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // fired when the user taps a notification
        // `response.payload` can carry the medicationId so you know which med it is
        debugPrint('Notification tapped, payload: ${response.payload}');
      },
    );

    // notification channel, every noti must belong to one.
    // changed to medication_reminders_v2 to force Android to create a new channel with max importance.
    const channel = AndroidNotificationChannel(
      'medication_reminders_v2', // channel id
      'Medication Reminders', // channel name
      description: 'Reminders to take your medication', // channel description
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel); // creates the channel

    _initialised = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          // make the general plugin to a platform specific obj
          AndroidFlutterLocalNotificationsPlugin
        >();

    // request standard notification permissions (for Android 13+)
    final grantedNotifs =
        await android?.requestNotificationsPermission() ?? false;

    // request exact alarm permissions (crucial for scheduled zoned notifications)
    try {
      await android?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
    }

    return grantedNotifs;
  }

  // metadata attached to each noti
  static const _channel = AndroidNotificationDetails(
    'medication_reminders_v2',
    'Medication Reminders',
    channelDescription: 'Reminders to take your medication',
    importance: Importance.max,
    priority: Priority.high,
  );

  /// TEST: fires a notification instantly.
  Future<void> showInstantNotification() async {
    await _plugin.show(
      8888,
      'PillPal Instant Test',
      'If you see this, notifications work instantly!',
      const NotificationDetails(android: _channel),
    );
  }

  /// TEST: fires a notification a few seconds from now. Use this to confirm
  /// the whole setup works before wiring real medication scheduling.
  Future<void> scheduleTestNotification() async {
    try {
      await _plugin.zonedSchedule(
        9999, // test id
        'PillPal test',
        'If you see this, notifications work!',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint(
        'Error scheduling exact test notification: $e. Falling back to inexact.',
      );
      await _plugin.zonedSchedule(
        9999,
        'PillPal test (Inexact)',
        'If you see this, notifications work (Inexact)!',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// cancel a single scheduled notification by its id
  Future<void> cancel(int id) => _plugin.cancel(id);

  /// cancel all scheduled notifications
  Future<void> cancelAll() => _plugin.cancelAll();

  // builds unique noti id frm a med and its times
  // same med + same time index -> same id, so we can cancel/replace
  int _notifId(String medicationId, int timeIndex) {
    // hashCode can be -ve, abs + modulo keeps it a +ve int
    return (medicationId.hashCode.abs() % 100000) * 1000 + timeIndex;
    // modulo ensures num x exceed size limit, *1000 creates empty space on right for the time index
  }

  /// cancels all reminders for one medication (covers up to 10 times/day)
  Future<void> cancelForMedication(Medication med) async {
    // regenerate the exact same ids the scheduler used, cancel only those
    for (var i = 0; i < med.scheduledTimes.length; i++) {
      if (med.frequencyType == FrequencyType.specificDays) {
        final days = med.selectedDays ?? [];
        for (var d = 0; d < days.length; d++) {
          await _plugin.cancel(_notifId(med.id, i * 100 + d));
        }
      } else {
        await _plugin.cancel(_notifId(med.id, i));
      }
    }
  }

  // set a reminder
  Future<void> _schedule({
    required int id,
    required Medication med,
    required tz.TZDateTime when,
    required DateTimeComponents match,
  }) async {
    await _plugin.zonedSchedule(
      // set a reminder
      id,
      'Time for ${med.name}', // noti title
      'Take ${med.formattedDosage}' // noti body
          '${med.intakeInstruction == IntakeInstruction.anytime ? '' : ' (${med.intakeInstruction.displayName})'}',
      when, // when to fire it
      const NotificationDetails(
        android: _channel,
      ), // use which channel and metadata
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: match, // repeat when
      payload: med.id, // when user taps, knows which med
    );
  }

  // returns the next future occurrence of a given time-of-day
  // either tdy (if the time hasn't passed), or tmr
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour, // scheduled time
      time.minute,
    );

    // if today's time already passed, schedule for tmr
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // next occurrence of a given weekday + time (for specificDays)
  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, TimeOfDay time) {
    var scheduled = _nextInstanceOfTime(time); // next time today/tomorrow
    // bump forward day by day until we land on the right weekday
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // schedules all reminders for one medication
  // call this after adding or editing a medication
  Future<void> scheduleForMedication(Medication med) async {
    // always clear this med's old reminders first
    await cancelForMedication(med);

    // "As needed" nonid to remind.
    if (med.frequencyType == FrequencyType.asNeeded) return;

    // loop thru each scheduled time
    for (var i = 0; i < med.scheduledTimes.length; i++) {
      final time = med.scheduledTimes[i];

      switch (med.frequencyType) {
        case FrequencyType.daily:
          await _schedule(
            id: _notifId(med.id, i),
            med: med,
            when: _nextInstanceOfTime(time),
            match: DateTimeComponents.time, // repeats every day
          );
          break;

        case FrequencyType.specificDays:
          final days = med.selectedDays ?? [];
          for (var d = 0; d < days.length; d++) {
            final weekday =
                days[d]; // 1=Mon ... 7=Sun 
            await _schedule( // create reminder
              id: _notifId(med.id, i * 100 + d), // include the day (i*100) and leave space for time idx
              med: med,
              when: _nextInstanceOfWeekdayTime(weekday, time),
              match: DateTimeComponents
                  .dayOfWeekAndTime, // repeats weekly on that day
            );
          }
          break;

        // case FrequencyType.interval:
        //   // For now, treat it like daily so the user still gets reminders.
        //   await _schedule(
        //     id: _notifId(med.id, i),
        //     med: med,
        //     when: _nextInstanceOfTime(time), 
        //     match: DateTimeComponents.time,
        //   );
        //   break;

        case FrequencyType.asNeeded:
          break; // already returned above
      }
    }
  }
}

