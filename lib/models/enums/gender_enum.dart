enum GenderType {
  male(displayName: 'Male'),
  female(displayName: 'Female'),
  preferNotToSay(displayName: 'Prefer not to say');

  final String displayName;

  const GenderType({required this.displayName});
}
