import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../models/service_product_model.dart';
import '../../booking/screens/booking_checkout_screen.dart';
import '../providers/consumer_provider.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class ServiceProductDetailScreen extends StatefulWidget {
  final ServiceProductModel service;

  const ServiceProductDetailScreen({super.key, required this.service});

  @override
  State<ServiceProductDetailScreen> createState() =>
      _ServiceProductDetailScreenState();
}

class _ServiceProductDetailScreenState
    extends State<ServiceProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerProvider>().fetchServiceDetails(widget.service.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsumerProvider>(
      builder: (context, provider, child) {
        // Use fetched service if available, otherwise fallback to constructor service
        final service =
            (provider.currentService != null &&
                    provider.currentService!.id == widget.service.id)
                ? provider.currentService!
                : widget.service;

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
                      _buildHeaderImage(context, service),
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
                      if (provider.isLoadingServiceDetails)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
                      // Service Name and Category
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                if (service.subcategoryName.isNotEmpty ||
                                    service.categoryName.isNotEmpty)
                                  Text(
                                    service.subcategoryName.isNotEmpty
                                        ? service.subcategoryName
                                        : service.categoryName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rating and Info
                      Row(
                        children: [
                          const Icon(
                            Iconsax.star1,
                            size: 18,
                            color: Colors.amber,
                          ),
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
                          const SizedBox(width: 4),
                          Text(
                            '${service.duration} mins',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
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
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child:
                                  service.providerImage.isEmpty
                                      ? const Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.providerName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    service.profession,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                  .map(
                                    (s) =>
                                        _buildSkillChip(s, AppColors.primary),
                                  )
                                  .toList(),
                        ),
                      ],

                      if (service.servicesOffered.isNotEmpty) ...[
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
                                  .map((s) => _buildSkillChip(s, Colors.blue))
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
                                  onTap:
                                      () => _openImageViewer(
                                        context,
                                        imageUrl,
                                        heroTag,
                                      ),
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
                                            (context, error, stackTrace) =>
                                                Container(
                                                  width: 140,
                                                  color: AppColors.surface,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                  ),
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
                            serviceDescription: service.description,
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
      },
    );
  }

  Widget _buildHeaderImage(BuildContext context, ServiceProductModel service) {
    // Priority: 1. Service Image, 2. Category Image, 3. Gradient Placeholder
    String? imageUrl;

    if (service.image.isNotEmpty) {
      imageUrl = service.image;
    } else if (service.categoryImage.isNotEmpty) {
      imageUrl = service.categoryImage;
    }

    return GestureDetector(
      onTap:
          () =>
              imageUrl != null
                  ? _openImageViewer(context, imageUrl, 'header_image')
                  : null,
      child: Hero(
        tag: 'header_image',
        child:
            imageUrl != null
                ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // If primary image fails, try category image if not already tried
                    if (service.image.isNotEmpty &&
                        service.categoryImage.isNotEmpty) {
                      return Image.network(
                        service.categoryImage,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => _buildPlaceholder(),
                      );
                    }
                    return _buildPlaceholder();
                  },
                )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Icon(Icons.image, size: 80, color: Colors.white),
    );
  }

  void _openImageViewer(BuildContext context, String imageUrl, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenImageViewer(
              imagePath: imageUrl,
              tag: heroTag,
              isFile:
                  true, // It uses Image.network internally in this app's widget
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
