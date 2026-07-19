import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAddPressed;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColours.primaryGreen,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ],
          ),

          if (onAddPressed != null)
            GestureDetector(
              onTap: onAddPressed,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 10),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
