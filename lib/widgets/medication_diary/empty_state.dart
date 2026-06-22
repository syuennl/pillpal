import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        // color: Colors.grey[100],
        // borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16), //12

          const Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 16, //14
              fontWeight: FontWeight.w600,
              color: Colors.black87, // grey 500
            ),
          ),
          const SizedBox(height: 6), //4

          Text(
            'Add notes to remember what to discuss with your doctor',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13, //12
              color: Colors.grey[500], //400
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
