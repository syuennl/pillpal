import 'package:flutter/material.dart';
import 'package:pillpal/utils/app_colours.dart';

class PreScan extends StatelessWidget {
  final VoidCallback onScanCamera;
  final VoidCallback onScanGallery;
  // final VoidCallback onScanMultiple;
  const PreScan({
    super.key,
    required this.onScanCamera,
    required this.onScanGallery,
    // required this.onScanMultiple,
  });

  // opens the bottom sheet with the three source options
  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // little grab handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),

                // camera
                _option(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  subtitle: 'Use your camera',
                  onTap: () {
                    Navigator.pop(sheetContext); // close sheet first
                    onScanCamera();
                  },
                ),

                // gallery
                _option(
                  icon: Icons.image_outlined,
                  label: 'Choose from Gallery',
                  subtitle: 'Front, back & sides for best results',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onScanGallery();
                  },
                ),

                // gallery (multiple images)
                // _option(
                //   icon: Icons.collections_outlined,
                //   label: 'Upload Multiple Photos',
                //   subtitle: 'Front, back & sides for best results',
                //   onTap: () {
                //     Navigator.pop(sheetContext);
                //     onScanMultiple();
                //   },
                // ),
                // const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _option({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColours.secondaryGreen,
        child: Icon(icon, color: AppColours.primaryGreen),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColours.fontBrown,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
      onTap: onTap,
    );
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

                  // button that opens the options sheet to upload med image
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showScanOptions(context),
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

            //       SizedBox(
            //         width: double.infinity,
            //         child: ElevatedButton(
            //           onPressed: onStartScanning,
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: AppColours.primaryGreen,
            //             elevation: 0,
            //             padding: const EdgeInsets.symmetric(vertical: 16),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(16),
            //             ),
            //           ),
            //           child: const Text(
            //             'Start Scanning',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 16,
            //               fontWeight: FontWeight.w600,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 24),

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
