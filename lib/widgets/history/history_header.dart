import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import 'history_filter_chip.dart';

class HistoryHeader extends StatelessWidget {
  final int totalRecords;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const HistoryHeader({
    super.key,
    required this.totalRecords,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColours.primaryGreen,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24, // Safe area + padding
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalRecords records',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              HistoryFilterChip(
                label: 'All',
                isSelected: activeFilter == 'All',
                onTap: () => onFilterChanged('All'),
              ),
              const SizedBox(width: 8),
              HistoryFilterChip(
                label: 'Taken',
                isSelected: activeFilter == 'Taken',
                onTap: () => onFilterChanged('Taken'),
              ),
              const SizedBox(width: 8),
              HistoryFilterChip(
                label: 'Missed',
                isSelected: activeFilter == 'Missed',
                onTap: () => onFilterChanged('Missed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
