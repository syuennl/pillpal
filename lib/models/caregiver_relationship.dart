import 'enums/caregiver_relationship_enum_type.dart';
export 'enums/caregiver_relationship_enum_type.dart';

class CaregiverRelationship {
  final String id;
  final String patientId;
  final String caregiverId;
  final CaregiverRelationshipType relationship;
  final DateTime sinceDate;

  CaregiverRelationship({
    required this.id,
    required this.patientId,
    required this.caregiverId,
    required this.relationship,
    required this.sinceDate,
  });

  CaregiverRelationship copyWith({
    String? id,
    String? patientId,
    String? caregiverId,
    CaregiverRelationshipType? relationship,
    DateTime? sinceDate,
  }) {
    return CaregiverRelationship(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      relationship: relationship ?? this.relationship,
      sinceDate: sinceDate ?? this.sinceDate,
    );
  }
}
