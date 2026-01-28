import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_type.dart';
import '../../../core/services/dummy_data_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/category_item.dart';
import 'full_image_screen.dart';
import 'main_screen.dart';
import 'service_provider_list_screen.dart';

import '../../cart/screens/cart_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.blue},
    {'name': 'Repair', 'icon': Icons.build, 'color': Colors.orange},
    {
      'name': 'Electrician',
      'icon': Icons.electric_bolt,
      'color': Colors.yellow.shade700,
    },
    {'name': 'Plumber', 'icon': Icons.water_drop, 'color': Colors.cyan},
    {'name': 'Salon', 'icon': Icons.face, 'color': Colors.pink},
    {'name': 'Painting', 'icon': Icons.format_paint, 'color': Colors.green},
    {'name': 'Carpenter', 'icon': Icons.handyman, 'color': Colors.brown},
    {'name': 'Cooking', 'icon': Icons.restaurant, 'color': Colors.red},
  ];

  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _posts = _getServiceBoyPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> _getServiceBoyPosts() {
    final serviceBoys = DummyDataService.instance.getUsersByType(
      UserType.serviceBoy,
    );
    List<Map<String, dynamic>> posts = [];
    for (UserModel boy in serviceBoys) {
      for (String img in boy.portfolioImages) {
        posts.add({'image': img, 'boy': boy});
      }
    }
    // Shuffle to make it look like a feed
    posts.shuffle();
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with location
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.jpg',
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PRO HANDS',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            // Container(
                            //   decoration: BoxDecoration(
                            //     color: AppColors.background,
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child: IconButton(
                            //     icon: const Icon(
                            //       Iconsax.search_normal_1,
                            //       size: 20,
                            //     ),
                            //     color: AppColors.textPrimary,
                            //     onPressed: () {
                            //       // In a real app, this could open a search delegate or focus the search bar
                            //       MainScreen.of(
                            //         context,
                            //       )?.setIndex(2); // Navigate to Explore
                            //     },
                            //   ),
                            // ),
                            // const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Iconsax.notification,
                                  size: 20,
                                ),
                                color: AppColors.textPrimary,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Iconsax.shopping_cart,
                                  size: 20,
                                ),
                                color: AppColors.textPrimary,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const CartScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories', style: AppTextStyles.h4),
                    TextButton(
                      onPressed: () {
                        MainScreen.of(context)?.setIndex(3);
                      },
                      child: Text(
                        'See all',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: 70,
                        child: CategoryItem(
                          name: category['name'],
                          icon: category['icon'],
                          color: category['color'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ServiceProviderListScreen(
                                      category: category['name'],
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Staggered Feed Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Service Highlights', style: AppTextStyles.h4),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: List.generate(_posts.length, (index) {
                    final post = _posts[index];
                    // Create a repeating pattern of tall and square tiles to match the image
                    // Pattern: Tall, Square, Tall (right), Square, Square...
                    int mainAxisCellCount = 1;
                    if (index % 4 == 0) {
                      mainAxisCellCount = 2; // Tall on left
                    } else if (index % 4 == 3) {
                      mainAxisCellCount = 2; // Tall on right
                    }

                    return StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: mainAxisCellCount,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FullImageScreen(
                                    imagePath: post['image'],
                                    uploader: post['boy'],
                                  ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: post['image'],
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                post['image'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
