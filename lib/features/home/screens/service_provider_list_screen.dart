import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/dummy_data_service.dart';
import 'service_provider_detail_screen.dart';

class ServiceProviderListScreen extends StatelessWidget {
  final String category;

  const ServiceProviderListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final providers = DummyDataService.instance.getProvidersByCategory(
      category,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          category,
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle:
            false, // Navigate to details usually back button is there, title next to it.
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Iconsax.search_normal,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilters(),
                const SizedBox(height: 12),
                _buildLocationHeader(),
              ],
            ),
          ),
          Expanded(
            child:
                providers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        return _buildProviderCard(context, provider);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.user_search,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No experts found for this category',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Filter',
            icon: Iconsax.setting_4,
            isSelected: true,
            showCount: false,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Profession',
            isSelected: true,
            count: 1,
            showCount: true,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Sort', isSelected: false),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'City', isSelected: false),
          const SizedBox(width: 8),
          _buildFilterChip(label: 'Reviewed', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    bool isSelected = false,
    bool showCount = false,
    int count = 0,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCount) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          if (icon == null && !showCount) ...[
            // Placeholder for spacing consistency if needed
          ],
          if (label == 'Filter') ...[
            const SizedBox(width: 4),
            const Icon(Icons.tune, size: 14, color: AppColors.primary),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Iconsax.location, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(
            'Kannur',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, UserModel provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ServiceProviderDetailScreen(provider: provider),
            ),
          );
        },
        child: Column(
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.background,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      provider.serviceImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.profession,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Contact Action
                  },
                  icon: const Icon(Icons.call, size: 16, color: Colors.white),
                  label: const Text(
                    'Contact',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    iconColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Portfolio Images
            if (provider.portfolioImages.isNotEmpty)
              SizedBox(
                height: 120, // Adjust height as per image aspect ratio
                child: Row(
                  children:
                      provider.portfolioImages.take(3).map((imagePath) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // Footer Stats
            Row(
              children: [
                _buildStatChip(
                  Icons.star,
                  '${provider.rating}',
                  const Color(0xFFFFA928),
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  Iconsax.message,
                  '${provider.reviewsCount} Reviews',
                  AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
