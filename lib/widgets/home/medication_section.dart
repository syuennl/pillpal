import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class MedicationSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const MedicationSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // heading
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // count
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${children.length}',
                  style: const TextStyle(
                    color: AppColours.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...children,
      ],
    );
  }
}
