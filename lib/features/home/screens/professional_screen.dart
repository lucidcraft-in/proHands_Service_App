import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/consumer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/models/user_model.dart';
import '../../../core/models/user_type.dart';
import '../../../core/widgets/expert_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import 'service_product_list_screen.dart';
import 'service_provider_detail_screen.dart';
import '../../cart/screens/cart_screen.dart';

class ProfessionalScreen extends StatefulWidget {
  const ProfessionalScreen({super.key});

  @override
  State<ProfessionalScreen> createState() => _ProfessionalScreenState();
}

class _ProfessionalScreenState extends State<ProfessionalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerProvider>().fetchCategories();
      context.read<ConsumerProvider>().fetchTrendingServices();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Professional',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Iconsax.shopping_cart,
        //       color: AppColors.textPrimary,
        //     ),
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(builder: (context) => const CartScreen()),
        //       );
        //     },
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: Column(
        children: [
          // Premium Search Bar Section
          // Container(
          //   padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          //   color: AppColors.white,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     decoration: BoxDecoration(
          //       color: AppColors.background,
          //       borderRadius: BorderRadius.circular(16),
          //       border: Border.all(color: AppColors.border.withOpacity(0.5)),
          //     ),
          //     child: const TextField(
          //       decoration: InputDecoration(
          //         hintText: 'Search for professionals...',
          //         prefixIcon: Icon(
          //           Iconsax.search_normal,
          //           color: AppColors.textTertiary,
          //           size: 20,
          //         ),
          //         border: InputBorder.none,
          //         hintStyle: TextStyle(
          //           color: AppColors.textTertiary,
          //           fontSize: 14,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: AppTextStyles.h4),
                  const SizedBox(height: 16),

                  // Fast Grid Categories
                  Consumer<ConsumerProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoadingCategories) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.categoriesError != null) {
                        return Center(
                          child: Text(
                            'Error: ${provider.categoriesError}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (provider.categories.isEmpty) {
                        return const Center(child: Text('No categories found'));
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                        itemBuilder: (context, index) {
                          final category = provider.categories[index];
                          // Map emoji or text to IconData if possible, or use a default
                          // For now, we'll maintain the existing UI structure but use category data
                          // Since API returns "icon": "🎨", we might need a mapping or just display text/image
                          // For this implementation, I will treat the iconString as text or use a default icon based on name

                          IconData iconData = Iconsax.category;
                          Color color = Colors.blue;

                          if (category.name.toLowerCase().contains('clean')) {
                            iconData = Iconsax.brush;
                            color = Colors.blue;
                          } else if (category.name.toLowerCase().contains(
                            'paint',
                          )) {
                            iconData = Iconsax.colorfilter;
                            color = Colors.green;
                          } else if (category.name.toLowerCase().contains(
                            'plumb',
                          )) {
                            iconData = Iconsax.drop;
                            color = Colors.blueAccent;
                          } else if (category.name.toLowerCase().contains(
                            'electric',
                          )) {
                            iconData = Iconsax.flash_1;
                            color = Colors.yellow.shade700;
                          }

                          return AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final delay = index * 0.08;
                              final curve = CurvedAnimation(
                                parent: _controller,
                                curve: Interval(
                                  delay.clamp(0.0, 1.0),
                                  (delay + 0.5).clamp(0.0, 1.0),
                                  curve: Curves.easeOutBack,
                                ),
                              );
                              return Opacity(
                                opacity: curve.value,
                                child: Transform.scale(
                                  scale: 0.8 + (0.2 * curve.value),
                                  child: child,
                                ),
                              );
                            },
                            child: _GridCategoryItem(
                              label: category.name,
                              icon: iconData, // Using mapped icon
                              color: color, // Using mapped color
                              onTap:
                                  () => _navigateToServiceSelection(
                                    context,
                                    category.id, // Pass ID
                                    category.name,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Trending Workers', style: AppTextStyles.h4),
                    ],
                  ),

                  // Trending Workers Vertical List
                  Consumer<ConsumerProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoadingTrendingServices) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.trendingServicesError != null) {
                        return Center(
                          child: Text(
                            'Error: ${provider.trendingServicesError}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (provider.trendingServices.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Iconsax.user_tag,
                          title: 'No Trending Workers',
                          subtitle:
                              'We couldn\'t find any trending workers at the moment. Check back soon!',
                          iconSize: 48,
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.trendingServices.length,
                        itemBuilder: (context, index) {
                          final service = provider.trendingServices[index];
                          return AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final delay = 0.4 + (index * 0.1);
                              final curve = CurvedAnimation(
                                parent: _controller,
                                curve: Interval(
                                  delay.clamp(0.0, 1.0),
                                  (delay + 0.5).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              );
                              return Opacity(
                                opacity: curve.value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - curve.value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ExpertCard(
                                name: service.providerName,
                                image: service.providerImage,
                                profession: service.profession,
                                rating: service.rating,
                                reviews: service.reviewsCount,
                                onTap: () {
                                  // Construct a partial UserModel to navigate
                                  final providerUser = UserModel(
                                    id: service.providerId,
                                    name: service.providerName,
                                    phone: '', // Not available in service model
                                    userType: UserType.serviceBoy,
                                    profession: service.profession,
                                    rating: service.rating,
                                    reviewsCount: service.reviewsCount,
                                    serviceImage: service.providerImage,
                                    // Add other fields with default/empty values
                                  );
                                  _navigateToProviderDetail(providerUser);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, double rating, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      name[0],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(name, style: AppTextStyles.labelSmall),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFA928), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFA928),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToServiceSelection(
    BuildContext context,
    String categoryId,
    String categoryName,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ServiceProductListScreen(
              categoryId: categoryId,
              categoryName: categoryName,
            ),
      ),
    );
  }

  void _navigateToProviderDetail(UserModel provider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceProviderDetailScreen(provider: provider),
      ),
    );
  }
}

class _GridCategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GridCategoryItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Center(child: Icon(icon, color: color, size: 32)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
