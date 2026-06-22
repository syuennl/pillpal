import 'package:flutter/material.dart';
import 'history_record_card.dart';

class HistoryRecordGroup extends StatelessWidget {
  final String dateHeader;
  final List<HistoryRecordCard> records;

  const HistoryRecordGroup({
    super.key,
    required this.dateHeader,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            dateHeader.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...records,
        const SizedBox(height: 8),
      ],
    );
  }
}
