import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class Scanning extends StatelessWidget {
  final Animation<double> pulseAnimation;
  const Scanning({super.key, required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: pulseAnimation,
            child: CircleAvatar(
              radius: 64,
              backgroundColor: AppColours.secondaryGreen.withOpacity(0.7),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 54,
                color: AppColours.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 32),

          const Text(
            'Scanning...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColours.fontBrown,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Reading medication information',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 120), // offset to visually center better
        ],
      ),
    );
  }
}
