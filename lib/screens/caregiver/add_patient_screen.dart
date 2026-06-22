import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../mock/caregiver.dart';
import '../../mock/user_profile.dart';
import '../../models/user.dart';
import '../../models/profile.dart';
import '../../models/caregiver_relationship.dart';
import '../../view_models/overall_patient_adherence_stats.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleAddPatient() {
    if (_formKey.currentState!.validate()) {
      final newPatientId = (mockUsers.length + 1).toString();
      final newPatient = User(
        id: newPatientId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      mockUsers.add(newPatient);

      mockProfiles.add(
        Profile(
          id: newPatientId,
          userId: newPatientId,
          birthDate: DateTime(1990, 1, 1),
          gender: GenderType.male,
          profileImagePath: 'lib/utils/images/pfp.jpeg',
        ),
      );

      final newRelationship = CaregiverRelationship(
        id: (mockCaregiverRelationships.length + 1).toString(),
        patientId: newPatientId,
        caregiverId: mockUsers[0].id,
        relationship: CaregiverRelationshipType.familyMember,
        sinceDate: DateTime.now(),
      );

      mockCaregiverRelationships.add(newRelationship);

      mockPatientMetrics[newPatientId] = OverallPatientAdherenceStats(
        takenToday: 0,
        missedToday: 0,
        totalTaken: 0,
        totalMissed: 0,
        totalSnoozed: 0,
        adherencePercentage: 100.0,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newPatient.name} added successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColours.primaryGreen,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColours.fontBrown,
          ),
        ),
        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            fillColor: Colors.white,
            filled: true,
            prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 20),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColours.primaryGreen,
                width: 1.5,
              ),
            ),
            
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColours.primaryRed,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColours.primaryRed,
                width: 1.5,
              ),
            ),
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Add New Patient',
        subtitle: 'Enter patient information',
        showBackButton: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // form fields
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'Enter patient\'s full name',
                      prefixIcon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Full Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'patient@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!val.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hintText: '0123456789',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        final text = val?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (text.length < 10 || text.length > 11) {
                          return 'Phone must be 10-11 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // note card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColours.secondaryGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Note: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text:
                                  'After adding the patient, you can assign medications and track their adherence from the patient details page.',
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // submit button
                    ElevatedButton(
                      onPressed: _handleAddPatient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColours.primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Add Patient',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // cancel button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColours.buttonGrey,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
