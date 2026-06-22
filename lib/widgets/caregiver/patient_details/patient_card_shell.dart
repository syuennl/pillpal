import 'package:flutter/material.dart';
import '../../../utils/app_colours.dart';

class PatientCardShell extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final bool isLargeTitle;
  final Widget? trailingTitleWidget;
  final Widget content;

  const PatientCardShell({
    super.key,
    this.title,
    this.icon,
    this.isLargeTitle = false,
    this.trailingTitleWidget,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColours.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: isLargeTitle ? 22 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (trailingTitleWidget != null) ...[
                  const Spacer(),
                  trailingTitleWidget!,
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
          content,
        ],
      ),
    );
  }
}
