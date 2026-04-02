import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:service_app/features/location/screens/location_fetch_screen.dart';
import '../providers/consumer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/shimmer_loading.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../widgets/category_item.dart';
import 'full_image_screen.dart';
import 'main_screen.dart';
import 'service_product_list_screen.dart';
import 'customer_bookings_screen.dart';
import 'notification_screen.dart';
import '../providers/notification_provider.dart';

import '../../cart/screens/cart_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  String _locationText = 'Locating...';

  @override
  void initState() {
    super.initState();
    _loadLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if categories are already loaded to avoid redundant calls if maintained in provider
      // But allow refresh if needed. Provider usually keeps state.
      if (context.read<ConsumerProvider>().categories.isEmpty) {
        context.read<ConsumerProvider>().fetchCategories();
      }
      if (context.read<ConsumerProvider>().feeds.isEmpty) {
        context.read<ConsumerProvider>().fetchFeeds();
      }
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  Future<void> _loadLocation() async {
    final locationData = await StorageService.getUserLocation();
    if (mounted) {
      setState(() {
        _locationText = locationData?['address'] ?? 'Set your location';
      });
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
                color: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo1.png',

                          height: 32,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PRO HANDS',
                          style: AppTextStyles.h4.copyWith(
                            color: const Color.fromARGB(255, 62, 66, 83),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Consumer<NotificationProvider>(
                              builder: (context, provider, child) {
                                return IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const NotificationScreen(),
                                      ),
                                    );
                                  },
                                  icon: Badge(
                                    label: Text(
                                      provider.unreadCount.toString(),
                                    ),
                                    isLabelVisible: provider.unreadCount > 0,
                                    child: const Icon(
                                      Iconsax.notification,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location Display Row
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationFetchScreen(),
                          ),
                        ).then(
                          (_) => _loadLocation(),
                        ); // Refresh location after returning
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Iconsax.location,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationText,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 5,
                        itemBuilder:
                            (context, index) => const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: Column(
                                children: [
                                  CircularShimmer(size: 50),
                                  SizedBox(height: 8),
                                  TextShimmer(width: 50, height: 10),
                                ],
                              ),
                            ),
                      );
                    }

                    if (provider.categoriesError != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => provider.fetchCategories(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.categories.isEmpty) {
                      return const Center(
                        child: EmptyStateWidget(
                          icon: Iconsax.category,
                          title: 'No categories',
                          subtitle: 'We couldn\'t find any categories.',
                          iconSize: 40,
                        ),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.categories.length,
                      itemBuilder: (context, index) {
                        final category = provider.categories[index];
                        print(category);
                        // Determine color based on category name for consistent branding
                        Color color = AppColors.primary;
                        final name = category.name.toLowerCase();
                        if (name.contains('clean')) {
                          color = Colors.blue;
                        } else if (name.contains('paint')) {
                          color = Colors.green;
                        } else if (name.contains('plumb')) {
                          color = Colors.cyan;
                        } else if (name.contains('electric')) {
                          color = Colors.yellow.shade700;
                        } else if (name.contains('repair')) {
                          color = Colors.orange;
                        } else if (name.contains('salon')) {
                          color = Colors.pink;
                        } else if (name.contains('carpenter')) {
                          color = Colors.brown;
                        } else if (name.contains('cook')) {
                          color = Colors.red;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SizedBox(
                            width: 70,
                            child: CategoryItem(
                              name: category.name,
                              image: category.image,
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
                      return StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: List.generate(
                          4,
                          (index) => StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: (index % 3 == 0) ? 2 : 1,
                            child: const CardShimmer(borderRadius: 16),
                          ),
                        ),
                      );
                    }

                    if (provider.feedsError != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 40),
                              const SizedBox(height: 12),
                              Text(provider.feedsError!),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => provider.fetchFeeds(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (provider.feeds.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: EmptyStateWidget(
                          icon: Iconsax.gallery,
                          title: 'No Highlights Yet',
                          subtitle:
                              'Our experts haven\'t shared any service highlights recently.',
                          iconSize: 50,
                        ),
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
