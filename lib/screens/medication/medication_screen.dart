import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import 'add_medicine_screen.dart';
import 'medication_details_screen.dart';
import '../../widgets/common/dashboard_header.dart';
import '../../widgets/medication/round_medication_list.dart';
import '../../widgets/medication/medication_card.dart';
import '../../widgets/medication/medication_category_section.dart';
import '../../widgets/medication/medication_column.dart';
import '../../widgets/medication/square_medication_item.dart';
import '../../widgets/medication/category_medications_modal.dart';
import '../../models/medication.dart';
import '../../models/enums/medication_enums.dart';
import '../../mock/medication.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Medication> pills = mockMedications
        .where((m) => m.type == MedicationType.pill)
        .toList();
    List<Medication> capsules = mockMedications
        .where((m) => m.type == MedicationType.capsule)
        .toList();
    List<Medication> syrups = mockMedications
        .where((m) => m.type == MedicationType.syrup)
        .toList();
    List<Medication> injections = mockMedications
        .where((m) => m.type == MedicationType.injection)
        .toList();
    List<Medication> otherMeds = mockMedications
        .where((m) => m.type == MedicationType.others)
        .toList();

    // shared handler - tap a med in the modal -> details screen
    void  selectMedication(Medication med) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicationDetailsScreen(medication: med),
        ),
      );
    }

    // shared handler - open the category modal
    void openCategoryModal({
      required String title,
      required IconData icon,
      required List<Medication> meds,
    }) {
      CategoryMedicationsModal.show(
        context: context,
        title: title,
        icon: icon,
        medications: meds,
        onSelectMedication: selectMedication,
      );
    }

    return Scaffold(
      backgroundColor: AppColours.backgroundGreen,
      body: Column(
        children: [
          DashboardHeader(
            title: 'My Pillbox',
            subtitle: mockMedications.length.toString() + ' medications',
            onAddPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedicineScreen(),
                ),
              );
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  // pills/capsules
                  MedicationCard(
                    child: MedicationCategorySection(
                      categoryName: 'PILLS / CAPSULES',
                      categoryIcon: MedicationType.pill.outlinedIcon,
                      badgeText:
                          '${pills.length} pill(s) • ${capsules.length} capsule(s)',
                      onCategoryTap: () => openCategoryModal(
                        title: 'PILLS / CAPSULES',
                        icon: MedicationType.pill.outlinedIcon,
                        meds: [...pills, ...capsules],
                      ),
                      content: RoundMedicationList(
                        medications: [...pills, ...capsules],
                        onMedicationTap: selectMedication,
                      ),
                    ),
                  ),

                  // syrups/injections split card
                  MedicationCard(
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // syrups
                          Expanded(
                            child: MedicationCategorySection(
                              categoryName: 'SYRUPS',
                              categoryIcon: MedicationType.syrup.outlinedIcon,
                              badgeText: syrups.length.toString(),
                              onCategoryTap: () => openCategoryModal(
                                title: 'SYRUPS',
                                icon: MedicationType.syrup.outlinedIcon,
                                meds: syrups,
                              ),
                              content: MedicationColumn(
                                medications: syrups,
                                onMedicationTap: selectMedication,
                              ),
                            ),
                          ),

                          // vertical divider
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: VerticalDivider(
                              color: AppColours.buttonGrey,
                              thickness: 1,
                            ),
                          ),

                          // injections
                          Expanded(
                            child: MedicationCategorySection(
                              categoryName: 'INJECTIONS',
                              categoryIcon: MedicationType.injection.outlinedIcon,
                              badgeText: injections.length.toString(),
                              onCategoryTap: () => openCategoryModal(
                                title: 'INJECTIONS',
                                icon: MedicationType.injection.outlinedIcon,
                                meds: injections,
                              ),
                              content: MedicationColumn(
                                medications: injections,
                                onMedicationTap: selectMedication,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // other medications
                  MedicationCard(
                    child: MedicationCategorySection(
                      categoryName: 'OTHER MEDICATIONS',
                      categoryIcon: MedicationType.others.outlinedIcon,
                      badgeText: otherMeds.length.toString(),
                      onCategoryTap: () => openCategoryModal(
                        title: 'OTHERS',
                        icon: MedicationType.others.outlinedIcon,
                        meds: otherMeds,
                      ),
                      content: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: otherMeds
                              .map(
                                (m) => Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: SquareMedicationItem(
                                    medName: m.name,
                                    medQuantity:
                                        '${m.quantity} ${m.dosageUnit}',
                                    medIcon: MedicationType.others.filledIcon,
                                    onTap: () => selectMedication(m),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
