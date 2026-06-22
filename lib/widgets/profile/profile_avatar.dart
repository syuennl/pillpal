import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colours.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final ValueChanged<String?> onImageChanged;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.onImageChanged,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source, // from gallery or camera
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        onImageChanged(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColours.primaryRed,
            content: Text(
              'Could not access ${source == ImageSource.gallery ? 'gallery' : 'camera'}. Please check permissions.',
            ),
          ),
        );
      }
    }
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Profile Photo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // choose frm gallery
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColours.primaryGreen,
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.gallery);
                  },
                ),

                // take photo
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColours.primaryGreen,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, ImageSource.camera);
                  },
                ),

                if (imageUrl != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColours.primaryRed,
                    ),
                    title: const Text(
                      'Remove Current Photo',
                      style: TextStyle(color: AppColours.primaryRed),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onImageChanged(null);
                    },
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  ImageProvider _getAvatarImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/') || path.startsWith('lib/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = MediaQuery.of(context).size.width * 0.12;
    return Stack(
      children: [
        // pfp container
        Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            backgroundColor: AppColours.secondaryGreen,
            radius: avatarSize,
            backgroundImage: imageUrl != null
                ? _getAvatarImage(imageUrl!)
                : null,
            child: imageUrl == null
                ? Icon(
                    Icons.person_outline,
                    size: avatarSize * 1.2,
                    color: AppColours.primaryGreen,
                  )
                : null,
          ),
        ),

        // camera button overlay
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColours.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showImageOptions(context),
              icon: const Icon(
                Icons.photo_camera_outlined,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
