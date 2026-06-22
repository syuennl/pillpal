import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin { // singleticker...: giving _AddMedicineScreenState ability to act as a metronome
  bool _isScanning = false;
  bool _hasScanned = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, // attach animation ctrler to the ticker, use screen's metronome to keep track of time so pulse animation plays smoothly
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

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    _pulseController.repeat(reverse: true);

    // simulate scan duration
    Future.delayed(const Duration(seconds: 3), () { // TODO: remove when backend integrated
      if (mounted) {
        setState(() {
          _isScanning = false;
          _hasScanned = true;
        });
        _pulseController.stop();

        // show success SnackBar
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
                color: AppColours.secondaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), 
                    blurRadius: 15, 
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, color: AppColours.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Information extracted successfully. Please review and edit if needed.',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  void _resetForm() {
    setState(() {
      _hasScanned = false;
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, 
      appBar: const CustomAppBar(
        title: 'Add New Medicine',
        showBackButton: true,
      ),
      body: _isScanning
          ? Scanning(pulseAnimation: _pulseAnimation)
          : _hasScanned
          ? MedicationForm(onCancel: _resetForm)
          : PreScan(onStartScanning: _startScanning),
    );
  }
}
