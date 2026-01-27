import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/service_package_card.dart';
import '../../../core/widgets/featured_service_card.dart';
import '../../../core/widgets/expert_service_card.dart';
import 'service_provider_detail_screen.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/dummy_data_service.dart';
import 'dart:async';

import '../widgets/location_selector_bottom_sheet.dart';
import '../../cart/screens/cart_screen.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  String _selectedLocation = 'Mesa, New Jersey - 45463';
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> _offers = [
    {
      'title': '50% OFF IN CLEANING',
      'subtitle': '#On first 50 booking',
      'tag': 'NEW OFFER',
      'color': AppColors.error,
      'image': 'assets/images/cleaning_service.png',
    },
    {
      'title': '30% OFF IN REPAIR',
      'subtitle': '#Special weekend deal',
      'tag': 'LIMITED',
      'color': Colors.orange,
      'image': 'assets/images/ac_repair_service.png',
    },
    {
      'title': 'FREE INSPECTION',
      'subtitle': '#For new users only',
      'tag': 'WELCOME',
      'color': AppColors.primary,
      'image': 'assets/images/smart_home_install.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _offers.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => LocationSelectorBottomSheet(
            onLocationSelected: (location) {
              setState(() {
                _selectedLocation = location;
              });
            },
          ),
    );
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
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.background,
                          backgroundImage: AssetImage(
                            'assets/images/man_profile.jpg',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const Text(
                                'Amjad',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Iconsax.search_normal_1,
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
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showLocationSelector,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Iconsax.location,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current location',
                                    style: AppTextStyles.caption,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedLocation,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: AppColors.textPrimary,
                                      ),
                                    ],
                                  ),
                                ],
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

            // Promotional Banner Carousel
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _offers.length,
                      itemBuilder: (context, index) {
                        final offer = _offers[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: offer['color'],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        offer['tag'],
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      offer['title'],
                                      style: AppTextStyles.h3.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      offer['subtitle'],
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('book now'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    offer['image'],
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        _offers.asMap().entries.map((entry) {
                          return Container(
                            width: _currentPage == entry.key ? 20.0 : 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  _currentPage == entry.key
                                      ? AppColors.primary
                                      : AppColors.textTertiary.withOpacity(0.3),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Service Packages Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Service packages', style: AppTextStyles.h4),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View all',
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
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    SizedBox(
                      width: 160,
                      child: ServicePackageCard(
                        title: 'Cleaning package',
                        price: 20.05,
                        gradient: AppColors.primaryGradient,
                        icon: Icons.cleaning_services,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: ServicePackageCard(
                        title: 'Repair package',
                        price: 15.52,
                        gradient: AppColors.orangeGradient,
                        icon: Icons.build,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: ServicePackageCard(
                        title: 'Repair package',
                        price: 15.52,
                        gradient: AppColors.cyanGradient,
                        icon: Icons.handyman,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Featured Service Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Featured service', style: AppTextStyles.h4),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View all',
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

            // Featured Services Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 400,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children:
                      DummyDataService.instance
                          .getProvidersByCategory('Cleaning')
                          .take(3)
                          .map(
                            (provider) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 280,
                                child: FeaturedServiceCard(
                                  providerName: provider.name,
                                  providerImage: provider.serviceImage,
                                  rating: provider.rating,
                                  serviceImage:
                                      provider.portfolioImages.isNotEmpty
                                          ? provider.portfolioImages.first
                                          : 'assets/images/plumber.png',
                                  serviceName: '${provider.profession} Special',
                                  originalPrice: 120.0,
                                  discountedPrice: 90.0,
                                  discountPercent: 25,
                                  duration: '4-5 Hours',
                                  servicemenRequired: '2 Servicemen',
                                  description: provider.bio,
                                  onTap:
                                      () => _navigateToProviderDetail(provider),
                                  onAddTap: () {},
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Expert Services Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Expert Service by rating', style: AppTextStyles.h4),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View all',
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

            // Expert Services Vertical List (sorted by rating)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final providers = DummyDataService.instance
                        .getProvidersByRating(limit: 5);
                    if (index >= providers.length) return null;

                    final provider = providers[index];
                    return ExpertServiceCard(
                      name: provider.name,
                      profileImage: provider.serviceImage,
                      serviceType: '${provider.profession} service',
                      location: provider.location,
                      rating: provider.rating,
                      onTap: () => _navigateToProviderDetail(provider),
                    );
                  },
                  childCount:
                      DummyDataService.instance
                          .getProvidersByRating(limit: 5)
                          .length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ), // Space for FAB
          ],
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
