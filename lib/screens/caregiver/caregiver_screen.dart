import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colours.dart';

import '../../widgets/common/dashboard_header.dart';
import '../../widgets/caregiver/caregiver_tab_bar.dart';
// import '../../widgets/caregiver/notification_alert_card.dart';
import '../../widgets/caregiver/patient_card.dart';
import '../../widgets/caregiver/caregiver_card.dart';
import 'add_patient_screen.dart';

import '../../view_models/overall_patient_adherence_stats.dart';
import '../../models/user.dart';
import '../../models/caregiver_relationship.dart';

import '../../services/auth_service.dart';
import '../../services/caregiver_service.dart';
import '../../services/adherence_log_service.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  String _activeTab = 'My Patients';
  // bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final _usersCollection = FirebaseFirestore.instance.collection('users');
    final _uid = AuthService().currentUser!.uid;
    final _caregiverService = CaregiverService();
    final _adherenceLogService = AdherenceLogService();

    final myPatients = _caregiverService.streamRelationshipsForCaregiver(_uid);
    final myCaregivers = _caregiverService.streamRelationshipsForPatient(_uid);

    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      body: Column(
        children: [
          // header
          StreamBuilder<List<CaregiverRelationship>>(
            stream: myPatients,
            builder: (context, snapshot) {
              final patientsCount = snapshot.data?.length ?? 0;
              return DashboardHeader(
                title: 'Caregiver',
                subtitle:
                    '$patientsCount patient${patientsCount == 1 ? '' : 's'} under your care',
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
              );
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
                // patients tab
                if (_activeTab == 'My Patients') ...[
                  // notification alert
                  // NotificationAlertCard(
                  //   isEnabled: _notificationsEnabled,
                  //   onEnablePressed: () {
                  //     setState(() {
                  //       _notificationsEnabled = true;
                  //     });
                  //   },
                  // ),
                  // const SizedBox(height: 4),
                  StreamBuilder<List<CaregiverRelationship>>(
                    stream: myPatients,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final rels = snapshot.data!;
                      // no patients
                      if (rels.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No patients linked yet.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      // has patients
                      return FutureBuilder<List<User>>(
                        future: Future.wait(
                          // wait for all patients to be fetched into a list
                          rels.map((r) async {
                            final doc = await _usersCollection
                                .doc(r.patientId)
                                .get();
                            final data = doc.data() ?? {};
                            return User(
                              id: doc.id,
                              name: data['name'] ?? 'Unknown',
                              email: data['email'] ?? '',
                              phone: data['phone'],
                            );
                          }),
                        ),
                        builder: (context, usersSnapshot) {
                          if (!usersSnapshot.hasData) {
                            // still loading
                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          return Column(
                            children: usersSnapshot.data!.map((patient) {
                              return FutureBuilder<
                                OverallPatientAdherenceStats
                              >(
                                future: _adherenceLogService.getPatientStats(
                                  patient.id,
                                ),
                                builder: (context, statsSnap) {
                                  final stats =
                                      statsSnap.data ??
                                      OverallPatientAdherenceStats(
                                        takenToday: 0,
                                        missedToday: 0,
                                        totalTaken: 0,
                                        totalMissed: 0,
                                        totalSnoozed: 0,
                                        adherencePercentage: 100.0,
                                      );
                                  return PatientCard(
                                    patient: patient,
                                    stats: stats,
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                ] else ...[
                  // caregiver tab
                  StreamBuilder<List<CaregiverRelationship>>(
                    stream: myCaregivers,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final rels = snapshot.data!;
                      if (rels.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No caregivers linked yet.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return Column(
                        children: rels
                            .map(
                              (relationship) => CaregiverCard(
                                caregiverRelationship: relationship,
                              ),
                            )
                            .toList(),
                      );
                    },
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
