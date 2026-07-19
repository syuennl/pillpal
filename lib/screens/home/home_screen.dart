import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colours.dart';

import '../../services/medication_service.dart';
import '../../services/adherence_log_service.dart';
import '../../services/auth_service.dart';
import '../../services/message_of_the_day_service.dart';
import '../../services/caregiver_service.dart';
import '../../services/notification_service.dart';

import '../../widgets/home/date_selector.dart';
import '../../widgets/home/summary_cards.dart';
import '../../widgets/home/medication_list.dart';
import '../../widgets/reminder_dialog.dart';
import 'notifications_screen.dart';

import '../../models/adherence_log.dart';
import '../../models/medication.dart';
import '../../models/message_of_the_day.dart';
import '../../models/caregiver_relationship.dart';
import '../../view_models/daily_task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  final _medService = MedicationService();
  final _logService = AdherenceLogService();
  final _notificationService = NotificationService();
  final _messageService = MessageOfTheDayService();
  final _caregiverService = CaregiverService();
  final _uid = AuthService().currentUser!.uid;

  // track which logs have auto marked as missed during this session
  // prevent spamming backend if StreamBuilder rebuilds multiple times rapidly
  final Set<String> _autoProcessedMissedLogs = {};

  // track which dialogs have already popped up while app is in foreground
  final Set<String> _poppedForegroundDialogs = {};
  Timer? _minuteTickTimer;

  // cache caregiver names to prevent spamming firestore on rebuilds
  final Map<String, String> _caregiverNameCache = {};

  Future<String> _cachedCaregiverName(String caregiverId) async {
    if (_caregiverNameCache.containsKey(caregiverId)) {
      return _caregiverNameCache[caregiverId]!; // caregiver name
    }

    // if cache dh caregiver id
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(caregiverId)
          .get();
      final fetchedName = doc.data()?['name'] as String?;
      final name = (fetchedName == null || fetchedName.trim().isEmpty)
          ? 'Caregiver'
          : fetchedName;
      _caregiverNameCache[caregiverId] = name; // store fetched caregiver name in cache
      return name;
    } catch (e) {
      // handles PERMISSION_DENIED gracefully
      return 'Caregiver';
    }
  }

  // set default date to current date
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedMonth = DateTime(now.year, now.month, 1);
    // knt put now.month only, datetime first param must be year
    // the 1 is to init to 1st day, to prevent cases where on 31/5, user clicks april, sys deducts 1 month = 31/4, invalid date

    // request notification and exact alarm permissions for Android 13+
    _notificationService.requestPermissions();

    // tick every 60 seconds to keep UI live (auto mark missed, pop dialogs)
    _minuteTickTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {}); // refresh screen
    });
  }

  @override
  void dispose() {
    _minuteTickTimer?.cancel();
    super.dispose();
  }

  String _formatMonthYear(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColours.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColours.fontBrown,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColours.primaryGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedMonth = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  // knt use isAtSameMomentAs cuz both dates includes millisec cuz of DateTime.now()
  // dey r initialised at different millisecs so will be different

  bool _isToday(DateTime d) => _sameDay(d, DateTime.now());

  List<DailyTask> _generateTasksForDate(
    DateTime selectedDate,
    List<Medication> medications,
    List<AdherenceLog> logs,
  ) {
    List<DailyTask> tasks = [];

    for (var med in medications) {
      for (var time in med.scheduledTimes) {
        AdherenceLog? matchingLog = logs.firstWhereOrNull(
          // find if there's a log recorded for the med at the scheduled time
          (log) =>
              log.medicationId == med.id &&
              log.scheduledTime == time &&
              _sameDay(
                log.date,
                selectedDate,
              ), // comparing log date and selected date (not necessarily tdy)
        );

        // check if unresolved reminders has passed its due time (with 5 mins grace)
        AdherenceLog? effectiveLog = matchingLog;

        final isUnresolved =
            matchingLog == null || matchingLog.status == LogStatus.snoozed;

        if (isUnresolved && _isToday(selectedDate)) {
          // selectedDate might be past dates, if not tdy nonid check 
          final now = TimeOfDay.now();
          final nowMinutes = now.hour * 60 + now.minute;

          final baseMinutes = time.hour * 60 + time.minute; // ori time
          final snoozeOffset =
              (matchingLog?.snoozeCount ?? 0) * 10; // snoozed time, if any
          final targetMinutes = baseMinutes + snoozeOffset;
          final deadline = targetMinutes + 5; // +5mins grace

          // pop up reminder dialog 
          // if we are inside the ACTIVE time window for this medication
          if (nowMinutes >= targetMinutes && nowMinutes <= deadline) {
            final popKey = '${med.id}_${targetMinutes}_${selectedDate.day}';
            if (!_poppedForegroundDialogs.contains(popKey)) {
              _poppedForegroundDialogs.add(popKey); // add into the popped list

              // wait for the current build frame to finish before showing dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  showReminderDialog(context, med);
                }
              });
            }
          }

          // reminder time passed (with 5-min grace)
          if (nowMinutes > deadline) {
            effectiveLog = AdherenceLog(
              id: '',
              medicationId: med.id,
              userId: med.userId,
              date: selectedDate,
              scheduledTime: time,
              status: LogStatus.missed,
              snoozeCount: matchingLog?.snoozeCount ?? 0,
            );

            // log to backend safely
            // use unique key for this dose to ensure only write once per session
            final uniqueDoseKey =
                '${med.id}_${time.hour}_${time.minute}_${selectedDate.day}';

            if (!_autoProcessedMissedLogs.contains(uniqueDoseKey)) {
              _autoProcessedMissedLogs.add(uniqueDoseKey);

              // log as missed
              // fire-and-forget (no await), won't block the UI build
              _logService.logMissed(
                medicationId: med.id,
                userId: med.userId,
                scheduledTime: time,
                date: selectedDate,
              );
            }
          }
        }

        // create daily task
        tasks.add(
          DailyTask(medication: med, scheduledTime: time, log: effectiveLog),
        );
      }
    }

    // sort tasks by time
    tasks.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return tasks;
  }

  Future<void> _handleTakeTask(DailyTask task) async {
    await _logService.logTaken(
      medicationId: task.medication.id,
      userId: task.medication.userId,
      scheduledTime: task.scheduledTime,
      date: _selectedDate,
    );
  }

  Future<void> _handleSnoozeTask(DailyTask task) async {
    await _logService.logSnoozed(
      medicationId: task.medication.id,
      userId: task.medication.userId,
      scheduledTime: task.scheduledTime,
      date: _selectedDate,
    );

    await _notificationService.scheduleSnoozeReminder(
      task.medication,
      task.scheduledTime,
    );
  }

  Future<void> _handleSkipTask(DailyTask task) async {
    await _logService.logMissed(
      medicationId: task.medication.id,
      userId: task.medication.userId,
      scheduledTime: task.scheduledTime,
      date: _selectedDate,
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final diff = today.difference(thatDay).inDays;

    final timeStr = DateFormat('h:mm a').format(timestamp);

    if (diff == 0) {
      return 'Today, $timeStr';
    } else if (diff == 1) {
      return 'Yesterday, $timeStr';
    } else {
      return '${DateFormat('MMM d, yyyy').format(timestamp)}, $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    // can apply different styles to different parts of the text
                    TextSpan(
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                      ), // set font size for all text, DRY principle
                      children: [
                        // month
                        TextSpan(
                          text:
                              '${_formatMonthYear(_selectedMonth).split(' ')[0]} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // year
                        TextSpan(
                          text: _formatMonthYear(_selectedMonth).split(' ')[1],
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),

                  // arrow button
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        actions: [
          // automatically stuck to right
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: _uid)
                    .where('read', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data?.docs.length ?? 0;
                  return Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text('$unreadCount'),
                    backgroundColor: AppColours.primaryGreen,
                    textColor: Colors.white,
                    child: const Icon(
                      Icons.notifications_none,
                      color: AppColours.primaryGreen,
                    ),
                  );
                },
              ),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: StreamBuilder<List<Medication>>(
        stream: _medService.streamMedications(_uid),
        builder: (context, medSnap) {
          return StreamBuilder<List<AdherenceLog>>(
            stream: _logService.streamLogsForDate(_uid, _selectedDate),
            builder: (context, logSnap) {
              // wait for the first medication load
              if (medSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final medications = medSnap.data ?? [];
              final logs = logSnap.data ?? [];

              // build today's tasks from LIVE data
              final todayTasks = _generateTasksForDate(
                _selectedDate,
                medications,
                logs,
              );

              // calculate today's adherence summary
              // knt use overal patient adherence stats cuz might chg date
              final total = todayTasks.length;
              final taken = todayTasks
                  .where((t) => t.log?.status == LogStatus.taken)
                  .length;
              final missed = todayTasks
                  .where((t) => t.log?.status == LogStatus.missed)
                  .length;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 16,
                        ), // space cuz body directly touches edge of app bar
                        // date selector
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: DateSelector(
                            selectedMonth: _selectedMonth,
                            selectedDate: _selectedDate,
                            onDateChanged: (DateTime newDate) {
                              setState(() {
                                _selectedDate = newDate;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // summary cards
                        SummaryCards(
                          total: total,
                          taken: taken,
                          missed: missed,
                        ),

                        // message of the day
                        StreamBuilder<List<CaregiverRelationship>>(
                          stream: _caregiverService
                              .streamRelationshipsForPatient(_uid),
                          builder: (context, caregiverSnap) {
                            final relationships = caregiverSnap.data ?? [];
                            if (relationships.isEmpty ||
                                relationships.every(
                                  (r) =>
                                      r.relationship !=
                                      CaregiverRelationshipType
                                          .primaryCaregiver,
                                )) {
                              return const SizedBox(height: 30);
                            }

                            return StreamBuilder<MessageOfTheDay?>(
                              stream: _messageService.streamMessageForPatient(
                                _uid,
                              ),
                              builder: (context, msgSnap) {
                                final messageData = msgSnap.data;
                                if (messageData == null ||
                                    messageData.message.isEmpty) {
                                  return const SizedBox(height: 30);
                                }

                                return FutureBuilder<String>(
                                  initialData:
                                      _caregiverNameCache[messageData
                                          .caregiverId],
                                  future:
                                      _caregiverNameCache.containsKey(
                                        messageData.caregiverId,
                                      )
                                      ? null
                                      : _cachedCaregiverName(
                                          messageData.caregiverId,
                                        ),
                                  builder: (context, userSnap) {
                                    if (!userSnap.hasData &&
                                        userSnap.connectionState ==
                                            ConnectionState.waiting) {
                                      return const SizedBox();
                                    }
                                    final caregiverName =
                                        userSnap.data ?? 'Caregiver';
                                    final formattedTime = _formatMessageTime(
                                      messageData.timestamp,
                                    );

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 20,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColours.primaryPink,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),

                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  messageData.message,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '$caregiverName · $formattedTime',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // medication list (fills remaining screen height)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: MedicationList(
                      todayTasks: todayTasks,
                      onTaken: _handleTakeTask,
                      onSnooze: _handleSnoozeTask,
                      onSkip: _handleSkipTask,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
