import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/service_product_model.dart';
import '../../booking/screens/booking_checkout_screen.dart';

class ServiceProductDetailScreen extends StatelessWidget {
  final ServiceProductModel service;

  const ServiceProductDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header with Service Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap:
                        () =>
                            service.image.isNotEmpty
                                ? _openImageViewer(
                                  context,
                                  service.image,
                                  'header_image',
                                )
                                : null,
                    child: Hero(
                      tag: 'header_image',
                      child:
                          service.image.isNotEmpty
                              ? Image.network(
                                service.image,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: AppColors.primary.withOpacity(0.1),
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: AppTextStyles.h3.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (service.subcategoryName.isNotEmpty)
                              Text(
                                service.subcategoryName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Text(
                      //   '₹${service.price}',
                      //   style: AppTextStyles.h3.copyWith(
                      //     color: AppColors.primary,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating and Duration
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        service.rating > 0
                            ? service.rating.toStringAsFixed(1)
                            : 'New',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        ' (${service.reviewsCount} reviews)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Iconsax.clock,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      // const SizedBox(width: 4),
                      // Text(
                      //   '${service.duration} mins',
                      //   style: AppTextStyles.bodySmall.copyWith(
                      //     color: AppColors.textSecondary,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Provider Info Section
                  Text(
                    'Service Professional',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              service.providerImage.isNotEmpty
                                  ? NetworkImage(service.providerImage)
                                  : null,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child:
                              service.providerImage.isEmpty
                                  ? const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.providerName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              service.profession,
                              style: AppTextStyles.caption.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Iconsax.verify5,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  if (service.specialties.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Specialties',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          service.specialties
                              .map((s) => _buildSkillChip(s, AppColors.primary))
                              .toList(),
                    ),
                  ],

                  if (service.servicesOffered.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Services Offered',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          service.servicesOffered
                              .map((s) => _buildSkillChip(s, Colors.blue))
                              .toList(),
                    ),
                  ],

                  if (service.additionalSkills.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Additional Skills',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          service.additionalSkills
                              .map((s) => _buildSkillChip(s, Colors.teal))
                              .toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Gallery
                  if (service.gallery.isNotEmpty) ...[
                    Text(
                      'Service Gallery',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: service.gallery.length,
                        itemBuilder: (context, index) {
                          final imageUrl = service.gallery[index];
                          final heroTag = 'gallery_image_$index';
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => _openImageViewer(context, imageUrl, heroTag),
                              child: Hero(
                                tag: heroTag,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: 140,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Container(
                                          width: 140,
                                          color: AppColors.surface,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BookingCheckoutScreen(
                        serviceName: service.name,
                        serviceId: service.id,
                        price: service.price,
                      ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(
    BuildContext context,
    String imageUrl,
    String heroTag,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.9),
        pageBuilder: (context, _, __) => _FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildSkillChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImageViewer({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background dismiss area
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
