import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Expert service card matching the design with profile photo, name,
/// service type, location, and rating
class ExpertServiceCard extends StatelessWidget {
  final String name;
  final String profileImage;
  final String serviceType;
  final String location;
  final double rating;
  final VoidCallback? onTap;

  // No longer using default profile photos for service providers
  static const String defaultWorkImage = 'assets/images/cleaning_service.png';

  const ExpertServiceCard({
    super.key,
    required this.name,
    required this.profileImage,
    required this.serviceType,
    required this.location,
    required this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use fallback work image if path is empty
    final String displayImage =
        profileImage.isEmpty ? defaultWorkImage : profileImage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Work Image - Rectangular focus
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.background,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  displayImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.work_outline,
                        size: 32,
                        color: AppColors.textTertiary,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Service Type
                  Text(
                    serviceType,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location Row
                  Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rating Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFFFFA928)),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 12,
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
}
