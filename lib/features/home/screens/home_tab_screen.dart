import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:service_app/features/location/screens/location_fetch_screen.dart';
import '../providers/consumer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../models/service_product_model.dart';
import '../widgets/service_card_horizontal.dart';
import 'service_product_detail_screen.dart';
import 'location_search_screen.dart';
import 'points_reward_detail_screen.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../widgets/category_item.dart';
import '../widgets/banner_carousel.dart';
import 'full_image_screen.dart';
import 'main_screen.dart';
import 'service_product_list_screen.dart';
import 'customer_bookings_screen.dart';
import 'notification_screen.dart';
import '../providers/notification_provider.dart';
import '../../profile/screens/point_history_screen.dart';

import '../../cart/screens/cart_screen.dart';
import '../../booking/screens/create_quotation_screen.dart';

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
      context.read<ConsumerProvider>().fetchUserProfile();
      if (context.read<ConsumerProvider>().categories.isEmpty) {
        context.read<ConsumerProvider>().fetchCategories();
      }
      // if (context.read<ConsumerProvider>().feeds.isEmpty) {
      context.read<ConsumerProvider>().fetchFeeds();
      // }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with location
            SliverToBoxAdapter(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
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
                          'PreHands',
                          style: AppTextStyles.h4.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Consumer<ConsumerProvider>(
                              builder: (context, provider, child) {
                                final points =
                                    provider.currentUser?.points ?? 0;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const PointHistoryScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.amber.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.stars,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$points pts',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                color: Colors.amber.shade800,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const CreateQuotationScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6236FF),
                                      Color(0xFF8E66FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6236FF,
                                      ).withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Iconsax.document_text5,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Get Quote',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                                    child: Icon(
                                      Iconsax.notification,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    // const SizedBox(height: 8),
                    _buildPointsProgramRibbon(context),

                    // Location Display Row
                  ],
                ),
              ),
            ),

            // Service Search Box
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Consumer<ConsumerProvider>(
                  builder: (context, provider, child) {
                    return Autocomplete<ServiceProductModel>(
                      displayStringForOption: (option) => option.name,
                      optionsBuilder: (
                        TextEditingValue textEditingValue,
                      ) async {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<ServiceProductModel>.empty();
                        }
                        await provider.searchServices(textEditingValue.text);
                        ;

                        if (provider.searchResults.isEmpty) {
                          // Return a dummy item to trigger optionsViewBuilder
                          return [
                            ServiceProductModel(
                              id: 'empty',
                              name: 'No services available',
                              description: '',
                              price: 0,
                              duration: 0,
                              providerName: '',
                              providerImage: '',
                              providerId: '',
                              image: '',
                            ),
                          ];
                        }
                        return provider.searchResults;
                      },
                      onSelected: (ServiceProductModel selection) {
                        if (selection.id == 'empty') return;
                        // fetchAndNavigateToProfile(
                        //   context,
                        //   selection.providerId,
                        // );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => ServiceProductDetailScreen(
                                  service: selection,
                                ),
                          ),
                        );
                      },
                      fieldViewBuilder: (
                        context,
                        textEditingController,
                        focusNode,
                        onFieldSubmitted,
                      ) {
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Search services...',
                            prefixIcon: const Icon(Iconsax.search_normal),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 8,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              constraints: const BoxConstraints(maxHeight: 300),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  if (option.id == 'empty') {
                                    return ListTile(
                                      title: Center(
                                        child: Text(
                                          option.name,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ),
                                    );
                                  }
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        option.image.isNotEmpty
                                            ? option.image
                                            : 'https://via.placeholder.com/50',
                                      ),
                                    ),
                                    title: Text(
                                      option.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
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
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                            ),
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
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 40,
                              ),
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
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => FullImageScreen(
                                        feeds: provider.feeds,
                                        initialIndex: index,
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

            const SliverToBoxAdapter(
              child: BannerCarousel(linkType: 'redeem_points_ad'),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationSearchScreen(),
            ),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        label: const Text(
          'Explore Nearby',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontFamily: 'Inter',
          ),
        ),
        icon: const Icon(Iconsax.location, size: 20),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPointsProgramRibbon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PointsRewardDetailScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8EBFA), Color(0xFFF3F5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -10,
              top: -10,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 4),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.08,
                child: const Icon(
                  Iconsax.gift,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'PH',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'BOOK MORE ',
                                  style: AppTextStyles.h4.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'EARN MORE',
                                  style: AppTextStyles.h4.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF00C853),
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Points That Reward You',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 12),
                // Container(
                //   height: 1.5,
                //   width: double.infinity,
                //   color: Colors.black.withOpacity(0.06),
                // ),
                // const SizedBox(height: 12),
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Expanded(
                //       child: Column(
                //         children: [
                //           Container(
                //             padding: const EdgeInsets.all(6),
                //             decoration: BoxDecoration(
                //               shape: BoxShape.circle,
                //               border: Border.all(color: Colors.blue.withOpacity(0.4)),
                //             ),
                //             child: const Icon(
                //               Iconsax.user_add,
                //               size: 14,
                //               color: Colors.blue,
                //             ),
                //           ),
                //           const SizedBox(height: 4),
                //           Text(
                //             'NEW USER\nBONUS',
                //             textAlign: TextAlign.center,
                //             style: AppTextStyles.caption.copyWith(
                //               fontSize: 8,
                //               fontWeight: FontWeight.bold,
                //               color: const Color(0xFF475569),
                //             ),
                //           ),
                //           const SizedBox(height: 4),
                //           Text(
                //             '40',
                //             style: AppTextStyles.labelLarge.copyWith(
                //               fontSize: 18,
                //               fontWeight: FontWeight.w900,
                //               color: const Color(0xFF00C853),
                //             ),
                //           ),
                //           Text(
                //             'POINTS\nADDED',
                //             textAlign: TextAlign.center,
                //             style: AppTextStyles.caption.copyWith(
                //               fontSize: 7,
                //               fontWeight: FontWeight.bold,
                //               color: AppColors.textSecondary,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       width: 1,
                //       height: 80,
                //       color: Colors.black.withOpacity(0.06),
                //     ),
                //     Expanded(
                //       child: Column(
                //         children: [
                //           Container(
                //             padding: const EdgeInsets.all(6),
                //             decoration: BoxDecoration(
                //               shape: BoxShape.circle,
                //               border: Border.all(color: Colors.green.withOpacity(0.4)),
                //             ),
                //             child: const Icon(
                //               Iconsax.wallet_3,
                //               size: 14,
                //               color: Colors.green,
                //             ),
                //           ),
                //           const SizedBox(height: 4),
                //           Text(
                //             'EARN POINTS\nON BOOKINGS',
                //             textAlign: TextAlign.center,
                //             style: AppTextStyles.caption.copyWith(
                //               fontSize: 8,
                //               fontWeight: FontWeight.bold,
                //               color: const Color(0xFF475569),
                //             ),
                //           ),
                //           const SizedBox(height: 4),
                //           Text(
                //             '10',
                //             style: AppTextStyles.labelLarge.copyWith(
                //               fontSize: 18,
                //               fontWeight: FontWeight.w900,
                //               color: const Color(0xFF00C853),
                //             ),
                //           ),
                //           Text(
                //             'POINTS FOR EVERY\n₹1000 BOOKING',
                //             textAlign: TextAlign.center,
                //             style: AppTextStyles.caption.copyWith(
                //               fontSize: 7,
                //               fontWeight: FontWeight.bold,
                //               color: AppColors.textSecondary,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       width: 1,
                //       height: 80,
                //       color: Colors.black.withOpacity(0.06),
                //     ),
                //     Expanded(
                //       child: Column(
                //         children: [
                //           Container(
                //             padding: const EdgeInsets.all(6),
                //             decoration: BoxDecoration(
                //               shape: BoxShape.circle,
                //               border: Border.all(color: Colors.orange.withOpacity(0.4)),
                //             ),
                //             child: const Icon(
                //               Iconsax.award,
                //               size: 14,
                //               color: Colors.orange,
                //             ),
                //           ),
                //           const SizedBox(height: 4),
                //           Text(
                //             'TOP EARNERS\nWIN BIG',
                //             textAlign: TextAlign.center,
                //             style: AppTextStyles.caption.copyWith(
                //               fontSize: 8,
                //               fontWeight: FontWeight.bold,
                //               color: const Color(0xFF475569),
                //             ),
                //           ),
                //           const SizedBox(height: 4),
                //           const Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Icon(Iconsax.gift, size: 14, color: Color(0xFF00C853)),
                //               SizedBox(width: 2),
                //               Icon(Iconsax.global, size: 14, color: Color(0xFF00C853)),
                //             ],
                //           ),
                //           const SizedBox(height: 4),
                //           Text(
                //             'GIFTS OR\nFAMILY TRIP',
                //             textAlign: TextAlign.center,
                //             style: AppTextStyles.caption.copyWith(
                //               fontSize: 7,
                //               fontWeight: FontWeight.bold,
                //               color: AppColors.textSecondary,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 12),
                // Align(
                //   alignment: Alignment.bottomRight,
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 8,
                //       vertical: 4,
                //     ),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(6),
                //       border: Border.all(
                //         color: AppColors.primary.withOpacity(0.4),
                //         width: 1,
                //       ),
                //       color: Colors.white,
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.end,
                //       children: [
                //         Text(
                //           'BOOK | EARN | REDEEM | ENJOY |',
                //           style: AppTextStyles.caption.copyWith(
                //             fontSize: 7,
                //             fontWeight: FontWeight.bold,
                //             color: AppColors.textSecondary,
                //             letterSpacing: 0.2,
                //           ),
                //         ),
                //         Text(
                //           'MORE BOOKINGS. MORE REWARDS.',
                //           style: AppTextStyles.caption.copyWith(
                //             fontSize: 7.5,
                //             fontWeight: FontWeight.w900,
                //             color: const Color(0xFF00C853),
                //             letterSpacing: 0.2,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
