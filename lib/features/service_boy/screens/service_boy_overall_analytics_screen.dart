import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/service_boy_provider.dart';

class ServiceBoyOverallAnalyticsScreen extends StatefulWidget {
  const ServiceBoyOverallAnalyticsScreen({super.key});

  @override
  State<ServiceBoyOverallAnalyticsScreen> createState() =>
      _ServiceBoyOverallAnalyticsScreenState();
}

class _ServiceBoyOverallAnalyticsScreenState
    extends State<ServiceBoyOverallAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ServiceBoyProvider>().fetchOverallAnalytics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Overall Analytics', style: AppTextStyles.h3),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ServiceBoyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAnalytics) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.analyticsError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    provider.analyticsError!,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchOverallAnalytics(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final analytics = provider.overallAnalytics;
          if (analytics == null) {
            return const Center(child: Text('No analytics data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Section
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Bookings',
                        analytics.totalBookings.toString(),
                        Iconsax.task,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Services',
                        analytics.totalServices.toString(),
                        Iconsax.setting_2,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  'Total Revenue',
                  '₹${analytics.totalRevenue.toStringAsFixed(0)}',
                  Iconsax.wallet,
                  AppColors.success,
                  fullWidth: true,
                ),
                const SizedBox(height: 32),

                // Bookings by Category
                if (analytics.bookingsByCategory.isNotEmpty) ...[
                  Text('Bookings by Category', style: AppTextStyles.h4),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: analytics.bookingsByCategory.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = analytics.bookingsByCategory[index];
                      return _buildCategoryItem(
                        item.categoryName,
                        '${item.bookingCount} Bookings',
                        Iconsax.book,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // Services by Category
                if (analytics.servicesByCategory.isNotEmpty) ...[
                  Text('Services by Category', style: AppTextStyles.h4),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: analytics.servicesByCategory.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = analytics.servicesByCategory[index];
                      return _buildCategoryItem(
                        item.categoryName,
                        '${item.serviceCount} Services',
                        Iconsax.setting,
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String title, String subtitle, IconData icon) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // const Icon(
          //   Icons.arrow_forward_ios,
          //   size: 14,
          //   color: AppColors.textTertiary,
          // ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
