import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class QuietHoursContent extends StatelessWidget {
  final bool isEditing;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  const QuietHoursContent({
    super.key,
    required this.isEditing,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set time range when you won\'t receive notifications',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            // start time
            Expanded(
              child: _buildTimeSection(
                context: context,
                label: 'Start Time',
                time: startTime,
                onTap: isEditing
                    ? () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          initialEntryMode: TimePickerEntryMode.input,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColours.primaryGreen,
                                  onPrimary: Colors.white,
                                  onSurface: AppColours.fontBrown,
                                  tertiary: AppColours.primaryGreen,
                                  onTertiary: Colors.white,
                                  tertiaryContainer: AppColours.secondaryGreen,
                                  onTertiaryContainer: AppColours.fontBrown,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          onStartTimeChanged(picked);
                        }
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 20),

            // end time
            Expanded(
              child: _buildTimeSection(
                context: context,
                label: 'End Time',
                time: endTime,
                onTap: isEditing
                    ? () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                          initialEntryMode: TimePickerEntryMode.input,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColours.primaryGreen,
                                  onPrimary: Colors.white,
                                  onSurface: AppColours.fontBrown,
                                  tertiary: AppColours.primaryGreen,
                                  onTertiary: Colors.white,
                                  tertiaryContainer: AppColours.secondaryGreen,
                                  onTertiaryContainer: AppColours.fontBrown,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          onEndTimeChanged(picked);
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTimeSection({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // label
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // time box
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: onTap == null ? 0 : 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: onTap == null
                  ? Border()
                  : Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Text(
              time.format(context),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: onTap == null ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
