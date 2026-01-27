import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/user_model.dart';

import '../../booking/screens/booking_checkout_screen.dart';

class ServiceProviderDetailScreen extends StatelessWidget {
  final UserModel provider;

  const ServiceProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header with Image/Avatar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.white.withOpacity(0.2),
                        child: Text(
                          provider.name[0],
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.white,
                            fontSize: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Overlay for better back button visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(provider.name, style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Text(
                            provider.profession,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA928).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFA928),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.rating.toString(),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: const Color(0xFFFFA928),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _buildStatItem(Iconsax.verify, 'Verified', 'Identity'),
                      const SizedBox(width: 12),
                      _buildStatItem(
                        Iconsax.message,
                        '${provider.reviewsCount}',
                        'Reviews',
                      ),
                      const SizedBox(width: 12),
                      _buildStatItem(Iconsax.award, '5+ Years', 'Exp.'),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Bio
                  Text('About me', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Text(
                    provider.bio,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Portfolio / Previous Work Section
                  // Portfolio Section
                  Text('Previous Work', style: AppTextStyles.h4),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _portfolioItem('assets/images/cleaning_service.png'),
                        _portfolioItem('assets/images/ac_repair_service.png'),
                        _portfolioItem('assets/images/painting_service.png'),
                        _portfolioItem('assets/images/smart_home_install.png'),
                        _portfolioItem('assets/images/garden_maintenance.png'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Specialties
                  Text('Specialties', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        provider.specialties
                            .map((s) => _buildBadge(s))
                            .toList(),
                  ),

                  const SizedBox(height: 32),

                  // Customer Reviews Section
                  _buildReviewsSection(),

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),

          // Bottom Booking Bar
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Price', style: AppTextStyles.caption),
                      Text(
                        '\$45.0/hr', // Using a fixed price as hourlyRate is not in UserModel
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookingCheckoutScreen(
                                serviceName:
                                    '${provider.profession} - ${provider.name}',
                                price:
                                    45.0, // Using a fixed price as hourlyRate is not in UserModel
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _portfolioItem(String imagePath) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customer Reviews', style: AppTextStyles.labelLarge),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildReviewItem(
          name: 'Jenny Wilson',
          rating: 5.0,
          date: '2 days ago',
          comment:
              'Outstanding service! The professional was very punctual and did a great job with the deep cleaning.',
          avatarColor: Colors.blue.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
        _buildReviewItem(
          name: 'Guy Hawkins',
          rating: 4.5,
          date: '1 week ago',
          comment:
              'Very professional and polite. Highly recommended for any household help.',
          avatarColor: Colors.orange.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required double rating,
    required String date,
    required String comment,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor,
                child: Text(
                  name[0],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(date, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFA928), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
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
}
