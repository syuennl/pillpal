import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../utils/app_colours.dart';
import 'category_medication_list_item.dart';

class CategoryMedicationsModal extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Medication> medications;

  final void Function(Medication medication) onSelectMedication;

  const CategoryMedicationsModal({
    super.key,
    required this.title,
    required this.icon,
    required this.medications,
    required this.onSelectMedication,
  });

  // helper to display the dialogue with the standard transition/barrier
  static Future<void> show({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Medication> medications,
    required void Function(Medication medication) onSelectMedication,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CategoryMedicationsModal(
        title: title,
        icon: icon,
        medications: medications,
        onSelectMedication: onSelectMedication,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.6;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: 480),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            // FILO, so put col, close btn, will paint close btn, col
            children: [
              Column(
                mainAxisSize: MainAxisSize.min, // fit content height
                children: [
                  // header with icon, title + count
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColours.tertiaryGreen, Colors.white],
                      ),
                    ),

                    child: Column(
                      children: [
                        // icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColours.secondaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: AppColours.primaryGreen,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // title + count badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              // only take up space needed, but expanded() will take as much space
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColours.fontBrown,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 10),

                            Container(
                              width: 20,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColours.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${medications.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // scrollable list
                  Flexible(
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: medications.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No medications in this category yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              shrinkWrap:
                                  false, // fix the height of modal, dun shrink based on contents
                              itemCount: medications.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final med = medications[index];
                                return CategoryMedicationListItem(
                                  medication: med,
                                  onTap: () {
                                    // when click on a med item
                                    Navigator.of(
                                      context,
                                    ).pop(); // close the modal
                                    onSelectMedication(
                                      med,
                                    ); // open med details screen
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),

              // close button
              Positioned(
                top: 12,
                right: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    // draws grey hover circle on tap, must be paired w/ Material (blank canvas)
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[700],
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
