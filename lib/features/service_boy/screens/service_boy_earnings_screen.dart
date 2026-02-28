import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import '../providers/service_boy_provider.dart';

class ServiceBoyEarningsScreen extends StatefulWidget {
  const ServiceBoyEarningsScreen({super.key});

  @override
  State<ServiceBoyEarningsScreen> createState() =>
      _ServiceBoyEarningsScreenState();
}

class _ServiceBoyEarningsScreenState extends State<ServiceBoyEarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceBoyProvider>().fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Earnings', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: Consumer<ServiceBoyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBookings) {
            return const Center(child: CircularProgressIndicator());
          }

          final completedBookings = provider.completedBookings;

          // Calculate Earnings
          double totalEarnings = 0;
          double weeklyEarnings = 0;
          double monthlyEarnings = 0;

          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final startOfMonth = DateTime(now.year, now.month, 1);

          for (var booking in completedBookings) {
            final amount = booking.totalAmount;
            totalEarnings += amount;

            try {
              final bookingDate = DateTime.parse(booking.date);
              if (bookingDate.isAfter(
                startOfWeek.subtract(const Duration(seconds: 1)),
              )) {
                weeklyEarnings += amount;
              }
              if (bookingDate.isAfter(
                startOfMonth.subtract(const Duration(seconds: 1)),
              )) {
                monthlyEarnings += amount;
              }
            } catch (_) {
              // Fallback if date parsing fails
            }
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchBookings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        Text(
                          'Total Earnings',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(totalEarnings),
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildBalanceStat(
                              'Weekly',
                              currencyFormat.format(weeklyEarnings),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: AppColors.white.withOpacity(0.3),
                            ),
                            _buildBalanceStat(
                              'Monthly',
                              currencyFormat.format(monthlyEarnings),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Earnings History Section
                  Text('Earnings History', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),

                  if (completedBookings.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Iconsax.wallet_3,
                              size: 64,
                              color: AppColors.textTertiary.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No earnings yet',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completedBookings.length,
                      itemBuilder: (context, index) {
                        final booking = completedBookings[index];
                        return _buildEarningsItem(
                          booking.serviceName,
                          booking.date,
                          currencyFormat.format(booking.totalAmount),
                          'Completed',
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  // Earnings Overview Header
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
                        // Dynamic chart logic could be added here later
                        // For now, staying with simple visual representation
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
        },
      ),
    );
  }

  Widget _buildBalanceStat(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsItem(
    String service,
    String date,
    String amount,
    String status,
  ) {
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
                child: const Icon(
                  Iconsax.money_send,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service, style: AppTextStyles.labelSmall),
                  Text(date, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                ),
              ),
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
