import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/models/booking_model.dart';
import '../../home/screens/customer_booking_details_screen.dart';

import 'package:provider/provider.dart';
import '../../home/providers/consumer_provider.dart';
import '../../../core/widgets/empty_state_widget.dart';

class BookingTabScreen extends StatefulWidget {
  const BookingTabScreen({super.key});

  @override
  State<BookingTabScreen> createState() => _BookingTabScreenState();
}

class _BookingTabScreenState extends State<BookingTabScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<ConsumerProvider>(
            context,
            listen: false,
          ).fetchMyBookings(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Consumer<ConsumerProvider>(
          builder: (context, provider, child) {
            return Text(
              'My Bookings (${provider.bookings.length})',
              style: AppTextStyles.h4,
            );
          },
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SearchTextField(
                hint: 'Search by ID, Service, or Provider',
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                onFilterTap: () {},
              ),
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
              child: Consumer<ConsumerProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingBookings) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.bookingsError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading bookings',
                            style: AppTextStyles.h4,
                          ),
                          Text(
                            provider.bookingsError!,
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.fetchMyBookings(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredBookings =
                      provider.bookings.where((booking) {
                        final id = booking.bookingId.toLowerCase();
                        final service = booking.serviceName.toLowerCase();
                        final providerName =
                            (booking.providerName ?? '').toLowerCase();
                        return id.contains(_searchQuery) ||
                            service.contains(_searchQuery) ||
                            providerName.contains(_searchQuery);
                      }).toList();

                  if (filteredBookings.isEmpty) {
                    return EmptyStateWidget(
                      icon:
                          _searchQuery.isEmpty
                              ? Iconsax.calendar_remove
                              : Iconsax.search_status,
                      title:
                          _searchQuery.isEmpty
                              ? 'No Bookings Yet'
                              : 'No Match Found',
                      subtitle:
                          _searchQuery.isEmpty
                              ? 'You haven\'t made any bookings yet. Start exploring our services!'
                              : 'We couldn\'t find any bookings matching "$_searchQuery".',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredBookings.length + 1, // +1 for FAB space
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == filteredBookings.length) {
                        return const SizedBox(height: 80);
                      }

                      final booking = filteredBookings[index];
                      // Map status to color
                      Color statusColor = AppColors.primary;
                      if (booking.status == BookingStatus.pending) {
                        statusColor = AppColors.warning;
                      } else if (booking.status == BookingStatus.ongoing) {
                        statusColor = AppColors.primary;
                      } else if (booking.status == BookingStatus.completed) {
                        statusColor = AppColors.success;
                      } else if (booking.status == BookingStatus.cancelled) {
                        statusColor = Colors.red;
                      }

                      return _BookingCard(
                        booking: booking,
                        id: booking.id,
                        bookingId: '#${booking.bookingId}',
                        serviceName: booking.serviceName,
                        price: booking.price,
                        discount: 0,
                        status:
                            booking.status.name[0].toUpperCase() +
                            booking.status.name.substring(1),
                        statusColor: statusColor,
                        paymentMode: booking.paymentMode,
                        date: booking.date,
                        time: booking.time,
                        location: booking.location,
                        bookingStatus: booking.status.name,
                        providerName:
                            booking.providerName ?? 'Unassigned', // Safe access
                        rating: 0.0,
                        totalAmount: booking.totalAmount,
                      );
                    },
                  );
                },
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
  final String paymentMode;
  final String date;
  final String time;
  final String location;
  final String bookingStatus;
  final String providerName;
  final double rating;

  final String id; // Backend ID
  final BookingModel booking;
  final double totalAmount;

  const _BookingCard({
    required this.booking,
    required this.id, // Add this
    required this.bookingId,
    required this.serviceName,
    required this.price,
    required this.discount,
    required this.status,
    required this.statusColor,
    required this.paymentMode,
    required this.date,
    required this.time,
    required this.location,
    required this.bookingStatus,
    required this.providerName,
    required this.rating,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => CustomerBookingDetailsScreen(booking: booking),
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
                if (booking.status == BookingStatus.completed)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Mode', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          ' $paymentMode',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Total Amount', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          ' $totalAmount',
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
                Text('Status', style: AppTextStyles.caption),
                const SizedBox(width: 8),
                Text(
                  bookingStatus,
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
                Row(
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
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // const Spacer(),
                // const Icon(Icons.star, color: Color(0xFFFFA928), size: 16),
                // const SizedBox(width: 4),
                // Text(
                //   rating.toString(),
                //   style: AppTextStyles.bodySmall.copyWith(
                //     fontWeight: FontWeight.w600,
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
