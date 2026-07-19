import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colours.dart';

import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/caregiver/patient_details/information_card.dart';
import '../../widgets/caregiver/patient_details/adherence_overview_card.dart';
import '../../widgets/caregiver/patient_details/today_status_card.dart';
import '../../widgets/caregiver/patient_details/current_medications_card.dart';
import '../../widgets/caregiver/patient_details/message_card.dart';
import '../../widgets/caregiver/patient_details/patient_card_shell.dart';

import '../../models/user.dart';
import '../../models/profile.dart';
import '../../models/caregiver_relationship.dart';
import '../../models/message_of_the_day.dart';
import '../../models/medication.dart';
import '../../view_models/overall_patient_adherence_stats.dart';

import '../../services/auth_service.dart';
import '../../services/caregiver_service.dart';
import '../../services/profile_service.dart';
import '../../services/medication_service.dart';
import '../../services/adherence_log_service.dart';
import '../../services/message_of_the_day_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  final User patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _authService = AuthService();
  final _caregiverService = CaregiverService();
  final _profileService = ProfileService();
  final _medicationService = MedicationService();
  final _adherenceLogService = AdherenceLogService();
  final _messageService = MessageOfTheDayService();

  bool _isLoading = true;
  Profile? _profile;
  OverallPatientAdherenceStats? _metrics;
  bool _isPrimaryCaregiver = false;
  String? _relationshipId;
  String? _messageOfDayId;
  String _messageOfDay =
      'Keep up the great work! Your health journey matters. 💚';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patientId = widget.patient.id;
    final currentUid = _authService.currentUser?.uid; // caregiver id

    try {
      final results = await Future.wait([
        _profileService.getProfile(patientId),
        _adherenceLogService.getPatientStats(patientId),
        _messageService.getMessageForPatient(patientId),
        if (currentUid != null)
          _caregiverService.streamRelationshipsForPatient(patientId).first,
      ]);

      _profile = results[0] as Profile?;
      _metrics = results[1] as OverallPatientAdherenceStats?;
      final msg = results[2] as MessageOfTheDay?;

      if (msg != null && msg.message.isNotEmpty) {
        _messageOfDayId = msg.id;
        _messageOfDay = msg.message;
      }

      if (currentUid != null && results.length > 3) {
        final rels = results[3] as List<CaregiverRelationship>;
        final currentRel = rels
            .where((r) => r.caregiverId == currentUid)
            .firstOrNull;

        if (currentRel != null) {
          _relationshipId = currentRel.id;
          _isPrimaryCaregiver =
              currentRel.relationship ==
              CaregiverRelationshipType.primaryCaregiver;
        }
      }
    } catch (e) {
      debugPrint('Error loading patient details: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            maxLength: 60,
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
              onPressed: () async {
                final newText = controller.text.trim();
                Navigator.pop(context); // close dialog immediately

                setState(() => _messageOfDay = newText);

                final msg = MessageOfTheDay(
                  id:
                      _messageOfDayId ??
                      widget.patient.id, // use patientId as doc id
                  patientId: widget.patient.id,
                  caregiverId: _authService.currentUser?.uid ?? '',
                  message: newText,
                  timestamp: DateTime.now(),
                );

                try {
                  await _messageService.saveMessage(msg);
                } catch (e) {
                  debugPrint('Error saving message: $e');
                }
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

  void _showRemovePatientDialog() {
    final patientName = widget.patient.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Patient'),
        content: Text(
          'Are you sure you want to stop caring for $patientName? You will no longer have access to their medication data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final relId =
                  _relationshipId!; // safe as _relationshipId is not null here

              // pop the dialog
              Navigator.pop(context);

              // pop the Patient Details Screen immediately
              // to disposes all active streams (medications/logs) bfr revoke access
              if (context.mounted) {
                Navigator.pop(context);
              }

              // wait for route pop animation to completely finish 
              // so that the StreamBuilders are completely disposed bfr access is revoked
              await Future.delayed(const Duration(milliseconds: 400));

              try {
                await _caregiverService.unlink(relId);
              } catch (e) {
                debugPrint('Error unlinking patient: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColours.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      appBar: CustomAppBar(
        title: 'Patient Details',
        showBackButton: true,
        actions: _relationshipId == null
            ? null
            : [
                // delete btn
                IconButton(
                  icon: const Icon(Icons.person_remove_outlined),
                  color: Colors.white,
                  tooltip: 'Remove Patient',
                  onPressed: _showRemovePatientDialog,
                ),
              ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColours.primaryGreen),
            )
          : SingleChildScrollView(
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
                      ).format(_profile?.birthDate ?? DateTime(1980, 1, 1)),
                    ),
                  ),

                  PatientCardShell(
                    title: 'Adherence Overview',
                    content: AdherenceOverviewCard(
                      adherenceRate:
                          _metrics?.adherencePercentage.toInt() ?? 100,
                      taken: _metrics?.totalTaken ?? 0,
                      missed: _metrics?.totalMissed ?? 0,
                      snoozed: _metrics?.totalSnoozed ?? 0,
                    ),
                  ),

                  PatientCardShell(
                    title: 'Today\'s Status',
                    content: TodayStatusCard(
                      takenToday: _metrics?.takenToday ?? 0,
                      missedToday: _metrics?.missedToday ?? 0,
                    ),
                  ),

                  StreamBuilder<List<Medication>>(
                    stream: _medicationService.streamMedications(
                      widget.patient.id,
                    ),
                    builder: (context, snapshot) {
                      final medications = snapshot.data ?? [];
                      return PatientCardShell(
                        title: 'Current Medications (${medications.length})',
                        content: CurrentMedicationsCard(
                          medications: medications,
                        ),
                      );
                    },
                  ),

                  if (_isPrimaryCaregiver)
                    PatientCardShell(
                      title: 'Message of the Day',
                      icon: Icons.favorite_border,
                      content: MessageCard(
                        message: _messageOfDay,
                        onEditPressed: _showEditMessageDialog,
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
