import '../view_models/patient_info.dart';
import '../view_models/caregiver_info.dart';

// mock data for caregiver screen
final List<PatientInfo> mockPatients = [
  PatientInfo(
    id: '1',
    name: 'Robert Johnson',
    medicationsCount: 5,
    missedDosesToday: 4,
    adherenceRate: 45,
  ),
  PatientInfo(
    id: '2',
    name: 'John Doe',
    medicationsCount: 4,
    missedDosesToday: 1,
    adherenceRate: 85,
  ),
  PatientInfo(
    id: '3',
    name: 'Jane Smith',
    medicationsCount: 2,
    missedDosesToday: 0,
    adherenceRate: 98,
  ),
];

final List<CaregiverInfo> mockCaregivers = [
  CaregiverInfo(
    id: '1',
    name: 'Michael Chen',
    relationship: 'Family Member',
    phone: '+1 (555) 345-6789',
    sinceDate: 'Mar 2024',
  ),
  CaregiverInfo(
    id: '2',
    name: 'Sarah Johnson',
    relationship: 'Primary Caregiver',
    phone: '+1 (555) 234-5678',
    sinceDate: 'Jan 2024',
  ),
];
