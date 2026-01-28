import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/dummy_data_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_type.dart';
import '../../../core/widgets/expert_card.dart';
import 'service_provider_list_screen.dart';
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

  final List<Map<String, dynamic>> _categories = [
    {'icon': Iconsax.brush, 'label': 'Cleaning', 'color': Colors.blue},
    {
      'icon': Iconsax.flash_1,
      'label': 'Electrician',
      'color': Colors.yellow.shade700,
    },
    {'icon': Iconsax.airdrop, 'label': 'Ac Repair', 'color': Colors.cyan},
    {'icon': Iconsax.user_square, 'label': 'Carpenter', 'color': Colors.brown},
    {'icon': Iconsax.coffee, 'label': 'Cooking', 'color': Colors.red},
    {'icon': Iconsax.colorfilter, 'label': 'Painter', 'color': Colors.green},
    {'icon': Iconsax.drop, 'label': 'Plumber', 'color': Colors.blueAccent},
    {'icon': Iconsax.magicpen, 'label': 'Saloon', 'color': Colors.pink},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trendingWorkers =
        DummyDataService.instance
            .getUsersByType(UserType.serviceBoy)
            .take(5)
            .toList();

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
        actions: [
          IconButton(
            icon: const Icon(
              Iconsax.shopping_cart,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Premium Search Bar Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            color: AppColors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search for professionals...',
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: AppTextStyles.h4),
                  const SizedBox(height: 16),

                  // Fast Grid Categories
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
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
                          label: category['label'],
                          icon: category['icon'],
                          color: category['color'],
                          onTap:
                              () => _navigateToServiceSelection(
                                context,
                                category['label'],
                              ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Trending Workers', style: AppTextStyles.h4),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Trending Workers Vertical List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trendingWorkers.length,
                    itemBuilder: (context, index) {
                      final worker = trendingWorkers[index];
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
                            name: worker.name,
                            image: worker.serviceImage,
                            profession: worker.profession,
                            rating: worker.rating,
                            reviews: worker.reviewsCount,
                            onTap: () => _navigateToProviderDetail(worker),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Recent Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Reviews', style: AppTextStyles.h4),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildReviewItem(
                    'Amal',
                    5.0,
                    'Very professional and punctual service. Highly recommended!',
                  ),
                  _buildReviewItem(
                    'Siyed',
                    4.8,
                    'Found the right expert quickly. The cleaning was thorough.',
                  ),
                  _buildReviewItem(
                    'Abi',
                    4.5,
                    'Good experience overall. Expert was polite and efficient.',
                  ),

                  const SizedBox(height: 20),
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

  void _navigateToServiceSelection(BuildContext context, String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceProviderListScreen(category: category),
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
