import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colours.dart';
import '../../models/caregiver_relationship.dart';
import '../../services/caregiver_service.dart';

class CaregiverCard extends StatelessWidget {
  final CaregiverRelationship caregiverRelationship;

  const CaregiverCard({super.key, required this.caregiverRelationship});

  @override
  Widget build(BuildContext context) {
    final relationship = caregiverRelationship.relationship.displayName;
    final sinceDate = DateFormat(
      'MMM yyyy',
    ).format(caregiverRelationship.sinceDate);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(caregiverRelationship.caregiverId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading state
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
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        Map<String, dynamic>? data;
        if (snapshot.hasData && snapshot.data!.exists) {
           data = snapshot.data!.data() as Map<String, dynamic>?;
        }
        
        final name = data?['name'] as String? ?? 'Unknown Caregiver';
        final phone = data?['phone'] as String?;

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
                child: const Icon(
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
                    // name and unlink button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                        // remove button
                        IconButton(
                          icon: const Icon(Icons.person_remove_outlined),
                          color: AppColours.primaryRed,
                          tooltip: 'Remove Caregiver',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remove Caregiver'),
                                content: Text(
                                  'Are you sure you want to remove $name as your caregiver? They will no longer have access to your medication data.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      try {
                                        await CaregiverService().unlink(
                                          caregiverRelationship.id,
                                        );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: AppColours.primaryRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
                          phone ?? '-',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // caregiver since ...
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Caregiver since $sinceDate',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
