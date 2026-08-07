import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/models/booking_model.dart';
import '../../home/screens/customer_booking_details_screen.dart';

import 'package:provider/provider.dart';
import '../../home/providers/consumer_provider.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';
import 'customer_quotations_list_screen.dart';

class BookingTabScreen extends StatefulWidget {
  final int initialTabIndex;
  const BookingTabScreen({super.key, this.initialTabIndex = 0});

  @override
  State<BookingTabScreen> createState() => _BookingTabScreenState();
}

class _BookingTabScreenState extends State<BookingTabScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('My Orders', style: AppTextStyles.h4),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.labelLarge,
            tabs: const [
              Tab(text: 'Bookings'),
              Tab(text: 'Quotations'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BookingsTabBody(),
            CustomerQuotationsListScreen(),
          ],
        ),
      ),
    );
  }
}

class BookingsTabBody extends StatefulWidget {
  const BookingsTabBody({super.key});

  @override
  State<BookingsTabBody> createState() => _BookingsTabBodyState();
}

class _BookingsTabBodyState extends State<BookingsTabBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  BookingStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;
  bool _isAscending = false;

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
    return SafeArea(
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
                onFilterTap: _showFilterBottomSheet,
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
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 5,
                      itemBuilder: (context, index) => const ListCardShimmer(),
                    );
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
                        // Search query
                        final id = booking.bookingId.toLowerCase();
                        final service = booking.serviceName.toLowerCase();
                        final providerName =
                            (booking.providerName ?? '').toLowerCase();
                        bool matchesSearch =
                            id.contains(_searchQuery) ||
                            service.contains(_searchQuery) ||
                            providerName.contains(_searchQuery);

                        if (!matchesSearch) return false;

                        // Status filter
                        if (_selectedStatus != null &&
                            booking.status != _selectedStatus) {
                          return false;
                        }

                        // Date range filter
                        if (_selectedDateRange != null) {
                          try {
                            final bookingDate = DateTime.parse(booking.date);
                            // Set time to midnight for comparison
                            final start = DateTime(
                              _selectedDateRange!.start.year,
                              _selectedDateRange!.start.month,
                              _selectedDateRange!.start.day,
                            );
                            final end = DateTime(
                              _selectedDateRange!.end.year,
                              _selectedDateRange!.end.month,
                              _selectedDateRange!.end.day,
                              23,
                              59,
                              59,
                            );

                            if (bookingDate.isBefore(start) ||
                                bookingDate.isAfter(end)) {
                              return false;
                            }
                          } catch (e) {
                            return true; // If parsing fails, don't filter it out
                          }
                        }

                        return true;
                      }).toList();

                  // Sorting
                  filteredBookings.sort((a, b) {
                    try {
                      final dateA = DateTime.parse(a.date);
                      final dateB = DateTime.parse(b.date);
                      return _isAscending
                          ? dateA.compareTo(dateB)
                          : dateB.compareTo(dateA);
                    } catch (e) {
                      return 0;
                    }
                  });

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
                      Color statusColor = const Color.fromARGB(255, 47, 55, 83);
                      if (booking.status == BookingStatus.assigned) {
                        statusColor = AppColors.warning;
                      } else if (booking.status == BookingStatus.reached) {
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
                        status: booking.status.getDisplayStatus(false),
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
      );
    }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BookingFilterBottomSheet(
            selectedStatus: _selectedStatus,
            selectedDateRange: _selectedDateRange,
            isAscending: _isAscending,
            onApply: (status, dateRange, ascending) {
              setState(() {
                _selectedStatus = status;
                _selectedDateRange = dateRange;
                _isAscending = ascending;
              });
            },
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
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
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                      // Text('Status', style: AppTextStyles.caption),
                      // const SizedBox(height: 4),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Iconsax.location,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location, 
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Row(
            //   children: [
            //     Text('Status', style: AppTextStyles.caption),
            //     const SizedBox(width: 8),
            //     Text(
            //       bookingStatus,
            //       style: AppTextStyles.bodySmall.copyWith(
            //         color: AppColors.success,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ],
            // ),
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

class BookingFilterBottomSheet extends StatefulWidget {
  final BookingStatus? selectedStatus;
  final DateTimeRange? selectedDateRange;
  final bool isAscending;
  final Function(BookingStatus?, DateTimeRange?, bool) onApply;

  const BookingFilterBottomSheet({
    super.key,
    this.selectedStatus,
    this.selectedDateRange,
    required this.isAscending,
    required this.onApply,
  });

  @override
  State<BookingFilterBottomSheet> createState() =>
      _BookingFilterBottomSheetState();
}

class _BookingFilterBottomSheetState extends State<BookingFilterBottomSheet> {
  BookingStatus? _tempStatus;
  DateTimeRange? _tempDateRange;
  late bool _tempAscending;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.selectedStatus;
    _tempDateRange = widget.selectedDateRange;
    _tempAscending = widget.isAscending;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _tempDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _tempDateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Bookings', style: AppTextStyles.h4),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempStatus = null;
                    _tempDateRange = null;
                    _tempAscending = false;
                  });
                },
                child: Text(
                  'Reset',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Status Filter
          Text('Status', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(null, 'All'),
                ...BookingStatus.values.map(
                  (status) => _buildStatusChip(
                    status,
                    status.getDisplayStatus(false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Date Range Filter
          Text('Date Range', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.calendar, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    _tempDateRange == null
                        ? 'Select Date Range'
                        : '${DateFormat('dd MMM').format(_tempDateRange!.start)} - ${DateFormat('dd MMM').format(_tempDateRange!.end)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const Spacer(),
                  if (_tempDateRange != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _tempDateRange = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sort Order
          Text('Sort by Date', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSortButton(
                  'Newest First',
                  false,
                  Iconsax.sort,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSortButton(
                  'Oldest First',
                  true,
                  Iconsax.sort,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_tempStatus, _tempDateRange, _tempAscending);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus? status, String label) {
    final isSelected = _tempStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _tempStatus = selected ? status : null);
        },
        selectedColor: AppColors.primary.withOpacity(0.1),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton(String label, bool ascending, IconData icon) {
    final isSelected = _tempAscending == ascending;
    return InkWell(
      onTap: () => setState(() => _tempAscending = ascending),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
