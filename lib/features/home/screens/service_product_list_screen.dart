import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../booking/screens/booking_checkout_screen.dart';
import '../providers/consumer_provider.dart';
import '../models/service_product_model.dart';

class ServiceProductListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ServiceProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ServiceProductListScreen> createState() =>
      _ServiceProductListScreenState();
}

class _ServiceProductListScreenState extends State<ServiceProductListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerProvider>().fetchServicesByCategory(
        widget.categoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryName, style: AppTextStyles.h4),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ConsumerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingServices) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.servicesError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading services',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.servicesError!,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchServicesByCategory(widget.categoryId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.services.isEmpty) {
            return EmptyStateWidget(
              icon: Iconsax.search_status,
              title: 'No Services Found',
              subtitle:
                  'We couldn\'t find any services for ${widget.categoryName} at the moment.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.services.length,
            itemBuilder: (context, index) {
              final service = provider.services[index];
              return _ServiceProductCard(service: service);
            },
          );
        },
      ),
    );
  }
}

class _ServiceProductCard extends StatelessWidget {
  final ServiceProductModel service;

  const _ServiceProductCard({required this.service});

  @override
  Widget build(BuildContext context) {
    print(service);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.h4.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Price
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Provider and Service Image Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    service.image.isNotEmpty
                        ? Image.network(
                          service.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 48,
                                height: 48,
                                color: AppColors.background,
                                child: const Icon(Icons.broken_image, size: 20),
                              ),
                        )
                        : Container(
                          width: 48,
                          height: 48,
                          color: AppColors.background,
                          child: const Icon(Icons.image, size: 20),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.providerName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (service.profession.isNotEmpty)
                      Text(
                        service.profession,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Iconsax.star1, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    service.rating > 0
                        ? service.rating.toStringAsFixed(1)
                        : 'New',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (service.reviewsCount > 0)
                    Text(
                      ' (${service.reviewsCount})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Gallery Section
          if (service.gallery.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: Row(
                children:
                    service.gallery.take(3).map((imageUrl) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.background,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                  ),
                                ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Determine logic for booking
                // For now just show a snackbar or placeholder
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Booking feature coming soon!')),
                // );
                Navigator.of(context).push(
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Book Now'),
            ),
          ),
        ],
      ),
    );
  }
}
