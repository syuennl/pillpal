import 'package:pillpal/models/user.dart';
import 'package:pillpal/models/profile.dart';

final mockUser = User(
  id: '1',
  name: 'John Doe',
  phone: '0123456789',
  email: 'johndoe8@gmail.com',
);

final mockProfile = Profile(
  id: '1',
  userId: mockUser.id,
  birthDate: DateTime(1972, 4, 14),
  gender: GenderType.male,
  // profileImagePath: ,
  emergencyContactName: 'Jane Doe',
  emergencyContactPhone: '0129876543',
  // medicalCondition: ,
  // allergies: [],
  // quietStartTime: DateTime(),
  // quietEndTime: DateTime(),
);
