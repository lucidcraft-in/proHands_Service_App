import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';

class LocationSelectorBottomSheet extends StatelessWidget {
  final Function(String) onLocationSelected;

  const LocationSelectorBottomSheet({
    super.key,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final recentLocations = [
      'Mesa, New Jersey - 45463',
      '8502 Preston Rd. Inglewood, Maine 98380',
      '4140 Parker Rd. Allentown, New Mexico 31134',
    ];

    final savedLocations = [
      {
        'label': 'Home',
        'address': '2464 Royal Ln. Mesa, New Jersey',
        'icon': Iconsax.home,
      },
      {
        'label': 'Work',
        'address': '3891 Ranchview Dr. Richardson, California',
        'icon': Iconsax.briefcase,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Select Location', style: AppTextStyles.h4),
          const SizedBox(height: 20),

          // Search
          SearchTextField(hint: 'Search location...', onFilterTap: () {}),
          const SizedBox(height: 24),

          // Use Current Location
          InkWell(
            onTap: () {
              onLocationSelected('Current Location (Detected)');
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.gps,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Use current location',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Saved Locations
          Text('Saved Locations', style: AppTextStyles.labelMedium),
          const SizedBox(height: 16),
          ...savedLocations.map(
            (loc) => _buildLocationItem(
              context,
              loc['label'] as String,
              loc['address'] as String,
              loc['icon'] as IconData,
            ),
          ),

          const SizedBox(height: 24),

          // Recent Locations
          Text('Recent Locations', style: AppTextStyles.labelMedium),
          const SizedBox(height: 16),
          ...recentLocations.map(
            (address) => _buildRecentItem(context, address),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
    BuildContext context,
    String label,
    String address,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          onLocationSelected(address);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(BuildContext context, String address) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          onLocationSelected(address);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            const Icon(Iconsax.clock, color: AppColors.textTertiary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                address,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
