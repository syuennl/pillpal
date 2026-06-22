import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class SquareMedicationItem extends StatelessWidget {
  final String medName;
  final String medQuantity;
  final IconData medIcon;
  final VoidCallback? onTap;

  const SquareMedicationItem({
    super.key,
    required this.medName,
    required this.medQuantity,
    required this.medIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 140, // fixed width for a nice square card feel
      padding: const EdgeInsets.all(12), // horizontal: 16, vertical: 20
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColours.primaryGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(medIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),

          // med name
          Text(
            medName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // med dosage
          Text(
            medQuantity,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    );
  }
}
