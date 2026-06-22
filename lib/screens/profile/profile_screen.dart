import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';
import '../../../mock/user_profile.dart';
import '../../../models/profile.dart';
import '../../widgets/profile/info_card_shell.dart';
import '../../widgets/profile/profile_content.dart';
import '../../widgets/profile/medical_content.dart';
import '../../widgets/profile/quiet_hours_content.dart';
import '../../widgets/profile/settings_content.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../login/landing_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPersonalEditing = false;
  bool _isMedicalEditing = false;
  bool _isQuietHoursEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  late TextEditingController _allergiesController;
  late TextEditingController _medicalConditionsController;

  late TimeOfDay _quietStartTime;
  late TimeOfDay _quietEndTime;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: mockUsers[0].name);
    _phoneController = TextEditingController(text: mockUsers[0].phone);
    _dobController = TextEditingController(
      text: mockProfiles[0].birthDate.toString().substring(0, 10),
    );
    _genderController = TextEditingController(
      text: mockProfiles[0].gender.displayName,
    );
    _emergencyNameController = TextEditingController(
      text: mockProfiles[0].emergencyContactName ?? '',
    );
    _emergencyPhoneController = TextEditingController(
      text: mockProfiles[0].emergencyContactPhone ?? '',
    );

    _allergiesController = TextEditingController(
      text: mockProfiles[0].allergies?.join(', ') ?? '',
    );
    _medicalConditionsController = TextEditingController(
      text: mockProfiles[0].medicalConditions?.join(', ') ?? '',
    );

    _quietStartTime =
        mockProfiles[0].quietStartTime ?? const TimeOfDay(hour: 22, minute: 0);
    _quietEndTime =
        mockProfiles[0].quietEndTime ?? const TimeOfDay(hour: 7, minute: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _allergiesController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  GenderType _parseGender(String text) {
    final clean = text.trim().toLowerCase();
    if (clean == 'male') return GenderType.male;
    if (clean == 'female') return GenderType.female;
    return GenderType.preferNotToSay;
  }

  void _savePersonalInfo() {
    // if true/!false (validation fails returns false), then return without saving
    // ! = bang operator, asserts that the value is not null
    // .validate() = runs validator func we put in the input fields, return false if error
    if (!_formKey.currentState!.validate()) return;

    // if false/!true (validation success returns true), copy values into model
    setState(() {
      mockUsers[0] = mockUsers[0].copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
      );

      mockProfiles[0] = mockProfiles[0].copyWith(
        birthDate:
            DateTime.tryParse(_dobController.text) ?? mockProfiles[0].birthDate,
        gender: _parseGender(_genderController.text),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
      );

      _isPersonalEditing = false;
    });
  }

  void _saveMedicalInfo() {
    setState(() {
      final List<String> allergiesList = _allergiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final List<String> medicalConditionsList = _medicalConditionsController
          .text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      mockProfiles[0] = mockProfiles[0].copyWith(
        medicalConditions: medicalConditionsList,
        allergies: allergiesList,
      );

      _isMedicalEditing = false;
    });
  }

  void _saveQuietHours() {
    setState(() {
      mockProfiles[0] = mockProfiles[0].copyWith(
        quietStartTime: _quietStartTime,
        quietEndTime: _quietEndTime,
      );
      _isQuietHoursEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> personalInfoMap = {
      'Full Name': mockUsers[0].name,
      'Phone': mockUsers[0].phone?? '',
      'Date of Birth': mockProfiles[0].birthDate.toString().substring(0, 10),
      'Gender': mockProfiles[0].gender.displayName,
      'Emergency Contact':
          (mockProfiles[0].emergencyContactName?.isNotEmpty == true)
          ? '${mockProfiles[0].emergencyContactName}: ${mockProfiles[0].emergencyContactPhone}'
          : '-',
    };

    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      appBar: const CustomAppBar(title: 'Profile'),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // pfp
              ProfileAvatar(
                imageUrl: mockProfiles[0].profileImagePath,
                onImageChanged: (newPath) {
                  setState(() {
                    if (newPath == null) {
                      mockProfiles[0] = mockProfiles[0].copyWith(
                        clearProfileImage: true,
                      );
                    } else {
                      mockProfiles[0] = mockProfiles[0].copyWith(
                        profileImagePath: newPath,
                      );
                    }
                  });
                },
              ),
              SizedBox(height: 16),

              // name
              Text(
                mockUsers[0].name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 32),

              // personal info
              InfoCardShell(
                title: 'Personal Information',
                hasTrailing: true,
                isEditing: _isPersonalEditing,
                onEditTapped: () {
                  setState(() {
                    _isPersonalEditing = true;
                  });
                },
                onSaveTapped: _savePersonalInfo,
                content: ProfileContent(
                  isEditing: _isPersonalEditing,
                  formKey: _formKey,
                  data: personalInfoMap,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  dobController: _dobController,
                  genderController: _genderController,
                  emergencyNameController: _emergencyNameController,
                  emergencyPhoneController: _emergencyPhoneController,
                ),
              ),
              SizedBox(height: 16),

              // medical info
              InfoCardShell(
                title: 'Medical Information',
                hasTrailing: true,
                isEditing: _isMedicalEditing,
                onEditTapped: () {
                  setState(() {
                    _isMedicalEditing = true;
                  });
                },
                onSaveTapped: _saveMedicalInfo,
                content: MedicalContent(
                  isEditing: _isMedicalEditing,
                  allergies: mockProfiles[0].allergies ?? [],
                  medicalConditions: mockProfiles[0].medicalConditions ?? [],
                  allergiesController: _allergiesController,
                  medicalConditionsController: _medicalConditionsController,
                ),
              ),
              SizedBox(height: 16),

              // quiet hours
              InfoCardShell(
                title: 'Quiet Hours',
                hasTrailing: true,
                isEditing: _isQuietHoursEditing,
                onEditTapped: () {
                  setState(() {
                    _isQuietHoursEditing = true;
                  });
                },
                onSaveTapped: _saveQuietHours,
                content: QuietHoursContent(
                  isEditing: _isQuietHoursEditing,
                  startTime: _quietStartTime,
                  endTime: _quietEndTime,
                  onStartTimeChanged: (time) {
                    setState(() {
                      _quietStartTime = time;
                    });
                  },
                  onEndTimeChanged: (time) {
                    setState(() {
                      _quietEndTime = time;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // settings
              InfoCardShell(
                title: 'Settings',
                hasTrailing: false,
                content: const SettingsContent(),
              ),
              const SizedBox(height: 32),

              // sign out button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LandingScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.tertiaryRed,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, color: AppColours.primaryRed),
                      SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColours.primaryRed,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // version number
              // Text(
              //   'Version 1.0.0',
              //   style: TextStyle(color: Colors.grey[500], fontSize: 14),
              // ),
              // const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
