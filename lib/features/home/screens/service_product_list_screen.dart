import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../providers/consumer_provider.dart';
import '../models/service_product_model.dart';
import 'service_product_detail_screen.dart';

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
  String? _selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConsumerProvider>();
      provider.fetchServicesByCategory(widget.categoryId);
      provider.fetchSubcategories(widget.categoryId);
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
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ConsumerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingSubcategories &&
              provider.subcategories.isEmpty) {
            return const _ShimmerLoadingState();
          }
          return Column(
            children: [
              // Subcategory Chips
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child:
                    provider.isLoadingSubcategories
                        ? const ChipShimmer()
                        : provider.subcategories.isNotEmpty
                        ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.subcategories.length + 1,
                          itemBuilder: (context, index) {
                            final bool isAll = index == 0;
                            final bool isSelected =
                                isAll
                                    ? _selectedSubcategoryId == null
                                    : _selectedSubcategoryId ==
                                        provider.subcategories[index - 1].id;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  isAll
                                      ? 'All'
                                      : provider.subcategories[index - 1].name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedSubcategoryId =
                                          isAll
                                              ? null
                                              : provider
                                                  .subcategories[index - 1]
                                                  .id;
                                    });

                                    if (isAll) {
                                      provider.fetchServicesByCategory(
                                        widget.categoryId,
                                      );
                                    } else {
                                      provider.fetchServicesBySubcategory(
                                        provider.subcategories[index - 1].id,
                                      );
                                    }
                                  }
                                },
                                backgroundColor: Colors.white,
                                selectedColor: AppColors.primary,
                                checkmarkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : AppColors.border,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                size: 16,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No subcategories available',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),

              Expanded(child: _buildBody(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(ConsumerProvider provider) {
    if (provider.isLoadingServices) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const ListCardShimmer(),
      );
    }

    if (provider.servicesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error loading services', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 8),
            Text(
              provider.servicesError!,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedSubcategoryId == null) {
                  provider.fetchServicesByCategory(widget.categoryId);
                } else {
                  provider.fetchServicesBySubcategory(_selectedSubcategoryId!);
                }
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
  }
}

class _ServiceProductCard extends StatelessWidget {
  final ServiceProductModel service;

  const _ServiceProductCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ServiceProductDetailScreen(service: service),
          ),
        );
      },
      child: Container(
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
                // Text(
                //   '₹${service.price}',
                //   style: AppTextStyles.labelMedium.copyWith(
                //     color: AppColors.primary,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
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
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                  ),
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

            // Gallery Section (always show 3 image slots)
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: Row(
                children: List.generate(3, (i) {
                  final imageUrl =
                      i < service.gallery.length ? service.gallery[i] : null;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            imageUrl != null
                                ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  height: 72,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 72,
                                        color: AppColors.background,
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 20,
                                        ),
                                      ),
                                )
                                : Container(
                                  height: 72,
                                  color: AppColors.background,
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 20,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            // Arrow to navigate
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerLoadingState extends StatelessWidget {
  const _ShimmerLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 60,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [ChipShimmer(), ChipShimmer(), ChipShimmer()]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => const ListCardShimmer(),
          ),
        ),
      ],
    );
  }
}
