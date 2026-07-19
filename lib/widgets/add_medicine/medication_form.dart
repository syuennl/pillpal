import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:pillpal/models/medication.dart';
import 'package:pillpal/models/enums/medication_enums.dart';
import 'package:pillpal/utils/app_colours.dart';

import 'package:pillpal/services/auth_service.dart';
import 'package:pillpal/services/medication_service.dart';
import 'package:pillpal/services/notification_service.dart';
import 'package:pillpal/services/ocr_service.dart';

import 'form_components/medication_type_selector.dart';
import 'form_components/frequency_type_selector.dart';
import 'form_components/days_selector.dart';
import 'form_components/intake_instruction_selector.dart';
import 'form_components/form_text_field.dart';
import 'form_components/medication_image_picker.dart';

class MedicationForm extends StatefulWidget {
  final VoidCallback onCancel;
  final Medication? medication; // for editing
  final ScannedMedication? scannedInfo; // for adding

  const MedicationForm({
    super.key,
    required this.onCancel,
    this.medication,
    this.scannedInfo,
  });

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

  MedicationType _selectedType = MedicationType.pill;
  String? _imagePath;
  FrequencyType _selectedFrequency = FrequencyType.daily;
  IntakeInstruction _selectedInstruction = IntakeInstruction.anytime;
  Set<int> _selectedDays = {};
  String? _aiSummary;
  List<String>? _sideEffects;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // create controllers
    _nameController = TextEditingController();
    _dosageAmountController = TextEditingController();
    _dosageUnitController = TextEditingController();
    _strengthValueController = TextEditingController();
    _strengthUnitController = TextEditingController();
    _quantityController = TextEditingController();
    _scheduledTimesController = TextEditingController();
    _expiryDateController = TextEditingController();

    // fill the controllers and overwrite defaults if prefilling
    if (widget.isEditing) {
      _prefillFromMedication(widget.medication!); // existing edit prefill
    } else if (widget.scannedInfo != null) {
      _prefillFromScan(widget.scannedInfo!); // OCR prefill
    }
    // if neither, fields stay empty (manual entry)
  }

  // generic enum parser
  T _parseEnum<T>(List<T> values, String? raw, T fallback) {
    if (raw == null) return fallback;
    return values.firstWhereOrNull((e) => (e as Enum).name == raw) ?? fallback;
    // fallbacks important for prefilled info from ai (prevent bad ai strings)
  }

  String _formatScanDate(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  void _prefillFromMedication(Medication med) {
    _nameController.text = med.name;
    _dosageAmountController.text = med.dosageAmount.toString();
    _dosageUnitController.text = med.dosageUnit;
    _strengthValueController.text =
        med.strengthValue?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '';
    _strengthUnitController.text = med.strengthUnit ?? '';
    _quantityController.text = med.formattedQuantity;
    _scheduledTimesController.text = med.scheduledTimes
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .join(', ');
    _expiryDateController.text = med.expiryDate != null
        ? _formatScanDate(med.expiryDate.toString())
        : '';

    _selectedType = med.type;
    _imagePath = med.imagePath;
    _selectedFrequency = med.frequencyType;
    _selectedInstruction = med.intakeInstruction;
    _selectedDays = med.selectedDays?.toSet() ?? {};
    _aiSummary = med.aiSummary;
    _sideEffects = med.sideEffects;
  }

  void _prefillFromScan(ScannedMedication s) {
    // plain text fields
    _nameController.text = s.name ?? '';
    _dosageAmountController.text = s.dosageAmount?.toString() ?? '';
    _dosageUnitController.text = s.dosageUnit ?? '';
    _strengthValueController.text =
        s.strengthValue?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '';
    _strengthUnitController.text = s.strengthUnit ?? '';
    _quantityController.text =
        s.quantity?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '';
    _scheduledTimesController.text = s.times?.join(', ') ?? '';
    _expiryDateController.text = _formatScanDate(s.expiryDate);

    // enum selections (string -> enum, with safe fallback)
    _selectedType = _parseEnum(
      MedicationType.values,
      s.medicationType,
      MedicationType.pill,
    );
    _selectedFrequency = _parseEnum(
      FrequencyType.values,
      s.frequencyType,
      FrequencyType.daily,
    );
    _selectedInstruction = _parseEnum(
      IntakeInstruction.values,
      s.intakeInstruction,
      IntakeInstruction.anytime,
    );

    // image
    _imagePath = s.imagePath;

    // AI-generated content carried through to the saved medication
    // (store on temp fields your _handleSubmit already reads, OR keep them here
    //  and include in the Medication you build on save)
    _aiSummary = s.aiSummary;
    _sideEffects = s.sideEffects;
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
    super.dispose();
  }

  List<TimeOfDay> _parseScheduledTimes(String text) {
    final times = <TimeOfDay>[];

    final parts = text
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      if (_selectedFrequency == FrequencyType.asNeeded) {
        return [];
      }
      return [const TimeOfDay(hour: 9, minute: 0)];
    }

    for (var part in parts) {
      final timeParts = part.split(':');
      if (timeParts.length == 2) {
        // ensure there's 2 numbers, not inputs like '08' / 'morning'
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          times.add(TimeOfDay(hour: hour, minute: minute));
        }
      }
    }

    if (times.isEmpty) {
      if (_selectedFrequency == FrequencyType.asNeeded) {
        return [];
      }
      return [const TimeOfDay(hour: 9, minute: 0)];
    }
    return times;
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

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final dosageAmount = double.tryParse(_dosageAmountController.text) ?? 1.0;
    final dosageUnit = _dosageUnitController.text.trim().isEmpty
        ? 'tablet'
        : _dosageUnitController.text.trim();

    final strengthValue = double.tryParse(_strengthValueController.text);
    final strengthUnit = _strengthUnitController.text.trim().isEmpty
        ? null
        : _strengthUnitController.text.trim();

    final quantity = double.tryParse(_quantityController.text) ?? 30.0;

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
          imagePath: _imagePath,
          quantity: quantity,
          dosageAmount: dosageAmount,
          dosageUnit: dosageUnit,
          frequencyType: _selectedFrequency,
          selectedDays: _selectedDays.toList(),
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

        // cancel using the OLD med
        await NotificationService().cancelForMedication(widget.medication!);

        await MedicationService().updateMedication(updatedMed);

        // schedule fresh with the NEW values
        await NotificationService().scheduleForMedication(updatedMed);

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
          imagePath: _imagePath,
          quantity: quantity,
          dosageAmount: dosageAmount,
          dosageUnit: dosageUnit,
          frequencyType: _selectedFrequency,
          selectedDays: _selectedDays.toList(),
          strengthValue: strengthValue,
          strengthUnit: strengthUnit,
          scheduledTimes: scheduledTimes,
          intakeInstruction: _selectedInstruction,
          treatmentStartDate: DateTime.now(),
          expiryDate: expiryDate,
          aiSummary: _aiSummary ?? '',
          sideEffects: _sideEffects ?? [],
        );

        // save new med
        final newId = await MedicationService().addMedication(newMed);
        await NotificationService().scheduleForMedication(
          newMed.copyWith(id: newId),
        );

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
              MedicationImagePicker(
                imagePath: _imagePath,
                onImageChanged: (newPath) {
                  setState(() => _imagePath = newPath);
                },
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
                          validator: (v) {
                            final hasValue = v != null && v.trim().isNotEmpty;
                            final hasUnit = _strengthUnitController.text
                                .trim()
                                .isNotEmpty;
                            // if unit is filled but value isn't, value becomes required
                            if (hasUnit && !hasValue) return 'Enter strength';
                            if (hasValue && double.tryParse(v) == null)
                              return 'Enter a number';
                            return null; // both empty = fine
                          },
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
                          controller: _strengthUnitController,
                          validator: (v) {
                            final hasUnit = v != null && v.trim().isNotEmpty;
                            final hasValue = _strengthValueController.text
                                .trim()
                                .isNotEmpty;
                            // if value is filled but unit isn't, unit becomes required
                            if (hasValue && !hasUnit)
                              return 'Enter unit (e.g. mg)';
                            return null; // both empty = fine
                          },
                        ),
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
              ],
              SizedBox(height: 10),

              // scheduled times
              _buildLabel('Scheduled Times'),
              _buildSubText('Separate multiple times with commas'),
              FormTextField(
                controller: _scheduledTimesController,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    if (_selectedFrequency == FrequencyType.asNeeded) {
                      return null;
                    }
                    return 'Required';
                  }
                  final parts = v
                      .split(',')
                      .map((p) => p.trim())
                      .where((p) => p.isNotEmpty)
                      .toList();

                  if (parts.isEmpty) {
                    if (_selectedFrequency == FrequencyType.asNeeded) {
                      return null;
                    }
                    return 'Required';
                  }

                  for (final p in parts) {
                    final t = p.split(':');
                    if (t.length != 2) {
                      return 'Use HH:MM (e.g. 08:00, 21:00)';
                    }
                    final hour = int.tryParse(t[0]);
                    final minute = int.tryParse(t[1]);
                    if (hour == null || minute == null) {
                      return 'Use HH:MM (e.g. 08:00, 21:00)';
                    }
                    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _aiSummary!,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.grey[600],
                              size: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'AI-generated summary may contain inaccuracies. \nAlways follow the guidance of your doctor or pharmacist.',
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.5,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // side effects
              if (_sideEffects != null && _sideEffects!.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildLabel('Possible Side Effects'),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColours.secondaryYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // side effects list
                      ..._sideEffects!.map(
                        (effect) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  effect,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // warning text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.grey[600],
                              size: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'AI-generated side effects may contain inaccuracies. \nContact your healthcare provider if you experience severe side effects.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
