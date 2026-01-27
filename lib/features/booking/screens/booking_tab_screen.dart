import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'booking_detail_screen.dart';
import '../../chat/screens/chat_screen.dart';

class BookingTabScreen extends StatelessWidget {
  const BookingTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My cart (3)', style: AppTextStyles.h4),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SearchTextField(hint: 'Search here', onFilterTap: () {}),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('All booking', style: AppTextStyles.h4),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _BookingCard(
                    bookingId: '#58961',
                    serviceName: 'Curtain cleaning',
                    price: 26.0,
                    discount: 10,
                    status: 'Pending',
                    statusColor: AppColors.warning,
                    servicemenCount: 1,
                    date: '22 Feb, 2024',
                    time: '10:28 AM',
                    location: 'California-USA',
                    paymentStatus: 'Paid in advance',
                    providerName: 'Arlene McCoy',
                    rating: 3.5,
                  ),
                  const SizedBox(height: 16),
                  _BookingCard(
                    bookingId: '#25636',
                    serviceName: 'House hold cook',
                    price: 31.0,
                    discount: 10,
                    status: 'Completed',
                    statusColor: AppColors.success,
                    servicemenCount: 1,
                    date: '15 Jan, 2024',
                    time: '02:30 PM',
                    location: 'New York-USA',
                    paymentStatus: 'Paid',
                    providerName: 'John Doe',
                    rating: 4.5,
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String bookingId;
  final String serviceName;
  final double price;
  final int discount;
  final String status;
  final Color statusColor;
  final int servicemenCount;
  final String date;
  final String time;
  final String location;
  final String paymentStatus;
  final String providerName;
  final double rating;

  const _BookingCard({
    required this.bookingId,
    required this.serviceName,
    required this.price,
    required this.discount,
    required this.status,
    required this.statusColor,
    required this.servicemenCount,
    required this.date,
    required this.time,
    required this.location,
    required this.paymentStatus,
    required this.providerName,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => BookingDetailScreen(
                  bookingId: bookingId,
                  serviceName: serviceName,
                  status: status,
                ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bookingId,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\$$price',
                            style: AppTextStyles.priceMedium.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (discount > 0)
                            Text(
                              '($discount%)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select serviceman', style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        '$servicemenCount servicemen',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Iconsax.calendar,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text('$date - $time', style: AppTextStyles.bodySmall),
                const SizedBox(width: 16),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Iconsax.location,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(location, style: AppTextStyles.bodySmall),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Text('Payment', style: AppTextStyles.caption),
                const SizedBox(width: 8),
                Text(
                  paymentStatus,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                // Tappable profile section to open chat
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ChatScreen(
                              currentUserId: 'current_user',
                              currentUserName: 'You',
                              otherUserId: 'provider_$bookingId',
                              otherUserName: providerName,
                              otherUserImage: '',
                            ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Provider', style: AppTextStyles.caption),
                          Row(
                            children: [
                              Text(
                                providerName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Iconsax.message,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star, color: Color(0xFFFFA928), size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
