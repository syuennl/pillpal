enum CaregiverRelationshipType {
  primaryCaregiver(displayName: 'Primary Caregiver'),
  familyMember(displayName: 'Family Member'),
  friend(displayName: 'Friend'),
  healthcareProfessional(displayName: 'Healthcare Professional');

  final String displayName;

  const CaregiverRelationshipType({required this.displayName});
}
