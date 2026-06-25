import 'package:flutter/material.dart';
import 'package:pillpal/models/medication.dart';
import 'package:pillpal/models/enums/medication_enums.dart';
import 'package:pillpal/utils/app_colours.dart';

import 'package:pillpal/services/auth_service.dart';
import 'package:pillpal/services/medication_service.dart';

import 'form_components/medication_type_selector.dart';
import 'form_components/frequency_type_selector.dart';
import 'form_components/days_selector.dart';
import 'form_components/intake_instruction_selector.dart';
import 'form_components/form_text_field.dart';

class MedicationForm extends StatefulWidget {
  final VoidCallback onCancel;
  final Medication? medication;

  const MedicationForm({super.key, required this.onCancel, this.medication});

  bool get isEditing => medication != null;

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _dosageAmountController;
  late final TextEditingController _dosageUnitController;
  late final TextEditingController _strengthValueController;
  late final TextEditingController _strengthUnitController;
  late final TextEditingController _quantityController;
  late final TextEditingController _scheduledTimesController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _intervalDaysController;

  late MedicationType _selectedType;
  late FrequencyType _selectedFrequency;
  late IntakeInstruction _selectedInstruction;
  late final Set<int> _selectedDays;
  String? _aiSummary;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;

    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    final String initialName;
    final String initialDosageAmount;
    final String initialDosageUnit;
    final String initialStrengthValue;
    final String initialStrengthUnit;
    final String initialQuantity;
    final String initialScheduledTimes;
    final String initialExpiryDate;
    final String initialIntervalDays;

    if (med != null) {
      initialName = med.name;
      initialDosageAmount = med.dosageAmount.toString();
      initialDosageUnit = med.dosageUnit;
      initialStrengthValue = med.strengthValue?.toString() ?? '20';
      initialStrengthUnit = med.strengthUnit ?? 'mg';
      initialQuantity = med.quantity.toString();
      initialScheduledTimes = med.scheduledTimes
          .map((t) {
            final hour = t.hour.toString().padLeft(2, '0');
            final minute = t.minute.toString().padLeft(2, '0');
            return '$hour:$minute';
          })
          .join(', ');
      initialExpiryDate = med.expiryDate != null
          ? fmtDate(med.expiryDate!)
          : '15/08/2027';
      initialIntervalDays = med.intervalDays?.toString() ?? '';
      _aiSummary = med.aiSummary;
    } else {
      initialName = 'Simvastatin';
      initialDosageAmount = '1';
      initialDosageUnit = 'tablet';
      initialStrengthValue = '20';
      initialStrengthUnit = 'mg';
      initialQuantity = '30';
      initialScheduledTimes = '21:00';
      initialExpiryDate = '15/08/2027';
      initialIntervalDays = '';
      _aiSummary =
          'Simvastatin is a statin medication used to lower cholesterol and reduce the risk of heart disease. It works by blocking an enzyme in the liver that produces cholesterol. Best taken in the evening as the body produces more cholesterol at night. Common side effects include muscle pain and digestive issues.';
    }

    _nameController = TextEditingController(text: initialName);
    _dosageAmountController = TextEditingController(text: initialDosageAmount);
    _dosageUnitController = TextEditingController(text: initialDosageUnit);
    _strengthValueController = TextEditingController(
      text: initialStrengthValue,
    );
    _strengthUnitController = TextEditingController(text: initialStrengthUnit);
    _quantityController = TextEditingController(text: initialQuantity);
    _scheduledTimesController = TextEditingController(
      text: initialScheduledTimes,
    );
    _expiryDateController = TextEditingController(text: initialExpiryDate);
    _intervalDaysController = TextEditingController(text: initialIntervalDays);

    _selectedType = med?.type ?? MedicationType.pill;
    _selectedFrequency = med?.frequencyType ?? FrequencyType.daily;
    _selectedInstruction =
        med?.intakeInstruction ?? IntakeInstruction.afterFood;
    _selectedDays = {...?med?.selectedDays};
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageAmountController.dispose();
    _dosageUnitController.dispose();
    _strengthValueController.dispose();
    _strengthUnitController.dispose();
    _quantityController.dispose();
    _scheduledTimesController.dispose();
    _expiryDateController.dispose();
    _intervalDaysController.dispose();
    super.dispose();
  }

  List<TimeOfDay> _parseScheduledTimes(String text) {
    final times = <TimeOfDay>[];

    if (text.isEmpty) return [const TimeOfDay(hour: 9, minute: 0)];

    final parts = text.split(',');
    for (var part in parts) {
      final trimmed = part.trim();
      final timeParts = trimmed.split(':');
      if (timeParts.length == 2) {
        // ensure there's 2 numbers, not inputs like '08' / 'morning'
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          times.add(TimeOfDay(hour: hour, minute: minute));
        }
      }
    }
    return times.isNotEmpty ? times : [const TimeOfDay(hour: 9, minute: 0)];
  }

  DateTime? _parseExpiryDate(String text) {
    if (text.isEmpty) return null;

    final parts = text.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  String? _validateTextFields(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _validateNumberFields(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'Required' : null;
    }

    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState!.validate()) return;

    if (_selectedFrequency == FrequencyType.specificDays &&
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();

    final dosageAmount = double.tryParse(_dosageAmountController.text) ?? 1.0;
    final dosageUnit = _dosageUnitController.text.trim().isEmpty
        ? 'tablet'
        : _dosageUnitController.text.trim();

    final strengthValue = int.tryParse(_strengthValueController.text);
    final strengthUnit = _strengthUnitController.text.trim().isEmpty
        ? 'mg'
        : _strengthUnitController.text.trim();

    final quantity = int.tryParse(_quantityController.text) ?? 30;
    final intervalDays = int.tryParse(_intervalDaysController.text);

    final scheduledTimes = _parseScheduledTimes(_scheduledTimesController.text);
    final expiryDate = _parseExpiryDate(_expiryDateController.text);

    try {
      final uid = AuthService().currentUser!.uid;

      // edit existing medication
      if (widget.isEditing) {
        final updatedMed = Medication(
          id: widget.medication!.id,
          userId: widget.medication!.userId,
          name: name,
          type: _selectedType,
          quantity: quantity,
          dosageAmount: dosageAmount,
          dosageUnit: dosageUnit,
          frequencyType: _selectedFrequency,
          selectedDays: _selectedDays.toList(),
          intervalDays: intervalDays,
          strengthValue: strengthValue,
          strengthUnit: strengthUnit,
          scheduledTimes: scheduledTimes,
          intakeInstruction: _selectedInstruction,
          treatmentStartDate: widget.medication!.treatmentStartDate,
          treatmentEndDate: widget.medication!.treatmentEndDate,
          expiryDate: expiryDate,
          aiSummary: widget.medication!.aiSummary,
          sideEffects: widget.medication!.sideEffects,
        );

        await MedicationService().updateMedication(updatedMed);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name updated successfully'),
            backgroundColor: AppColours.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        // add new medication
        final newMed = Medication(
          id: '',
          userId: uid,
          name: name,
          type: _selectedType,
          quantity: quantity,
          dosageAmount: dosageAmount,
          dosageUnit: dosageUnit,
          frequencyType: _selectedFrequency,
          selectedDays: _selectedDays.toList(),
          intervalDays: intervalDays,
          strengthValue: strengthValue,
          strengthUnit: strengthUnit,
          scheduledTimes: scheduledTimes,
          intakeInstruction: _selectedInstruction,
          treatmentStartDate: DateTime.now(),
          expiryDate: expiryDate,
          aiSummary:
              'This medication is used to treat your symptoms. Please follow dosage instructions carefully.',
          sideEffects: ['Drowsiness', 'Mild nausea'],
        );

        // save new med
        await MedicationService().addMedication(newMed);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added successfully'),
            backgroundColor: AppColours.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColours.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 24.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSubText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // name
              _buildLabel('Medication Name'),
              FormTextField(
                controller: _nameController,
                validator: _validateTextFields,
              ),
              const SizedBox(height: 10),

              // type
              _buildLabel('Medication Type'),
              MedicationTypeSelector(
                selectedType: _selectedType,
                onChanged: (newType) {
                  setState(() => _selectedType = newType);
                },
              ),
              const SizedBox(height: 10),

              // picture
              _buildLabel('Picture of Pill (Optional)'),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColours.textboxGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    style: BorderStyle.solid,
                  ), // TODO: a dashed package can be added later
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.file_upload_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click to upload a photo',
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
              SizedBox(height: 10),

              // dosage
              _buildLabel('Dosage'),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubText('Amount'),
                        FormTextField(
                          controller: _dosageAmountController,
                          keyboardType: TextInputType.number,
                          validator: _validateNumberFields,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubText('Unit'),
                        FormTextField(
                          controller: _dosageUnitController,
                          validator: _validateTextFields,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSubText('Example: 1 tablet'),
              SizedBox(height: 10),

              // strength
              _buildLabel('Strength'),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubText('Value'),
                        FormTextField(
                          controller: _strengthValueController,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              _validateNumberFields(v, isRequired: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubText('Unit'),
                        FormTextField(controller: _strengthUnitController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSubText('Example: 20 mg per tablet'),
              SizedBox(height: 10),

              // quantity
              _buildLabel('Quantity'),
              _buildSubText('Total amount of medication in the box'),
              FormTextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: _validateNumberFields,
              ),
              const SizedBox(height: 10),

              _buildLabel('Frequency'),
              _buildSubText('How often do you take this?'),
              FrequencyTypeSelector(
                selectedFrequency: _selectedFrequency,
                onChanged: (newFreq) {
                  // when new freq selected, clear existing values
                  setState(() {
                    _selectedFrequency = newFreq;
                    _selectedDays.clear();
                    _intervalDaysController.clear();
                  });
                },
              ),

              // based on the type of freq selected, different ui will be displayed
              // specific days
              if (_selectedFrequency == FrequencyType.specificDays) ...[
                const SizedBox(height: 24),
                _buildSubText('Select days of the week'),
                DaysSelector(
                  selectedDays: _selectedDays,
                  onDayToggled: (dayIndex) {
                    setState(() {
                      if (_selectedDays.contains(dayIndex)) {
                        _selectedDays.remove(dayIndex); // unselect
                      } else {
                        _selectedDays.add(dayIndex); // select
                      }
                    });
                  },
                ),
              ]
              // interval days
              else if (_selectedFrequency == FrequencyType.interval) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Every',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),

                    SizedBox(
                      width: 60,
                      child: FormTextField(
                        controller: _intervalDaysController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (_selectedFrequency != FrequencyType.interval)
                            return null; // skip if not interval
                          return _validateNumberFields(v);
                        },
                        hint: '1',
                      ),
                    ),
                    const SizedBox(width: 12),

                    const Text(
                      'day(s)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 10),

              // scheduled times
              _buildLabel('Scheduled Times'),
              _buildSubText('Separate multiple times with commas'),
              FormTextField(
                controller: _scheduledTimesController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  for (final p in v.split(',')) {
                    final t = p.trim().split(':');
                    if (t.length != 2 ||
                        int.tryParse(t[0]) == null ||
                        int.tryParse(t[1]) == null) {
                      return 'Use HH:MM (e.g. 08:00, 21:00)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // intake instruction
              _buildLabel('Take Medication'),
              IntakeInstructionSelector(
                selectedInstruction: _selectedInstruction,
                onChanged: (newInst) {
                  setState(() => _selectedInstruction = newInst);
                },
              ),
              const SizedBox(height: 10),

              // expiry date
              _buildLabel('Expiry Date'),
              FormTextField(
                controller: _expiryDateController,
                suffixIcon: 'calendar',
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColours.primaryGreen,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _expiryDateController.text =
                          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                    });
                  }
                },
              ),

              // ai summary
              if (_aiSummary != null && _aiSummary!.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildLabel('AI Summary'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColours.secondaryGreen.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _aiSummary!,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
              ],
              const SizedBox(height: 48),

              // buttons
              Row(
                children: [
                  // cancel button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: widget.onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          elevation: 0, // removed default shadow
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // submit button
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.primaryGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Save Changes'
                                    : 'Add Medication',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
