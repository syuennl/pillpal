import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class MedicationCategorySection extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final String badgeText;
  final Widget content;

  // if null, header is not interactive
  final VoidCallback? onCategoryTap;

  const MedicationCategorySection({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.badgeText,
    required this.content,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final header = Row(
      children: [
        // icon
        Icon(categoryIcon, color: AppColours.primaryGreen, size: 16),
        const SizedBox(width: 8),

        // category name
        Expanded(
          child: Text(
            categoryName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColours.primaryYellow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badgeText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // category header (tappable when onCategoryTap is provided)
        if (onCategoryTap != null)
          InkWell(
            onTap: onCategoryTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: header,
            ),
          )
        else
          header,
        const SizedBox(height: 20),

        // dynamic content
        content,
      ],
    );
  }
}
