import 'package:pillpal/mock/user_profile.dart';
import '../models/caregiver_relationship.dart';
import '../view_models/overall_patient_adherence_stats.dart';

final List<CaregiverRelationship> mockCaregiverRelationships = [
  // john doe's caregivers
  CaregiverRelationship(
    id: '1',
    patientId: mockUsers[0].id, // john doe
    caregiverId: mockUsers[1].id, // michael chen
    relationship: CaregiverRelationshipType.familyMember,
    sinceDate: DateTime(2024, 3),
  ),

  CaregiverRelationship(
    id: '2',
    patientId: mockUsers[0].id,
    caregiverId: mockUsers[2].id, // sarah johnson
    relationship: CaregiverRelationshipType.primaryCaregiver,
    sinceDate: DateTime(2024, 1, 10),
  ),

  // john doe's patients
  CaregiverRelationship(
    id: '3',
    patientId: mockUsers[4].id, // robert johnson
    caregiverId: mockUsers[0].id, // john doe
    relationship: CaregiverRelationshipType.primaryCaregiver,
    sinceDate: DateTime(2024, 6, 2),
  ),

  CaregiverRelationship(
    id: '4',
    patientId: mockUsers[5].id, // laura smith
    caregiverId: mockUsers[0].id,
    relationship: CaregiverRelationshipType.primaryCaregiver,
    sinceDate: DateTime(2024, 8, 18),
  ),

  CaregiverRelationship(
    id: '5',
    patientId: mockUsers[3].id, // jane doe
    caregiverId: mockUsers[0].id,
    relationship: CaregiverRelationshipType.familyMember,
    sinceDate: DateTime(2024, 8, 25),
  ),

  // robert johnson's patients
  CaregiverRelationship(
    id: '6',
    patientId: mockUsers[1].id, // michael chen
    caregiverId: mockUsers[2].id, // sarah johnson
    relationship: CaregiverRelationshipType.primaryCaregiver,
    sinceDate: DateTime(2024, 10, 7),
  ),

  // robert johnson's patients
  CaregiverRelationship(
    id: '7',
    patientId: mockUsers[2].id, // sarah johnson
    caregiverId: mockUsers[4].id, // robert johnson
    relationship: CaregiverRelationshipType.familyMember,
    sinceDate: DateTime(2024, 11, 22),
  ),
];

// mock metrics map for patient users
final Map<String, OverallPatientAdherenceStats> mockPatientMetrics = {
  mockUsers[3].id: OverallPatientAdherenceStats(
    // jane doe
    takenToday: 2,
    missedToday: 0,
    totalTaken: 56,
    totalMissed: 1,
    totalSnoozed: 2,
    adherencePercentage: 98.0,
  ),
  mockUsers[4].id: OverallPatientAdherenceStats(
    // robert johnson
    takenToday: 1,
    missedToday: 4,
    totalTaken: 25,
    totalMissed: 30,
    totalSnoozed: 5,
    adherencePercentage: 45.0,
  ),
  mockUsers[5].id: OverallPatientAdherenceStats(
    // laura smith
    takenToday: 3,
    missedToday: 1,
    totalTaken: 85,
    totalMissed: 15,
    totalSnoozed: 0,
    adherencePercentage: 85.0,
  ),
};
