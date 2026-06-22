import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colours.dart';

class ProfileContent extends StatelessWidget {
  final bool isEditing;
  final GlobalKey<FormState> formKey;
  final Map<String, String> data;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final TextEditingController genderController;
  final TextEditingController emergencyNameController;
  final TextEditingController emergencyPhoneController;

  const ProfileContent({
    super.key,
    required this.isEditing,
    required this.formKey,
    required this.data,
    required this.nameController,
    required this.phoneController,
    required this.dobController,
    required this.genderController,
    required this.emergencyNameController,
    required this.emergencyPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    // view only
    if (!isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...data.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // label
                Text(
                  entry.key,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 3),

                // value
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ],
      );
    }

    // editing
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name'),
          const SizedBox(height: 6),
          _buildInputField(
            nameController,
            hintText: 'e.g. John Doe',
            textCapitalization: TextCapitalization
                .words, // capitalise first letter of each word
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Full Name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildLabel('Phone'),
          const SizedBox(height: 6),
          _buildInputField(
            phoneController,
            hintText: 'e.g., 0123456789',
            keyboardType: TextInputType.phone, // shows dialpad
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // restrict to digits only
              LengthLimitingTextInputFormatter(11), // restrict to 11 characters
            ],
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
          const SizedBox(height: 16),

          _buildLabel('Date of Birth'),
          const SizedBox(height: 6),
          _buildInputField(
            dobController,
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Date of Birth is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildLabel('Gender'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            value:
                ['Male', 'Female', 'Prefer not to say'].contains(
                  genderController.text,
                ) // whether the collection (valid values) contains the genderController.text value
                ? genderController
                      .text // if value exists, use it
                : null, // if value doesn't exist, show no initial value

            items: ['Male', 'Female', 'Prefer not to say'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),

            onChanged: (String? newVal) {
              if (newVal != null) {
                genderController.text = newVal;
              }
            },

            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Gender is required';
              }
              return null;
            },

            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              fillColor: Colors.white,
              filled: true,

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColours.primaryGreen,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColours.primaryRed,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColours.primaryRed,
                  width: 1.5,
                ),
              ),
            ),

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          _buildLabel('Emergency Contact (Optional)'),
          const SizedBox(height: 6),
          _buildInputField(
            emergencyNameController,
            hintText: 'e.g. John Doe',
            textCapitalization: TextCapitalization.words,
            validator: (val) {
              final name = val?.trim() ?? '';
              final phone = emergencyPhoneController.text.trim();
              if (phone.isNotEmpty && name.isEmpty) {
                return 'Emergency Name is required if Phone is provided';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          _buildInputField(
            emergencyPhoneController,
            hintText: 'e.g., 0123456789',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (val) {
              final phone = val?.trim() ?? '';
              final name = emergencyNameController.text.trim();
              if (name.isNotEmpty && phone.isEmpty) {
                return 'Emergency Phone is required if Name is provided';
              }
              if (phone.isNotEmpty) {
                if (phone.length < 10 || phone.length > 11) {
                  return 'Emergency Phone must be 10-11 digits';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(dobController.text) ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColours.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColours.primaryGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dobController.text = picked.toString().substring(
        0,
        10,
      ); // extracts first 10 characters
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller, {
    String? hintText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        fillColor: Colors.white,
        filled: true,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColours.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColours.primaryRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColours.primaryRed,
            width: 1.5,
          ),
        ),
      ),

      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }
}
