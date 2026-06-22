import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../../screens/caregiver/patient_details_screen.dart';
import '../../models/user.dart';
import '../../models/profile.dart';
import '../../mock/user_profile.dart';
import '../../mock/medication.dart';
import '../../view_models/overall_patient_adherence_stats.dart';

class PatientCard extends StatelessWidget {
  final User patient;
  final OverallPatientAdherenceStats stats;

  const PatientCard({super.key, required this.patient, required this.stats});

  ImageProvider _getAvatarImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/') || path.startsWith('lib/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final profile = mockProfiles.firstWhere(
      (p) => p.userId == patient.id,
      orElse: () => Profile(
        id: '',
        userId: patient.id,
        birthDate: DateTime(1990, 1, 1),
        gender: GenderType.male,
      ),
    );
    final profileImagePath = profile.profileImagePath;

    final String name = patient.name;
    final int medicationsCount = mockMedications
        .where((m) => m.userId == patient.id)
        .length;
    final int missedDosesToday = stats.missedToday;
    final int adherenceRate = stats.adherencePercentage.toInt();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailsScreen(patient: patient),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 5),
              blurRadius: 6,
              spreadRadius: -1,
            ),
          ],
        ),

        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColours.secondaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: profileImagePath != null && profileImagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image(
                            image: _getAvatarImage(profileImagePath),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.person_outline,
                          color: AppColours.primaryGreen,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),

                // info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$medicationsCount medications',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // arrow
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),

            if (missedDosesToday > 0) ...[
              // [] returns list, ... = spread operator cuz parent (Column) cannot have a list of widgets
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColours.tertiaryRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColours.primaryRed,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$missedDosesToday missed dose${missedDosesToday > 1 ? 's' : ''} today',
                      style: const TextStyle(
                        color: AppColours.primaryRed,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // adherence percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adherence',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$adherenceRate%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: adherenceRate / 100,
                backgroundColor: Colors.grey[200],
                minHeight: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  adherenceRate >= 80
                      ? AppColours.primaryGreen
                      : AppColours.primaryRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
