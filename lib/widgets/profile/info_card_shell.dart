import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class InfoCardShell extends StatelessWidget {
  final String title;
  final bool hasTrailing;
  final Widget content;
  final bool isEditing;
  final VoidCallback? onEditTapped;
  final VoidCallback? onSaveTapped;

  const InfoCardShell({
    super.key,
    required this.title,
    this.hasTrailing = false,
    required this.content,
    this.isEditing = false,
    this.onEditTapped,
    this.onSaveTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -1,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                // edit or save btn
                if (hasTrailing)
                  InkWell(
                    onTap: isEditing ? onSaveTapped : onEditTapped,
                    borderRadius: BorderRadius.circular(100),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        isEditing ? Icons.check : Icons.edit,
                        size: 16,
                        color: AppColours.primaryGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: content,
          ),
        ],
      ),
    );
  }
}
