import 'package:flutter/material.dart';
import '../../utils/app_colours.dart';
import '../../screens/profile/privacy_security_screen.dart';
import '../../screens/profile/help_support_screen.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),

        // privacy & security
        _buildSettingRow(
          Icons.shield_outlined,
          'Privacy & Security',
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrivacySecurityScreen(),
            ),
          ),
        ),

        // help & support
        _buildSettingRow(
          Icons.help_outline,
          'Help & Support',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingRow(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColours.primaryGreen, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
