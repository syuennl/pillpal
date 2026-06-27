import 'package:flutter/material.dart';
import '../widgets/history/history_header.dart';
import '../widgets/history/history_record_group.dart';
import '../widgets/history/history_record_card.dart';

import '../utils/app_colours.dart';
import '../models/adherence_log.dart';
import '../view_models/history_group.dart';

import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  final bool isActive;
  const HistoryScreen({super.key, this.isActive = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'All';
  late Future<List<HistoryGroup>> _historyGroupsFuture;

  @override
  void initState() {
    super.initState();
    _historyGroupsFuture = HistoryService.getHistoryGroups();
  }

  @override
  // runs whenever parent widget (bottom tab bar wrapper) updates this screen
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // is screen active now, but not moment ago? e.g., user just tapped & switched to History
    if (widget.isActive && !oldWidget.isActive) { 
      _refreshHistory();
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _historyGroupsFuture = HistoryService.getHistoryGroups();
    });
  }
  // since MainWrapper uses IndexedStack to preserve screen states across bottom navigation tabs, 
  // initState on HistoryScreen only called once 
  // if user recorded a dose as "Taken" on Home, switched to History, history list x refresh 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      body: FutureBuilder<List<HistoryGroup>>(
        // future is a Promise for db calls
        future: _historyGroupsFuture,
        builder: (context, snapshot) {
          // isLoading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColours.primaryGreen,
              ), // loading spinner
            );
          }

          // onError
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // data retrieved
          final historyGroups = snapshot.data ?? [];

          // calculate total records regardless of filter
          int totalRecords = 0;
          for (var group in historyGroups) {
            totalRecords += group.records.length;
          }

          // filter logic
          List<Widget> groupWidgets = [];
          for (var group in historyGroups) {
            List<HistoryRecordCard> filteredCards = [];

            // filtering records
            for (var record in group.records) {
              bool shouldInclude = false;
              if (_activeFilter == 'All') {
                shouldInclude = true;
              }
              if (_activeFilter == 'Taken' && record.status == LogStatus.taken) {
                shouldInclude = true;
              }
              if (_activeFilter == 'Missed' &&
                  record.status == LogStatus.missed) {
                shouldInclude = true;
              }

              if (shouldInclude) {
                filteredCards.add(
                  HistoryRecordCard(
                    medicationName: record.medicationName,
                    timeTaken: record.timeTaken,
                    scheduledTime: record.scheduledTime,
                    status: record.status,
                    iconType: record.iconType,
                  ),
                );
              }
            }

            // only add the group if it has records after filtering
            if (filteredCards.isNotEmpty) {
              groupWidgets.add(
                HistoryRecordGroup(
                  dateHeader: group.dateHeader,
                  records: filteredCards,
                ),
              );
            }
          }

          return Column(
            children: [
              HistoryHeader(
                totalRecords: totalRecords,
                activeFilter: _activeFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _activeFilter = filter;
                  });
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColours.primaryGreen,
                  onRefresh: _refreshHistory,
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      left: 24.0,
                      right: 24.0,
                      bottom: 24.0,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: groupWidgets,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
