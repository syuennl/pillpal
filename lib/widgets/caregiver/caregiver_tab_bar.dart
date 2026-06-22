import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';

class CaregiverTabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const CaregiverTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              title: 'My Patients',
              icon: Icons.group_outlined,
              isActive: activeTab == 'My Patients',
            ),
          ),
          Expanded(
            child: _buildTab(
              title: 'My Caregivers',
              icon: Icons.person_add_alt_1_outlined,
              isActive: activeTab == 'My Caregivers',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTabChanged(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColours.secondaryGreen.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColours.primaryGreen : Colors.grey[600],
            ),
            const SizedBox(width: 8),

            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColours.primaryGreen : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
