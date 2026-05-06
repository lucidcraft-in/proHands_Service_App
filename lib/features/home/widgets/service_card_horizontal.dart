import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/service_product_model.dart';
import '../screens/service_product_detail_screen.dart';
import '../screens/service_provider_detail_screen.dart';
import '../services/consumer_service.dart';

class ServiceCardHorizontal extends StatelessWidget {
  final ServiceProductModel service;

  const ServiceCardHorizontal({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        fetchAndNavigateToProfile(context, service.providerId);

        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => ServiceProductDetailScreen(service: service),
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  service.image.isNotEmpty
                      ? Image.network(
                        service.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: const Icon(Icons.broken_image, size: 24),
                            ),
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: const Icon(Icons.image, size: 24),
                      ),
            ),
            const SizedBox(width: 12),
            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.providerName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        service.rating > 0
                            ? service.rating.toStringAsFixed(1)
                            : 'New',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Iconsax.arrow_right_3,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
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

Future<void> fetchAndNavigateToProfile(
  BuildContext context,
  String providerId,
) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final consumerService = ConsumerService();
    final provider = await consumerService.getProviderById(providerId);

    // Hide loading details
    if (context.mounted) {
      Navigator.of(context).pop(); // Pop loading dialog
    }

    // Navigate to detail screen
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ServiceProviderDetailScreen(provider: provider),
        ),
      );
    }
  } catch (e) {
    // Hide loading details
    if (context.mounted) {
      Navigator.of(context).pop(); // Pop loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
