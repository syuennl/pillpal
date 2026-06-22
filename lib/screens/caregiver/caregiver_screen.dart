import 'package:flutter/material.dart';
import '../../widgets/common/dashboard_header.dart';
import '../../widgets/caregiver/caregiver_tab_bar.dart';
import '../../widgets/caregiver/notification_alert_card.dart';
import '../../widgets/caregiver/patient_card.dart';
import '../../widgets/caregiver/caregiver_card.dart';
import '../../utils/app_colours.dart';
import '../../mock/caregiver.dart';
import '../../mock/user_profile.dart';
import '../../view_models/overall_patient_adherence_stats.dart';
import 'add_patient_screen.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  String _activeTab = 'My Patients';
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final String currentUserId = mockUsers[0].id; // John Doe

    final myPatients = mockCaregiverRelationships
        .where((r) => r.caregiverId == currentUserId)
        .map((r) => mockUsers.firstWhere((u) => u.id == r.patientId)) // get user obj
        .toList();

    final myCaregivers = mockCaregiverRelationships
        .where((r) => r.patientId == currentUserId) // get relationship obj
        .toList();

    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      body: Column(
        children: [
          // header
          DashboardHeader(
            title: 'Caregiver',
            subtitle:
                '${myPatients.length} patient${myPatients.length == 1 ? '' : 's'} under your care',
            onAddPressed: () async {
              // async + result == true -->freeze parent screen to wait for child screen to close, so it can auto refresh wif new data when come back
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPatientScreen(),
                ),
              );

              if (result == true) {
                // when child closed, navigator.pop(context, true) passes true back
                setState(
                  () {}, // refresh
                ); // if din check parent blindly runs setState (refresh + query db), wastes battery and memory
              }
            },
          ),

          // tab bar
          CaregiverTabBar(
            activeTab: _activeTab,
            onTabChanged: (tab) {
              setState(() {
                _activeTab = tab;
              });
            },
          ),

          // tab content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24.0),
              children: [
                if (_activeTab == 'My Patients') ...[
                  // patients tab
                  // notification alert
                  NotificationAlertCard(
                    isEnabled: _notificationsEnabled,
                    onEnablePressed: () {
                      setState(() {
                        _notificationsEnabled = true;
                      });
                    },
                  ),
                  const SizedBox(height: 4),

                  ...myPatients.map((patient) {
                    final stats = mockPatientMetrics[patient.id] ??
                        OverallPatientAdherenceStats(
                          takenToday: 0,
                          missedToday: 0,
                          totalTaken: 0,
                          totalMissed: 0,
                          totalSnoozed: 0,
                          adherencePercentage: 100.0,
                        );
                    return PatientCard(patient: patient, stats: stats);
                  }),
                ] else ...[
                  // caregiver tab
                  ...myCaregivers.map(
                    (relationship) =>
                        CaregiverCard(caregiverRelationship: relationship),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
