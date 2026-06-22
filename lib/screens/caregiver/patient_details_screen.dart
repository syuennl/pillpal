import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../models/message_of_the_day.dart';
import '../../mock/message_of_the_day.dart';
import '../../widgets/caregiver/patient_details/information_card.dart';
import '../../widgets/caregiver/patient_details/adherence_overview_card.dart';
import '../../widgets/caregiver/patient_details/today_status_card.dart';
import '../../widgets/caregiver/patient_details/current_medications_card.dart';
import '../../widgets/caregiver/patient_details/message_card.dart';
import '../../widgets/caregiver/patient_details/patient_card_shell.dart';
import '../../utils/app_colours.dart';
import '../../models/user.dart';
import '../../models/profile.dart';
import '../../models/caregiver_relationship.dart';
import '../../mock/caregiver.dart';
import '../../mock/user_profile.dart';
import '../../mock/medication.dart';
import '../../view_models/overall_patient_adherence_stats.dart';

class PatientDetailsScreen extends StatefulWidget {
  final User patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late String _messageOfDay;

  @override
  void initState() {
    super.initState();
    final patientId = widget.patient.id;
    final patientMsgData = mockMessagesOfTheDay.firstWhereOrNull((msg) => msg.patientId == patientId);
    _messageOfDay = patientMsgData?.message ??
        'Keep up the great work! Your health journey matters. 💚';
  }

  void _showEditMessageDialog() {
    final controller = TextEditingController(text: _messageOfDay);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 12.0),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
          title: const Text(
            'Message of the Day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColours.fontBrown,
            ),
          ),

          content: TextField(
            controller: controller,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Enter encouragement message...',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColours.primaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),

          actions: [
            // cancel
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // save
            ElevatedButton(
              onPressed: () {
                final newText = controller.text.trim();
                setState(() {
                  _messageOfDay = newText;
                  final index = mockMessagesOfTheDay.indexWhere((msg) => msg.patientId == widget.patient.id);
                  if (index != -1) {
                    mockMessagesOfTheDay[index] = mockMessagesOfTheDay[index].copyWith(
                      message: newText,
                      caregiverId: '1',
                      timestamp: DateTime.now(),
                    );
                  } else {
                    mockMessagesOfTheDay.add(MessageOfTheDay(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      patientId: widget.patient.id,
                      caregiverId: '1',
                      message: newText,
                      timestamp: DateTime.now(),
                    ));
                  }
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // void _showContactOptions() {
  // showModalBottomSheet(
  //   context: context,
  //   backgroundColor: Colors.white,
  //   shape: const RoundedRectangleBorder(
  //     borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //   ),
  //   builder: (context) {
  //     return SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             Text(
  //               'Contact ${widget.patient.name}',
  //               style: const TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: AppColours.fontBrown,
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             ListTile(
  //               leading: const Icon(
  //                 Icons.phone_outlined,
  //                 color: AppColours.primaryGreen,
  //               ),
  //               title: const Text('Voice Call'),
  //               subtitle: const Text('012-345 6789'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                       content: Text('Calling ${widget.patient.name}...'),
  //                       behavior: SnackBarBehavior.floating,
  //                     ),
  //                   );
  //                 },
  //               ),
  //               ListTile(
  //                 leading: const Icon(
  //                   Icons.message_outlined,
  //                   color: AppColours.primaryGreen,
  //                 ),
  //                 title: const Text('Send SMS'),
  //                 subtitle: const Text('012-345 6789'),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text(
  //                         'Opening message composer for ${widget.patient.name}...',
  //                       ),
  //                       behavior: SnackBarBehavior.floating,
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final patientMedications = mockMedications
        .where((m) => m.userId == widget.patient.id)
        .toList();

    CaregiverRelationship? relationship;
    for (var r in mockCaregiverRelationships) {
      if (r.caregiverId == '1' && r.patientId == widget.patient.id) {
        relationship = r;
        break;
      }
    }
    final isPrimaryCaregiver =
        relationship?.relationship == CaregiverRelationshipType.primaryCaregiver;

    final metrics =
        mockPatientMetrics[widget.patient.id] ??
        OverallPatientAdherenceStats(
          takenToday: 0,
          missedToday: 0,
          totalTaken: 0,
          totalMissed: 0,
          totalSnoozed: 0,
          adherencePercentage: 100.0,
        );

    final profile = mockProfiles.firstWhere(
      (p) => p.userId == widget.patient.id,
      orElse: () => Profile(
        id: '',
        userId: widget.patient.id,
        birthDate: DateTime(1980, 5, 15),
        gender: GenderType.male,
      ),
    );

    double adherenceRate = metrics.adherencePercentage;
    int takenCount = metrics.totalTaken;
    int missedCount = metrics.totalMissed;
    int takenToday = metrics.takenToday;
    int missedToday = metrics.missedToday;
    int snoozedCount = metrics.totalSnoozed;

    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      appBar: const CustomAppBar(
        title: 'Patient Details',
        showBackButton: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // patient info card
            PatientCardShell(
              title: 'Information',
              isLargeTitle: true,
              content: InformationCard(
                name: widget.patient.name,
                phone: widget.patient.phone ?? '',
                dateOfBirth: DateFormat(
                  'MMMM d, yyyy',
                ).format(profile.birthDate),
              ),
            ),

            PatientCardShell(
              title: 'Adherence Overview',
              content: AdherenceOverviewCard(
                adherenceRate: adherenceRate.toInt(),
                taken: takenCount,
                missed: missedCount,
                snoozed: snoozedCount,
              ),
            ),

            PatientCardShell(
              title: 'Today\'s Status',
              content: TodayStatusCard(
                takenToday: takenToday,
                missedToday: missedToday,
              ),
            ),

            PatientCardShell(
              title: 'Current Medications (${patientMedications.length})',
              content: CurrentMedicationsCard(medications: patientMedications),
            ),

            if (isPrimaryCaregiver)
              PatientCardShell(
                title: 'Message of the Day',
                icon: Icons.favorite_border,
                content: MessageCard(
                  message: _messageOfDay,
                  onEditPressed: _showEditMessageDialog,
                ),
              ),
            // const SizedBox(height: 16),

            // action buttons
            // Padding(
            // padding: const EdgeInsets.symmetric(horizontal: 16),
            // child: Row(
            //     children: [
            //       Expanded(
            //         child: ElevatedButton(
            //           onPressed: () {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               SnackBar(
            //                 content: Text('Reminder sent to ${widget.patient.name}!'),
            //                 behavior: SnackBarBehavior.floating,
            //                 backgroundColor: AppColours.primaryGreen,
            //               ),
            //             );
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColours.primaryGreen,
            //             elevation: 0,
            //             padding: const EdgeInsets.symmetric(vertical: 16),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(16),
            //             ),
            //           ),
            //           child: const Text(
            //             'Send Reminder',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 14,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ),
            //       const SizedBox(width: 12),

            //       Expanded(
            //         child: ElevatedButton(
            //           onPressed: _showContactOptions,
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColours.buttonGrey,
            //             elevation: 0,
            //             padding: const EdgeInsets.symmetric(vertical: 16),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(16),
            //             ),
            //           ),
            //           child: Text(
            //             'Contact Patient',
            //             style: TextStyle(
            //               color: Colors.grey[800],
            //               fontSize: 14,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
