import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pillpal/utils/app_colours.dart';

class MedicationImagePicker extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onImageChanged;

  const MedicationImagePicker({
    super.key,
    required this.imagePath,
    required this.onImageChanged,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 70);
    if (image != null) {
      onImageChanged(image.path);
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColours.primaryGreen,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(context, ImageSource.camera);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.image_outlined,
                color: AppColours.primaryGreen,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    if (!hasImage) {
      // placeholder
      return GestureDetector(
        onTap: () => _showSourceSheet(context),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColours.textboxGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 32,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to upload a photo',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'PNG, JPG up to 10MB',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // show photo + remove/replace controls
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: imagePath!.startsWith('http')
              ? Image.network(
                  imagePath!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 44,
                      color: Colors.grey[500],
                    ),
                  ),
                )
              : Image.file(
                  File(imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // if the file is missing/unreadable, fall back to placeholder
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 44,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
        ),

        // remove button (top-right)
        Positioned(
          top: 10,
          right: 10,
          child: _circleButton(
            icon: Icons.close,
            color: AppColours.primaryRed,
            onTap: () => onImageChanged(null), // clears the image
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
