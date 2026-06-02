import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../widgets/home/date_selector.dart';
import '../widgets/home/summary_cards.dart';
import '../widgets/home/medication_list.dart';
import '../models/adherence_log.dart';
import '../view_models/daily_task.dart';
import '../mock/medication.dart';
import '../mock/adherence_log.dart';
import '../mock/app_notification.dart';
import '../utils/app_colours.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedMonth;
  late DateTime _selectedDate;

  // set default date to current date
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedMonth = DateTime(now.year, now.month, 1);
    // knt put now.month only, datetime first param must be year
    // the 1 is to init to 1st day, to prevent cases where on 31/5, user clicks april, sys deducts 1 month = 31/4, invalid date
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

  List<DailyTask> _generateTasksForDate(DateTime selectedDate) {
    List<DailyTask> tasks = [];

    for (var med in mockMedications) {
      for (var time in med.scheduledTimes) {
        AdherenceLog? matchingLog;

        // find if there's a log recorded for the med at the scheduled time

        matchingLog = mockAdherenceLogs.firstWhereOrNull(
          (log) =>
              log.medicationId == med.id &&
              log.scheduledTime == time &&
              // knt use isAtSameMomentAs cuz both dates includes millisec cuz of DateTime.now()
              log.date.year == selectedDate.year &&
              // dey r initialised at different millisecs so will be different
              log.date.month == selectedDate.month &&
              log.date.day == selectedDate.day,
        );

        // create daily task
        tasks.add(
          DailyTask(medication: med, scheduledTime: time, log: matchingLog),
        );
      }
    }

    // sort tasks by time
    tasks.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return tasks;
  }

  void _handleTakeTask(DailyTask task) {
    _updateAdherenceLog(task, LogStatus.taken);
  }

  void _handleSnoozeTask(DailyTask task) {
    _updateAdherenceLog(task, LogStatus.snoozed, incrementSnooze: true);
  }

  void _handleSkipTask(DailyTask task) {
    _updateAdherenceLog(task, LogStatus.missed);
  }

  void _updateAdherenceLog(
    DailyTask task,
    LogStatus status, {
    bool incrementSnooze = false,
  }) {
    setState(() {
      final existingLog = task.log;

      if (existingLog != null) {
        final index = mockAdherenceLogs.indexOf(existingLog);
        if (index != -1) {
          mockAdherenceLogs[index] = existingLog.copyWith(
            status: status,
            takenTime: status == LogStatus.taken ? TimeOfDay.now() : null,
            snoozeCount: incrementSnooze
                ? existingLog.snoozeCount + 1
                : existingLog.snoozeCount,
          );
        }
      } else {
        final newLog = AdherenceLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          medicationId: task.medication.id,
          userId: task.medication.userId,
          date: _selectedDate,
          scheduledTime: task.scheduledTime,
          takenTime: status == LogStatus.taken ? TimeOfDay.now() : null,
          status: status,
          snoozeCount: incrementSnooze ? 1 : 0,
        );
        mockAdherenceLogs.add(newLog);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotificationsCount = mockNotifications.where((n) => !n.read).length;
    
    // build today's tasks
    List<DailyTask> todayTasks = _generateTasksForDate(_selectedDate);

    // calculate today's adherence summary
    int total = todayTasks.length;
    int taken = todayTasks
        .where((task) => task.log?.status == LogStatus.taken)
        .length;
    int missed = todayTasks
        .where((task) => task.log?.status == LogStatus.missed)
        .length;

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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
              icon: Badge(
                isLabelVisible: unreadNotificationsCount > 0,
                label: Text('$unreadNotificationsCount'),
                backgroundColor: AppColours.primaryGreen,
                textColor: Colors.white,
                child: const Icon(
                  Icons.notifications_none,
                  color: AppColours.primaryGreen,
                ),
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

      body: SingleChildScrollView(
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
            SummaryCards(total: total, taken: taken, missed: missed),
            const SizedBox(height: 24),

            // medication list
            MedicationList(
              todayTasks: todayTasks,
              onTaken: _handleTakeTask,
              onSnooze: _handleSnoozeTask,
              onSkip: _handleSkipTask,
            ),
          ],
        ),
      ),
    );
  }
}
