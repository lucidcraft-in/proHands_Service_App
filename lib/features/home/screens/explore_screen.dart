import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:iconsax/iconsax.dart';
import '../../cart/screens/cart_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Explore',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search for services...',
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
            const SizedBox(height: 24),

            Text('Featured', style: AppTextStyles.h4),
            const SizedBox(height: 16),

            // Featured Horizontal List
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  final List<Map<String, dynamic>> exploreItems = [
                    {
                      'title': 'Home Deep Cleaning',
                      'subtitle': 'Top Choice this week',
                      'image': 'assets/images/cleaning_service.png',
                      'color': const Color(0xFF4A90E2),
                    },
                    {
                      'title': 'Express AC Service',
                      'subtitle': 'Starts from \$29',
                      'image': 'assets/images/ac_repair_service.png',
                      'color': const Color(0xFFF5A623),
                    },
                    {
                      'title': 'Professional Painting',
                      'subtitle': 'Wall to Wall perfection',
                      'image': 'assets/images/painting_service.png',
                      'color': const Color(0xFF7ED321),
                    },
                  ];
                  final item = exploreItems[index];

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final delay = index * 0.1;
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
                          offset: Offset(20 * (1 - curve.value), 0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.asset(
                              item['image'],
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item['color'],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'FEATURED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['title'],
                                    style: AppTextStyles.h4.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle'],
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            Text('New Arrivals', style: AppTextStyles.h4),
            const SizedBox(height: 16),

            // New Arrivals List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> newArrivals = [
                  {
                    'title': 'Smart Home Installation',
                    'subtitle': 'Upgrade your living space with smart tech.',
                    'image': 'assets/images/smart_home_install.png',
                  },
                  {
                    'title': 'Garden Maintenance',
                    'subtitle': 'Keep your garden green and healthy.',
                    'image': 'assets/images/garden_maintenance.png',
                  },
                  {
                    'title': 'Premium Kitchen Cleaning',
                    'subtitle':
                        'Get your kitchen spotless with our expert team.',
                    'image': 'assets/images/cleaning_service.png',
                  },
                ];
                final item = newArrivals[index];

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = 0.3 + (index * 0.1);
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
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(item['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: AppTextStyles.h4.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['subtitle'],
                                style: AppTextStyles.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
