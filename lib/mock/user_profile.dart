import 'package:pillpal/models/user.dart';
import 'package:pillpal/models/profile.dart';

List<User> mockUsers = [
  User(id: '1', name: 'John Doe', phone: '0123456789', email: 'john@gmail.com'),

  User(
    id: '2',
    name: 'Michael Chen',
    phone: '0124567389',
    email: 'michael@gmail.com',
  ),

  User(
    id: '3',
    name: 'Sarah Johnson',
    phone: '0145869304',
    email: 'sarah@gmail.com',
  ),

  User(id: '4', name: 'Jane Doe', phone: '0129876543', email: 'jane@gmail.com'),

  User(
    id: '5',
    name: 'Robert Johnson',
    phone: '0134569872',
    email: 'robert@gmail.com',
  ),

  User(
    id: '6',
    name: 'Laura Smith',
    phone: '012948576',
    email: 'laura@gmail.com',
  ),
];

List<Profile> mockProfiles = [
  // john doe
  Profile(
    id: '1',
    userId: mockUsers[0].id,
    birthDate: DateTime(1972, 4, 14),
    gender: GenderType.male,
    profileImagePath: 'lib/utils/images/pfp.jpeg',
    emergencyContactName: 'Jane Doe',
    emergencyContactPhone: '0129876543',
    medicalConditions: const ['Hypertension', 'Type 2 Diabetes'],
    allergies: const ['Penicillin', 'Peanuts'],
    quietStartTime: null,
    quietEndTime: null,
  ),

  // michael chen
  Profile(
    id: '2',
    userId: mockUsers[1].id,
    birthDate: DateTime(1985, 9, 20),
    gender: GenderType.male,
    profileImagePath: 'lib/utils/images/pfp.jpeg',
    emergencyContactName: 'Cindy Ng',
    emergencyContactPhone: '0124682989',
    medicalConditions: const ['Hypertension'],
    allergies: const ['Peanuts', 'Dairy'],
    quietStartTime: null,
    quietEndTime: null,
  ),

  // sarah johnson
  Profile(
    id: '3',
    userId: mockUsers[2].id,
    birthDate: DateTime(1941, 7, 5),
    gender: GenderType.male,
    profileImagePath: 'lib/utils/images/pfp.jpeg',
    emergencyContactName: 'Brittany Blake',
    emergencyContactPhone: '0196845729',
    medicalConditions: const ['Hypertension'],
    allergies: null,
    quietStartTime: null,
    quietEndTime: null,
  ),

  // jane doe
  Profile(
    id: '4',
    userId: mockUsers[3].id,
    birthDate: DateTime(1974, 3, 10),
    gender: GenderType.male,
    profileImagePath: 'lib/utils/images/pfp.jpeg',
    emergencyContactName: 'John Doe',
    emergencyContactPhone: '0123456789',
    medicalConditions: null,
    allergies: null,
    quietStartTime: null,
    quietEndTime: null,
  ),

  // robert johnson
  Profile(
    id: '5',
    userId: mockUsers[4].id,
    birthDate: DateTime(1988, 1, 11),
    gender: GenderType.male,
    profileImagePath: 'lib/utils/images/pfp.jpeg',
    emergencyContactName: null,
    emergencyContactPhone: null,
    medicalConditions: null,
    allergies: null,
    quietStartTime: null,
    quietEndTime: null,
  ),

  // laura smith
  Profile(
    id: '6',
    userId: mockUsers[5].id,
    birthDate: DateTime(1945, 5, 15),
    gender: GenderType.male,
    profileImagePath: 'lib/utils/images/pfp.jpeg',
    emergencyContactName: 'Robert Johnson',
    emergencyContactPhone: '0134569872',
    medicalConditions: ['Asthma', 'Hypoglycemia'],
    allergies: ['Sulfa drugs', 'Gluten'],
    quietStartTime: null,
    quietEndTime: null,
  ),
];
