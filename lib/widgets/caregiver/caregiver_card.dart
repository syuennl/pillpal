import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colours.dart';
import '../../models/caregiver_relationship.dart';
import '../../models/user.dart';
import '../../mock/user_profile.dart';

class CaregiverCard extends StatelessWidget {
  final CaregiverRelationship caregiverRelationship;

  const CaregiverCard({super.key, required this.caregiverRelationship});

  @override
  Widget build(BuildContext context) {
    final user = mockUsers.firstWhere(
      (u) => u.id == caregiverRelationship.caregiverId,
      orElse: () =>
          User(id: '', name: 'Unknown Caregiver', phone: '-', email: ''),
    );

    final name = user.name;
    final relationship = caregiverRelationship.relationship.displayName;
    final phone = user.phone;
    final sinceDate = DateFormat(
      'MMM yyyy',
    ).format(caregiverRelationship.sinceDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 5),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColours.secondaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.person_outlined,
              color: AppColours.primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                // relationship
                Text(
                  relationship,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColours.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // phone number
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),

                    Text(
                      phone ?? '',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // caregiver since ...
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      'Caregiver since $sinceDate',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
