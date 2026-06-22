import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class PreScan extends StatelessWidget {
  final VoidCallback onStartScanning;
  const PreScan({super.key, required this.onStartScanning});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // scan card
            Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColours.secondaryGreen,
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 54,
                      color: AppColours.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Scan Medication Label',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColours.fontBrown,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Position the medication label or packaging \nclearly in view',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStartScanning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColours.primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start Scanning',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // tips Card
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColours.secondaryGreen.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips for Best Results',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColours.fontBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTipRow('Ensure good lighting'),
                  const SizedBox(height: 12),
                  _buildTipRow('Keep the label flat and in focus'),
                  const SizedBox(height: 12),
                  _buildTipRow('Include medication name and dosage'),
                  const SizedBox(height: 12),
                  _buildTipRow('You can edit information after scanning'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTipRow(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 6.0),
        child: Icon(Icons.circle, size: 6, color: AppColours.primaryGreen),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    ],
  );
}
