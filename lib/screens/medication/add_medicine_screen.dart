import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pillpal/services/ocr_service.dart';
import 'package:pillpal/utils/app_colours.dart';

import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/add_medicine/pre_scan.dart';
import '../../widgets/add_medicine/scanning.dart';
import '../../widgets/add_medicine/medication_form.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen>
    with SingleTickerProviderStateMixin {
  // singleticker...: giving _AddMedicineScreenState ability to act as a metronome
  bool _isScanning = false;
  bool _hasScanned = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  ScannedMedication? scannedInfo;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync:
          this, // attach animation ctrler to the ticker, use screen's metronome to keep track of time so pulse animation plays smoothly
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // capture from camera
  Future<void> _scanFromCamera() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // shrink so the upload isn't slow
    );
    if (image == null) return; // user backed out
    await _runScan([image.path]);
  }

  // pick one photo from gallery
  // Future<void> _scanFromGallery() async {
  //   final image = await _picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 70,
  //   );
  //   if (image == null) return;
  //   await _runScan([image.path]);
  // }

  // pick from gallery
  Future<void> _scanFromGallery() async {
    final images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isEmpty) return;
    await _runScan(images.map((i) => i.path).toList());
  }

  // shows the scanning animation, calls Gemini, handles the result
  Future<void> _runScan(List<String> imagePaths) async {
    setState(() => _isScanning = true);
    _pulseController.repeat(reverse: true);

    try {
      final scanned = await OcrService.scanLabel(imagePaths);

      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _hasScanned = true;
        scannedInfo = scanned;
      });
      _pulseController.stop();

      _showSnack(
        'Information extracted successfully. Please review and edit if needed.',
        AppColours.primaryGreen,
        Icons.check,
      );
    } catch (e) {
      if (!mounted) return;
      // scan failed, still let the user fill the form manually
      setState(() {
        _isScanning = false;
        _hasScanned = true;
        scannedInfo = null; // form will just show empty fields
      });
      _pulseController.stop();

      _showSnack(
        'Could not read the label. Please enter the details manually.',
        AppColours.primaryRed,
        Icons.error_outline,
      );
    }
  }

  void _showSnack(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _hasScanned = false;
      _isScanning = false;
      scannedInfo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Add New Medicine',
        showBackButton: true,
      ),
      body: _isScanning
          ? Scanning(pulseAnimation: _pulseAnimation)
          : _hasScanned
          ? MedicationForm(scannedInfo: scannedInfo, onCancel: _resetForm)
          : PreScan(
              onScanCamera: _scanFromCamera,
              onScanGallery: _scanFromGallery,
              // onScanMultiple: _scanMultiple,
            ),
    );
  }
}
