import 'package:flutter/material.dart';
import '../../../utils/app_colours.dart';

class InformationCard extends StatelessWidget {
  final String name;
  final String phone;
  final String dateOfBirth;

  const InformationCard({
    super.key,
    required this.name,
    required this.phone,
    required this.dateOfBirth,
  });

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        // icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColours.secondaryGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColours.primaryGreen, size: 18),
        ),
        const SizedBox(width: 16),

        // details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),

              // value
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.person_outline, 'Name', name),
        const SizedBox(height: 16),

        _buildInfoRow(Icons.phone_outlined, 'Phone', phone),
        const SizedBox(height: 16),

        _buildInfoRow(
          Icons.calendar_today_outlined,
          'Date of Birth',
          dateOfBirth,
        ),
      ],
    );
  }
}
