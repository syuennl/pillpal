import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class HorizontalMedicationItem extends StatelessWidget {
  final String medName;
  final String medQuantity;
  final IconData medIcon;
  final bool hasBorder;
  final VoidCallback? onTap;

  const HorizontalMedicationItem({
    super.key,
    required this.medName,
    required this.medQuantity,
    required this.medIcon,
    this.hasBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: hasBorder ? const EdgeInsets.all(16) : EdgeInsets.zero,
      decoration: hasBorder
          ? BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(16),
            )
          : null,
      child: Row(
        crossAxisAlignment: hasBorder
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          // logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColours.primaryGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(medIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // med name
                Text(
                  medName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // med quantity
                Text(
                  medQuantity,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
