import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/service_boy_provider.dart';
import 'edit_service_screen.dart';

class ServiceBoyServiceDetailsScreen extends StatefulWidget {
  final String serviceId;

  const ServiceBoyServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceBoyServiceDetailsScreen> createState() =>
      _ServiceBoyServiceDetailsScreenState();
}

class _ServiceBoyServiceDetailsScreenState
    extends State<ServiceBoyServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceBoyProvider>().fetchServiceDetails(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ServiceBoyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingServiceDetails) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.serviceDetailsError != null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: Text('Service Details', style: AppTextStyles.h4),
                centerTitle: true,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.warning_2,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load service',
                      style: AppTextStyles.h4.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.serviceDetailsError!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed:
                          () => provider.fetchServiceDetails(widget.serviceId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final service = provider.selectedService;
          if (service == null) {
            return const Scaffold(
              body: Center(child: Text('Service not found')),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                // Sliver App Bar with service image
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Iconsax.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EditServiceScreen(service: service),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              provider.fetchServiceDetails(widget.serviceId);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        service.imageUrl != null && service.imageUrl!.isNotEmpty
                            ? Image.network(
                              service.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stack) =>
                                      _buildImagePlaceholder(
                                        service.categoryIcon,
                                      ),
                            )
                            : _buildImagePlaceholder(service.categoryIcon),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Badges Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                style: AppTextStyles.h3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.end,
                            //   children: [
                            //     _buildBadge(
                            //       service.isActive ? 'Active' : 'Inactive',
                            //       service.isActive
                            //           ? AppColors.success
                            //           : AppColors.error,
                            //     ),
                            //     const SizedBox(height: 6),
                            //     _buildBadge(
                            //       service.isApproved ? 'Approved' : 'Pending',
                            //       service.isApproved
                            //           ? AppColors.primary
                            //           : const Color(0xFFFFA928),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Category chip
                        if (service.categoryName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  service.categoryIcon,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  service.categoryName,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // isTrending indicator
                        if (service.isTrending)
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFFA928).withOpacity(0.15),
                                  const Color(0xFFFF6B35).withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFA928).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.trend_up,
                                  color: Color(0xFFFFA928),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '🔥 Trending Service',
                                        style: AppTextStyles.labelMedium
                                            .copyWith(
                                              color: const Color(0xFFCC8000),
                                            ),
                                      ),
                                      Text(
                                        'This service is featured as trending',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Description
                        Text('Description', style: AppTextStyles.h4),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            service.description.isNotEmpty
                                ? service.description
                                : 'No description provided.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Provider Info (if available)
                        if (service.providerName != null ||
                            service.providerPhone != null) ...[
                          Text('Provider', style: AppTextStyles.h4),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Iconsax.user,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (service.providerName != null)
                                      Text(
                                        service.providerName!,
                                        style: AppTextStyles.labelMedium,
                                      ),
                                    if (service.providerPhone != null)
                                      Text(
                                        service.providerPhone!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Status Details Grid
                        Text('Details', style: AppTextStyles.h4),
                        const SizedBox(height: 10),
                        GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildDetailChip(
                              Iconsax.activity,
                              'Status',
                              service.status,
                              AppColors.primary,
                            ),
                            _buildDetailChip(
                              service.isApproved
                                  ? Iconsax.tick_circle
                                  : Iconsax.clock,
                              'Approval',
                              service.isApproved ? 'Approved' : 'Pending',
                              service.isApproved
                                  ? AppColors.success
                                  : const Color(0xFFFFA928),
                            ),
                            _buildDetailChip(
                              Iconsax.trend_up,
                              'Trending',
                              service.isTrending ? 'Yes' : 'No',
                              service.isTrending
                                  ? const Color(0xFFFFA928)
                                  : AppColors.textTertiary,
                            ),
                            _buildDetailChip(
                              Iconsax.category,
                              'Category',
                              service.categoryName.isNotEmpty
                                  ? service.categoryName
                                  : '—',
                              AppColors.primary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Edit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditServiceScreen(service: service),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  provider.fetchServiceDetails(
                                    widget.serviceId,
                                  );
                                }
                              });
                            },
                            icon: const Icon(Iconsax.edit, color: Colors.white),
                            label: Text(
                              'Edit Service',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder(String categoryIcon) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              categoryIcon.isNotEmpty ? categoryIcon : '🔧',
              style: const TextStyle(fontSize: 56),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
