import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class MedicalContent extends StatelessWidget {
  final bool isEditing;
  final List<String> allergies;
  final List<String> medicalConditions;
  final TextEditingController allergiesController;
  final TextEditingController medicalConditionsController;

  const MedicalContent({
    super.key,
    required this.isEditing,
    required this.allergies,
    required this.medicalConditions,
    required this.allergiesController,
    required this.medicalConditionsController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          icon: Icons.error_outline,
          iconColor: AppColours.primaryRed,
          title: 'Allergies',
          isEditing: isEditing,
          items: allergies,
          chipBgColor: AppColours.tertiaryRed,
          chipTextColor: AppColours.primaryRed,
          controller: allergiesController,
        ),
        const SizedBox(height: 24),

        _buildSection(
          icon: Icons.medical_information_outlined,
          iconColor: AppColours.primaryGreen,
          title: 'Medical Conditions',
          isEditing: isEditing,
          items: medicalConditions,
          chipBgColor: AppColours.secondaryGreen,
          chipTextColor: AppColours.primaryGreen,
          controller: medicalConditionsController,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isEditing,
    required List<String> items,
    required Color chipBgColor,
    required Color chipTextColor,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // icon + title
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),

            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // body (editing textfield or read-only chips)
        // editing
        if (isEditing)
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
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
            ),

            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          )
        else if (items.isEmpty) // view only, no allergies/conditions
          Text(
            'None reported',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          )
        else // view only, has allergies/conditions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: chipBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item,
                  style: TextStyle(color: chipTextColor, fontSize: 14),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
