import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/add_medicine/medication_form.dart';

class EditMedicationScreen extends StatelessWidget {
  final Medication medication;

  const EditMedicationScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Edit Medication',
        showBackButton: true,
      ),
      body: MedicationForm(
        medication: medication,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}
