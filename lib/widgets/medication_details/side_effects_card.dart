import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../medication/medication_card.dart';

class SideEffectsCard extends StatelessWidget {
  final List<String> sideEffects;
  final VoidCallback onDiaryPressed;

  const SideEffectsCard({
    super.key,
    required this.sideEffects,
    required this.onDiaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MedicationCard(
      backgroundColor: AppColours.secondaryYellow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColours.primaryOrange,
              size: 20,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Possible Side Effects',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // side effects list
                  ...sideEffects.map(
                    (effect) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Expanded(
                            child: Text(
                              effect,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Contact your healthcare provider if you experience severe side effects.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // medication diary button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onDiaryPressed,
                      icon: const Icon(
                        Icons.description_outlined,
                        color: AppColours.primaryGreen,
                        size: 18,
                      ),
                      label: const Text(
                        'Medication Diary',
                        style: TextStyle(
                          color: AppColours.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColours.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ],
      // ),
    );
  }
}
