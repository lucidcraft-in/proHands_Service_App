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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header with Service Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
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
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
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
                            Text(service.name, style: AppTextStyles.h3),
                            if (service.subcategoryName.isNotEmpty)
                              Text(
                                service.subcategoryName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
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
                        ),
                      ),
                      Text(
                        ' (${service.reviewsCount} reviews)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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
                  Text('Service Professional', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
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
                              ),
                            ),
                            Text(
                              service.profession,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
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
                    Text('Specialties', style: AppTextStyles.labelLarge),
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
                    Text('Services Offered', style: AppTextStyles.labelLarge),
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
                    Text('Additional Skills', style: AppTextStyles.labelLarge),
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
                  Text('Description', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Text(
                    service.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Gallery
                  if (service.gallery.isNotEmpty) ...[
                    Text('Service Gallery', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: service.gallery.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                service.gallery[index],
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
          color: AppColors.white,
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
