import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ServiceBoyEarningsScreen extends StatelessWidget {
  const ServiceBoyEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Earnings', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text('Total Balance', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.8))),
                  const SizedBox(height: 8),
                  Text('\$1,245.50', style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 32)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBalanceStat('Weekly', '\$350.00'),
                      Container(width: 1, height: 30, color: AppColors.white.withOpacity(0.3)),
                      _buildBalanceStat('Monthly', '\$1,120.00'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Payout Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payout History', style: AppTextStyles.labelLarge),
                TextButton(
                  onPressed: () {},
                  child: Text('Withdraw', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPayoutItem('Feb 22, 2024', '\$450.00', 'Completed'),
            _buildPayoutItem('Feb 15, 2024', '\$380.00', 'Completed'),
            _buildPayoutItem('Feb 08, 2024', '\$410.00', 'Completed'),
            
            const SizedBox(height: 32),
            
            // Simplified Chart (Demo)
            Text('Earnings Overview', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildChartBar(0.4),
                  _buildChartBar(0.6),
                  _buildChartBar(0.3),
                  _buildChartBar(0.8),
                  _buildChartBar(0.5),
                  _buildChartBar(0.7),
                  _buildChartBar(0.9),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceStat(String title, String value) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.8))),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.labelMedium.copyWith(color: AppColors.white)),
      ],
    );
  }

  Widget _buildPayoutItem(String date, String amount, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.arrow_down, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payout to Bank', style: AppTextStyles.labelSmall),
                  Text(date, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              Text(status, style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double percentage) {
    return Container(
      width: 20,
      height: 120 * percentage,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
