import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colours.dart';
import '../../services/caregiver_service.dart';
import '../../services/auth_service.dart';
import '../../models/caregiver_relationship.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/caregiver/connect_card_shell.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _caregiverService = CaregiverService();
  final _authService = AuthService();

  final _codeController = TextEditingController();

  bool _isLoadingCode = false;
  bool _isRedeeming = false;
  String? _myInviteCode;

  CaregiverRelationshipType _selectedRelationship =
      CaregiverRelationshipType.familyMember;

  @override
  void initState() {
    super.initState();
    _generateCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() => _isLoadingCode = true);
    try {
      final uid = _authService.currentUser!.uid;
      final code = await _caregiverService.generateInviteCode(uid);
      if (mounted) {
        setState(() {
          _myInviteCode = code;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate code: $e'),
            backgroundColor: AppColours.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCode = false);
      }
    }
  }

  void _copyToClipboard() {
    if (_myInviteCode != null) {
      Clipboard.setData(ClipboardData(text: _myInviteCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColours.primaryGreen,
        ),
      );
    }
  }

  Future<void> _redeemCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit code'),
          backgroundColor: AppColours.primaryRed,
        ),
      );
      return;
    }

    setState(() => _isRedeeming = true);
    try {
      final uid = _authService.currentUser!.uid;
      await _caregiverService.redeemInviteCode(
        code: code,
        caregiverId: uid,
        relationship: _selectedRelationship,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully linked patient!'),
            backgroundColor: AppColours.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColours.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRedeeming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Connect',
        subtitle: 'Invite caregivers or add a patient',
        showBackButton: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [
                  // invite caregivers
                  ConnectCardShell(
                    title: 'Invite caregivers',
                    subtitle:
                        'Generate a code and share it with a caregiver to link them to your account.',
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoadingCode ? null : _generateCode,
                        icon: _isLoadingCode
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh, size: 18),
                        label: const Text('Regenerate code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // code
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: AppColours.tertiaryGreen,
                                border: Border.all(
                                  color: AppColours.primaryGreen.withOpacity(
                                    0.3,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  _myInviteCode?.split('').join('  ') ??
                                      '- - - - - -',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // copy button
                          InkWell(
                            onTap: _copyToClipboard,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.content_copy,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // code expiry message
                      Center(
                        child: Text(
                          'This code expires in 24 hours',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // add patient card
                  ConnectCardShell(
                    title: 'Add new patient',
                    subtitle:
                        'Enter the 6-digit code from your patient\'s app to link their account.',
                    children: [
                      const SizedBox(height: 4),

                      // code input field
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 16,
                        ),

                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '000000',
                          hintStyle: TextStyle(
                            color: Colors.grey[300],
                            letterSpacing: 16,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 22,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColours.secondaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // relationship dropdown
                      Text(
                        'Relationship to Patient',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // dropdown
                      DropdownButtonFormField<CaregiverRelationshipType>(
                        value: _selectedRelationship,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColours.secondaryGreen,
                              width: 2,
                            ),
                          ),
                        ),

                        items: CaregiverRelationshipType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.displayName,
                              style: TextStyle(fontSize: 15),
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRelationship = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // add patient button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isRedeeming ? null : _redeemCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColours.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isRedeeming
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Add Patient',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
