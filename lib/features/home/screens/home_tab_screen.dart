import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/consumer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/category_item.dart';
import 'full_image_screen.dart';
import 'main_screen.dart';
import 'service_product_list_screen.dart';
import 'customer_bookings_screen.dart';

import '../../cart/screens/cart_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if categories are already loaded to avoid redundant calls if maintained in provider
      // But allow refresh if needed. Provider usually keeps state.
      if (context.read<ConsumerProvider>().categories.isEmpty) {
        context.read<ConsumerProvider>().fetchCategories();
      }
    });
    if (context.read<ConsumerProvider>().feeds.isEmpty) {
      context.read<ConsumerProvider>().fetchFeeds();
    }
  }

  @override
  void dispose() {
    super.dispose();
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
                            // Container(
                            //   decoration: BoxDecoration(
                            //     color: AppColors.background,
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child: IconButton(
                            //     icon: const Icon(
                            //       Iconsax.notification,
                            //       size: 20,
                            //     ),
                            //     color: AppColors.textPrimary,
                            //     onPressed: () {
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder:
                            //               (context) =>
                            //                   const CustomerBookingsScreen(),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
                            // const SizedBox(width: 12),
                            // Container(
                            //   decoration: BoxDecoration(
                            //     color: AppColors.background,
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child: IconButton(
                            //     icon: const Icon(
                            //       Iconsax.shopping_cart,
                            //       size: 20,
                            //     ),
                            //     color: AppColors.textPrimary,
                            //     onPressed: () {
                            //       Navigator.of(context).push(
                            //         MaterialPageRoute(
                            //           builder: (context) => const CartScreen(),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // ),
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
                child: Consumer<ConsumerProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoadingCategories) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.categories.isEmpty) {
                      return const Center(child: Text('No categories'));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final category = provider.categories[index];

                        // Map icons and colors (same logic as ProfessionalScreen)
                        // IconData iconData = Iconsax.category;
                        IconData iconData = Iconsax.category;
                        Color color = Colors.blue;

                        if (category.name.toLowerCase().contains('clean')) {
                          iconData =
                              Icons.cleaning_services; // Or Iconsax.brush
                          color = Colors.blue;
                        } else if (category.name.toLowerCase().contains(
                          'paint',
                        )) {
                          iconData = Icons.format_paint;
                          color = Colors.green;
                        } else if (category.name.toLowerCase().contains(
                          'plumb',
                        )) {
                          iconData = Icons.water_drop;
                          color = Colors.cyan; // or blueAccent
                        } else if (category.name.toLowerCase().contains(
                          'electric',
                        )) {
                          iconData = Icons.electric_bolt;
                          color = Colors.yellow.shade700;
                        } else if (category.name.toLowerCase().contains(
                          'repair',
                        )) {
                          iconData = Icons.build;
                          color = Colors.orange;
                        } else if (category.name.toLowerCase().contains(
                          'salon',
                        )) {
                          iconData = Icons.face;
                          color = Colors.pink;
                        } else if (category.name.toLowerCase().contains(
                          'carpenter',
                        )) {
                          iconData = Icons.handyman;
                          color = Colors.brown;
                        } else if (category.name.toLowerCase().contains(
                          'cook',
                        )) {
                          iconData = Icons.restaurant;
                          color = Colors.red;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                            width: 70,
                            child: CategoryItem(
                              name: category.name,
                              icon: iconData,
                              color: color,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ServiceProductListScreen(
                                          categoryId: category.id,
                                          categoryName: category.name,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
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
                child: Consumer<ConsumerProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoadingFeeds) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.feedsError != null) {
                      return Center(
                        child: Text('Error: ${provider.feedsError}'),
                      );
                    }

                    if (provider.feeds.isEmpty) {
                      return const Center(
                        child: Text('No service highlights yet'),
                      );
                    }

                    return StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: List.generate(provider.feeds.length, (index) {
                        final feed = provider.feeds[index];
                        final String imageUrl =
                            feed.images.isNotEmpty
                                ? feed.images.first
                                : 'https://via.placeholder.com/300';

                        // Create a repeating pattern
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
                                        imagePath: imageUrl,
                                        isNetworkImage: true,
                                        uploader: feed.provider.toUserModel(),
                                      ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: imageUrl,
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
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
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
