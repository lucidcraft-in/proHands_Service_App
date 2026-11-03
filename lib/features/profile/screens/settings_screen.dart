import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.h4,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Theme
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.moon,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Theme',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  _selectedTheme,
                  style: AppTextStyles.caption,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
                onTap: () {
                  _showThemeDialog();
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App Information
            Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'ABOUT',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Iconsax.info_circle,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'About Us',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                    onTap: () => _launchWebUrl('https://www.prohands.in/#about'),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Iconsax.document_text,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Privacy Policy',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                    onTap: () => _launchWebUrl('https://www.prohands.in/terms-and-conditions'),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Iconsax.document,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Terms & Conditions',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                    onTap: () => _launchWebUrl('https://www.prohands.in/terms-and-conditions'),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Iconsax.mobile,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'App Version',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWebUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching url $urlString: $e');
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Theme', style: AppTextStyles.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text('Light'),
              value: 'Light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text('Dark'),
              value: 'Dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() => _selectedTheme = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
