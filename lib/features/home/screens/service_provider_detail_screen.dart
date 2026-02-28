import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/user_model.dart';
import '../../home/providers/consumer_provider.dart';
import '../../home/models/service_product_model.dart';
import '../../booking/screens/booking_checkout_screen.dart';

class ServiceProviderDetailScreen extends StatefulWidget {
  final UserModel provider;

  const ServiceProviderDetailScreen({super.key, required this.provider});

  @override
  State<ServiceProviderDetailScreen> createState() =>
      _ServiceProviderDetailScreenState();
}

class _ServiceProviderDetailScreenState
    extends State<ServiceProviderDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ConsumerProvider>().fetchAllServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ConsumerProvider>(
        builder: (context, consumerProvider, child) {
          final providerServices =
              consumerProvider.allServices
                  .where((s) => s.providerId == provider.id)
                  .toList();

          return CustomScrollView(
            slivers: [
              // Header with Image/Avatar
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.white.withOpacity(0.2),
                              child: Text(
                                (provider.name?.isNotEmpty == true
                                    ? provider.name![0]
                                    : 'P'),
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.white,
                                  fontSize: 50,
                                ),
                              ),
                            ),
                            if (provider.location.isNotEmpty &&
                                provider.location != 'Unknown') ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.location,
                                    size: 16,
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider.location,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Overlay for better back button visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
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
                      // Basic Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.name ?? 'Provider',
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.profession,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA928).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFA928),
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  provider.rating.toString(),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: const Color(0xFFFFA928),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        children: [
                          _buildStatItem(
                            Iconsax.verify,
                            'Verified',
                            'Identity',
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(
                            Iconsax.message,
                            '${provider.reviewsCount}',
                            'Reviews',
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(Iconsax.award, '5+ Years', 'Exp.'),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Bio
                      Text('About me', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 12),
                      Text(
                        provider.bio,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Services Offered
                      if (provider.servicesOffered.isNotEmpty) ...[
                        Text(
                          'Services Offered',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              provider.servicesOffered
                                  .map((s) => _buildChip(s, AppColors.primary))
                                  .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Work Preference
                      if (provider.workPreference.isNotEmpty) ...[
                        Text(
                          'Work Preference',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              provider.workPreference
                                  .map((s) => _buildChip(s, Colors.orange))
                                  .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Preferred Work Location
                      if (provider.workLocationPreferred.isNotEmpty) ...[
                        Text(
                          'Preferred Work Locations',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              provider.workLocationPreferred
                                  .map((s) => _buildChip(s, Colors.green))
                                  .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Portfolio / Previous Work Section
                      // Portfolio Section
                      // Text('Previous Work', style: AppTextStyles.h4),
                      // const SizedBox(height: 16),
                      // SizedBox(
                      //   height: 120,
                      //   child: ListView(
                      //     scrollDirection: Axis.horizontal,
                      //     children: [
                      //       _portfolioItem('assets/images/cleaning_service.png'),
                      //       _portfolioItem('assets/images/ac_repair_service.png'),
                      //       _portfolioItem('assets/images/painting_service.png'),
                      //       _portfolioItem('assets/images/smart_home_install.png'),
                      //       _portfolioItem('assets/images/garden_maintenance.png'),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 32),

                      // Specialties
                      Text('Specialties', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            provider.specialties
                                .map((s) => _buildBadge(s))
                                .toList(),
                      ),

                      const SizedBox(height: 32),

                      // Services Provided by this Professional
                      Text('Services Offered', style: AppTextStyles.h4),
                      const SizedBox(height: 16),
                      if (consumerProvider.isLoadingAllServices)
                        const Center(child: CircularProgressIndicator())
                      else if (providerServices.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No specific services listed yet.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: providerServices.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final service = providerServices[index];
                            return _buildServiceItem(context, service);
                          },
                        ),

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),

              // Bottom Booking Bar (Optional now that we have service items, but keep as primary contact/general)
              SliverToBoxAdapter(
                child: Container(
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
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // General inquiry or book the first available service?
                            // Or just deep link to chat?
                            // For now keep it as "General Booking" if needed or hide it.
                            if (providerServices.isNotEmpty) {
                              _navigateToCheckout(
                                context,
                                providerServices.first,
                              );
                            } else {
                              // Fallback if no specific services listed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => BookingCheckoutScreen(
                                        serviceName:
                                            '${provider.profession} - ${provider.name ?? 'Provider'}',
                                        serviceId: provider.id,
                                        price: 45.0,
                                      ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'General Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToCheckout(BuildContext context, ServiceProductModel service) {
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
  }

  Widget _buildServiceItem(BuildContext context, ServiceProductModel service) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (service.image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    service.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.textTertiary,
                          ),
                        ),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${service.price}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToCheckout(context, service),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Book This Service'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
