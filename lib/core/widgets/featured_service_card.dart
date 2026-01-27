import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FeaturedServiceCard extends StatelessWidget {
  final String providerName;
  final String providerImage;
  final double rating;
  final String serviceImage;
  final String serviceName;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final String duration;
  final String servicemenRequired;
  final String? description;
  final bool isAdded;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const FeaturedServiceCard({
    super.key,
    required this.providerName,
    required this.providerImage,
    required this.rating,
    required this.serviceImage,
    required this.serviceName,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.duration,
    required this.servicemenRequired,
    this.description,
    this.isAdded = false,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(providerImage),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child:
                        providerImage.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      providerName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.star, color: Color(0xFFFFA928), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Service image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    serviceImage,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 160,
                          color: AppColors.background,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textTertiary,
                          ),
                        ),
                  ),
                ),
                if (discountPercent > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$discountPercent%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Service details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (originalPrice > discountedPrice) ...[
                        Text(
                          '\$${originalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '\$${discountedPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.priceMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        servicemenRequired,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: onAddTap,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color:
                              isAdded ? AppColors.success : AppColors.primary,
                          width: 1.5,
                        ),
                        backgroundColor:
                            isAdded ? AppColors.successLight : AppColors.white,
                      ),
                      child: Text(
                        isAdded ? 'Added' : 'Add',
                        style: AppTextStyles.labelMedium.copyWith(
                          color:
                              isAdded ? AppColors.success : AppColors.primary,
                        ),
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
}
