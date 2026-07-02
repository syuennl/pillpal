import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillpal/utils/app_colours.dart';

import '../../../models/profile.dart';

import '../../widgets/profile/info_card_shell.dart';
import '../../widgets/profile/profile_content.dart';
import '../../widgets/profile/medical_content.dart';
import '../../widgets/profile/quiet_hours_content.dart';
import '../../widgets/profile/settings_content.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../login/landing_screen.dart';

import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../services/profile_service.dart';

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

  late TimeOfDay
  _quietStartTime; // holds the data during form filling, like ctrller
  late TimeOfDay _quietEndTime;

  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  final _uid = AuthService().currentUser!.uid;
  final _db = FirebaseFirestore.instance; // for user doc (name/phone)
  bool _isDataLoading = true;

  // saved snapshots
  String _userName = ''; // saved snapshot to be returned when editing cancelled
  String _userPhone = '';
  Profile? _profile; // current loaded profile

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _genderController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _allergiesController = TextEditingController();
    _medicalConditionsController = TextEditingController();

    _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
    _quietEndTime = const TimeOfDay(hour: 7, minute: 0);

    _loadData();
  }

  Future<void> _loadData() async {
    // name + phone from user doc
    final userDoc = await _db.collection('users').doc(_uid).get();
    final userData = userDoc.data() ?? {};

    final profile = await _profileService.getProfile(_uid);

    if (!mounted) return;
    setState(() {
      _profile = profile;

      _userName = userData['name'] ?? '-';
      _userPhone = userData['phone'] ?? '-';

      _resetForm();

      _isDataLoading = false;
    });
  }

  // (re)populate ctrlers w/ data during init and when edit cancels (falls back to saved snapshots)
  void _resetForm() {
    _nameController.text = _userName;
    _phoneController.text = _userPhone;

    if (_profile != null) {
      _dobController.text = _profile!.birthDate.toString().substring(0, 10);
      _genderController.text = _profile!.gender.displayName;
      _emergencyNameController.text = _profile!.emergencyContactName ?? '';
      _emergencyPhoneController.text = _profile!.emergencyContactPhone ?? '';
      _allergiesController.text = _profile!.allergies?.join(', ') ?? '';
      _medicalConditionsController.text =
          _profile!.medicalConditions?.join(', ') ?? '';
      _quietStartTime =
          _profile!.quietStartTime ?? const TimeOfDay(hour: 22, minute: 0);
      _quietEndTime =
          _profile!.quietEndTime ?? const TimeOfDay(hour: 7, minute: 0);
    }
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

  void _savePersonalInfo() async {
    // if true/!false (validation fails returns false), then return without saving
    // ! = bang operator, asserts that the value is not null
    // .validate() = runs validator func we put in the input fields, return false if error
    if (!_formKey.currentState!.validate()) return;

    // name + phone (user doc)
    await _db.collection('users').doc(_uid).set({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    }, SetOptions(merge: true));

    // the rest
    final updatedPersonalInfo = (_profile ?? _blankProfile()).copyWith(
      birthDate: DateTime.tryParse(_dobController.text) ?? _profile!.birthDate,
      gender: _parseGender(_genderController.text),
      emergencyContactName: _emergencyNameController.text.trim().isEmpty
          ? null
          : _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
          ? null
          : _emergencyPhoneController.text.trim(),
    );
    await _profileService.saveProfile(updatedPersonalInfo);

    if (!mounted) return;

    setState(() {
      _userName = _nameController.text.trim();
      _userPhone = _phoneController.text.trim();
      _profile = updatedPersonalInfo;
      _isPersonalEditing = false;
    });
  }

  void _saveMedicalInfo() async {
    final List<String> allergiesList = _allergiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final List<String> medicalConditionsList = _medicalConditionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final updatedMedicalInfo = (_profile ?? _blankProfile()).copyWith(
      medicalConditions: medicalConditionsList,
      allergies: allergiesList,
    );

    await _profileService.saveProfile(updatedMedicalInfo);

    if (!mounted) return;

    setState(() {
      _profile = updatedMedicalInfo;
      _isMedicalEditing = false;
    });
  }

  void _saveQuietHours() async {
    final updatedQuietHours = (_profile ?? _blankProfile()).copyWith(
      quietStartTime: _quietStartTime,
      quietEndTime: _quietEndTime,
    );

    await _profileService.saveProfile(updatedQuietHours);

    if (!mounted) return;

    setState(() {
      _profile = updatedQuietHours;
      _isQuietHoursEditing = false;
    });
  }

  // fallback when the user has no profile doc yet (first time)
  // nid to have something to copywith to save profile
  Profile _blankProfile() => Profile(
    id: _uid,
    userId: _uid,
    birthDate: DateTime(2000),
    gender: GenderType.preferNotToSay,
  );

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = _profile;

    Map<String, String> personalInfoMap = {
      'Full Name': _nameController.text,
      'Phone': _phoneController.text,
      'Date of Birth': profile?.birthDate.toString().substring(0, 10) ?? '-',
      'Gender': profile?.gender.displayName ?? '-',
      'Emergency Contact': (profile?.emergencyContactName?.isNotEmpty == true)
          ? '${profile!.emergencyContactName}: ${profile.emergencyContactPhone}'
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
                imageUrl: profile?.profileImagePath,
                onImageChanged: (newPath) async {
                  final updatedPfp = (_profile ?? _blankProfile()).copyWith(
                    profileImagePath: newPath,
                    clearProfileImage: newPath == null,
                  );

                  await _profileService.saveProfile(updatedPfp);
                  if (mounted) setState(() => _profile = updatedPfp);
                },
              ),
              SizedBox(height: 16),

              // name
              Text(
                _nameController.text,
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
                onCancelTapped: () {
                  setState(() {
                    _isPersonalEditing = false;
                    _resetForm();
                  });
                },
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
                onCancelTapped: () {
                  setState(() {
                    _isMedicalEditing = false;
                    _resetForm();
                  });
                },
                content: MedicalContent(
                  isEditing: _isMedicalEditing,
                  allergies: profile?.allergies ?? [],
                  medicalConditions: profile?.medicalConditions ?? [],
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
                onCancelTapped: () {
                  setState(() {
                    _isQuietHoursEditing = false;
                    _resetForm();
                  });
                },
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
                  onPressed: () async {
                    final uid = AuthService().currentUser?.uid;
                    if (uid != null) {
                      // clear FCM token
                      await FcmService().clearToken(uid);
                    }

                    // back to landing screen FIRST to unmount active screens and cancel their streams
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LandingScreen(),
                      ),
                      (route) => false,
                    );

                    // THEN sign out, preventing permission-denied errors on active streams
                    await AuthService().signOut();
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
