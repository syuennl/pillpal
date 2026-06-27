import 'package:flutter/material.dart';
import 'pending_medication_card.dart';
import 'package:pillpal/utils/app_colours.dart';
import 'package:pillpal/view_models/daily_task.dart';
import 'medication_section.dart';
import 'missed_medication_card.dart';
import 'taken_medication_card.dart';
import 'empty_state.dart';

class MedicationList extends StatelessWidget {
  const MedicationList({
    super.key,
    required this.todayTasks,
    required this.onTaken,
    required this.onSnooze,
    required this.onSkip,
  });

  final List<DailyTask> todayTasks;
  final ValueChanged<DailyTask> onTaken;
  final ValueChanged<DailyTask> onSnooze;
  final ValueChanged<DailyTask> onSkip;

  @override
  Widget build(BuildContext context) {
    if (todayTasks.isEmpty) {
      return const EmptyState();
    }

    // split tasks by status
    final toTakeTasks = todayTasks.where((t) => t.needsAction).toList();
    final missedTasks = todayTasks.where((t) => t.isMissed).toList();
    final takenTasks = todayTasks.where((t) => t.isTaken).toList();

    return Container(
      decoration: const BoxDecoration(
        color: AppColours.primaryGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // To take (pending + snoozed)
          MedicationSection(
            title: 'To take',
            children: toTakeTasks
                .map(
                  (task) => PendingMedicationCard(
                    medication: task.medication,
                    scheduledTime: task.adjustedTime,
                    isSnoozed: task.isSnoozed,
                    onTaken: () => onTaken(task),
                    onSnooze: () => onSnooze(task),
                    onSkip: () => onSkip(task),
                  ),
                )
                .toList(),
          ),

          // gap only when both sections render
          if (toTakeTasks.isNotEmpty && missedTasks.isNotEmpty)
            const SizedBox(height: 24),

          // Missed
          MedicationSection(
            title: 'Missed',
            children: missedTasks
                .map(
                  (task) => MissedMedicationCard(
                    medication: task.medication,
                    scheduledTime: task.adjustedTime,
                    onTap: () => onTaken(task),
                  ),
                )
                .toList(),
          ),

          // gap only when both sections render
          if (missedTasks.isNotEmpty && takenTasks.isNotEmpty)
            const SizedBox(height: 24),

          // Taken
          MedicationSection(
            title: 'Taken',
            children: takenTasks
                .map(
                  (task) => TakenMedicationCard(
                    medication: task.medication,
                    scheduledTime: task.adjustedTime,
                  ),
                )
                .toList(),
          ),

          // bottom padding for scrolling
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
