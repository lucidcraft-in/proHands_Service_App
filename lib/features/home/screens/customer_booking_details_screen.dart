import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/full_screen_image.dart';
import '../providers/consumer_provider.dart';

class CustomerBookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const CustomerBookingDetailsScreen({super.key, required this.booking});

  @override
  State<CustomerBookingDetailsScreen> createState() =>
      _CustomerBookingDetailsScreenState();
}

class _CustomerBookingDetailsScreenState
    extends State<CustomerBookingDetailsScreen> {
  final _commentController = TextEditingController();
  double _rating = 0;
  final List<File> _images = [];
  final _picker = ImagePicker();
  bool _reviewSubmitted = false;
  late BookingModel _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerProvider>().fetchBookingLogs(_currentBooking.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    final provider = context.read<ConsumerProvider>();
    final success = await provider.submitReview(
      bookingId: _currentBooking.id,
      rating: _rating,
      comment: _commentController.text,
      imagePaths: _images.map((file) => file.path).toList(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {
        _reviewSubmitted = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.reviewError ?? 'Failed to submit review'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Current Booking Status: ${_currentBooking.status}");
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Booking Details', style: AppTextStyles.h4),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Timeline
            _buildTimeline(_currentBooking.status),
            const SizedBox(height: 24),

            // Delay Request Section
            if (_currentBooking.status == BookingStatus.delayRequested)
              _buildDelaySection(),

            if (_currentBooking.status == BookingStatus.delayRequested)
              const SizedBox(height: 24),

            // Reassign Options
            if (_currentBooking.status == BookingStatus.reassignRequested)
              _buildReassignSection(),

            if (_currentBooking.status == BookingStatus.reassignRequested)
              const SizedBox(height: 24),

            // Service Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking ID',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _currentBooking.bookingId,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(_currentBooking.serviceName, style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    _currentBooking.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Iconsax.calendar, _currentBooking.date),
                  const SizedBox(height: 8),
                  _buildDetailRow(Iconsax.clock, _currentBooking.time),
                  const SizedBox(height: 8),
                  _buildDetailRow(Iconsax.location, _currentBooking.location),
                  const Divider(height: 24),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('Total Amount', style: AppTextStyles.h4),
                  //     Text(
                  //       '₹${_currentBooking.price.toStringAsFixed(0)}',
                  //       style: AppTextStyles.h4.copyWith(
                  //         color: AppColors.primary,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Provider Details (if assigned)
            if (_currentBooking.providerName != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service Provider', style: AppTextStyles.h4),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentBooking.providerName!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_currentBooking.providerProfession != null)
                              Text(
                                _currentBooking.providerProfession!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // if (_currentBooking.providerPhone != null &&
                    //     _currentBooking.status == BookingStatus.reached)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 16),
                    //     child: ElevatedButton.icon(
                    //       onPressed: () {
                    //         // Call functionality
                    //       },
                    //       icon: const Icon(Icons.call),
                    //       label: const Text('Call Provider'),
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: Colors.green,
                    //         foregroundColor: Colors.white,
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),

            if (_currentBooking.status == BookingStatus.completed)
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Details', style: AppTextStyles.h4),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Mode',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _currentBooking.paymentMode,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₹${_currentBooking.totalAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (_currentBooking.status == BookingStatus.completed) ...[
              const SizedBox(height: 24),
              Text('Job Proof Photos', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              _currentBooking.jobProofImages.isEmpty
                  ? _buildEmptyPhotoPlaceholder('No proof photos available')
                  : _buildNetworkImageGallery(_currentBooking.jobProofImages),
            ],

            // Review Section
            if (_currentBooking.status == BookingStatus.completed &&
                !_reviewSubmitted)
              _buildReviewSection(),

            const SizedBox(height: 24),
            _buildLogsTimeline(),

            // Cancel Booking Section
            if (_currentBooking.status != BookingStatus.completed &&
                _currentBooking.status != BookingStatus.cancelled)
              Column(
                children: [
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Cancel Booking',
                    onPressed: _showCancelDialog,
                    textColor: AppColors.error,
                    isOutlined: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsTimeline() {
    return Consumer<ConsumerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBookingLogs) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.bookingLogs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Timeline', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.bookingLogs.length,
              itemBuilder: (context, index) {
                final log = provider.bookingLogs[index];
                final isLast = index == provider.bookingLogs.length - 1;

                DateTime? dateTime;
                try {
                  dateTime = DateTime.parse(log.createdAt).toLocal();
                  ;
                } catch (_) {}

                final dateStr =
                    dateTime != null
                        ? "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}"
                        : log.createdAt;

                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: AppColors.border,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.notes,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  dateStr,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  "  created by ${log.createdByName}",
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancel Booking', style: AppTextStyles.h4),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please provide a reason for cancellation.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hint: 'Reason (e.g., No longer need service)',
                  controller: reasonController,
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Go Back',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Consumer<ConsumerProvider>(
                builder: (context, provider, child) {
                  return TextButton(
                    onPressed:
                        provider.isRequestingCancellation
                            ? null
                            : () =>
                                _cancelBooking(reasonController.text.trim()),
                    child: Text(
                      provider.isRequestingCancellation
                          ? 'Resquesting...'
                          : 'Cancel Task',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }

  Future<void> _cancelBooking(String reason) async {
    if (reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please provide a reason')));
      return;
    }

    final provider = context.read<ConsumerProvider>();
    final success = await provider.cancelBookingRequest(
      bookingId: _currentBooking.id,
      reason: reason,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cancellation request sent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back to bookings list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.cancellationError ?? 'Failed to request cancellation',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildReviewSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate your experience', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hint: 'Share your feedback...',
            controller: _commentController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text('Add Photos (Optional)', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ..._images.map(
                  (file) => Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _images.remove(file);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Consumer<ConsumerProvider>(
            builder: (context, provider, child) {
              return CustomButton(
                text: 'Submit Review',
                isLoading: provider.isSubmittingReview,
                onPressed: provider.isSubmittingReview ? null : _submitReview,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPhotoPlaceholder(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Iconsax.image, color: AppColors.textTertiary, size: 32),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildNetworkImageGallery(List<String> images) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => FullScreenImage(
                          imageUrl: images[index],
                          isNetworkImage: true,
                        ),
                  ),
                );
              },
              child: Hero(
                tag: images[index],
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Center(
                          child: Icon(Iconsax.image, color: AppColors.error),
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDelaySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.clock, color: AppColors.warning),
              const SizedBox(width: 12),
              Text(
                'Delay Requested',
                style: AppTextStyles.h4.copyWith(color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'The technician has requested to delay this service.',
            style: AppTextStyles.bodyMedium,
          ),
          if (_currentBooking.delayTime != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Proposed Time: ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentBooking.delayTime!,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
          if (_currentBooking.delayNote != null &&
              _currentBooking.delayNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason: ',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    _currentBooking.delayNote!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Consumer<ConsumerProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Reject',
                      onPressed:
                          provider.isHandlingDelay
                              ? null
                              : () => _handleDelay('REJECT'),
                      backgroundColor: AppColors.error,
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Accept',
                      onPressed:
                          provider.isHandlingDelay
                              ? null
                              : () => _handleDelay('ACCEPT'),
                      isLoading: provider.isHandlingDelay,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelay(String action) async {
    final provider = context.read<ConsumerProvider>();
    final success = await provider.handleDelayRequest(
      bookingId: _currentBooking.id,
      action: action,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delay request $action'
            'ED successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      // Fetch fresh booking details to update UI
      final updatedBooking = await provider.fetchBookingDetails(
        _currentBooking.id,
      );
      if (updatedBooking != null && mounted) {
        setState(() {
          _currentBooking = updatedBooking;
        });
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.delayHandleError ?? 'Failed to handle delay request',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReassignSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reassignment Required',
            style: AppTextStyles.h4.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'The provider has requested a reassignment. Please choose how you would like to proceed.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          _buildReassignOption(
            title: 'Let Admin Choose',
            subtitle: 'We will assign the best available professional for you.',
            icon: Iconsax.user_tick,
            onTap: () => _handleReassignChoice('ADMIN_CHOOSE'),
          ),
          const SizedBox(height: 12),
          _buildReassignOption(
            title: 'Choose Another Service',
            subtitle: 'Pick a different service that fits your needs.',
            icon: Iconsax.search_status,
            onTap: () => _showServicePicker(),
          ),
          const SizedBox(height: 12),
          _buildReassignOption(
            title: 'I Will Wait',
            subtitle: 'Keep the current booking and wait for updates.',
            icon: Iconsax.clock,
            onTap: () => _handleReassignChoice('WAIT'),
          ),
          const SizedBox(height: 12),
          _buildReassignOption(
            title: 'Cancel Booking',
            subtitle: 'If you no longer need the service.',
            icon: Iconsax.close_circle,
            color: AppColors.error,
            onTap: () => _handleReassignChoice('CANCELLED'),
          ),
        ],
      ),
    );
  }

  Widget _buildReassignOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleReassignChoice(
    String choice, {
    String? newServiceId,
  }) async {
    final provider = context.read<ConsumerProvider>();
    final success = await provider.submitReassignChoice(
      bookingId: _currentBooking.id,
      choice: choice,
      newServiceId: choice == 'CHOOSE_ANOTHER_SERVICE' ? newServiceId : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choice submitted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload booking details and logs after success
        _reloadBookingDetails();
        provider.fetchBookingLogs(_currentBooking.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.reassignChoiceError ?? 'Failed to submit choice',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _reloadBookingDetails() async {
    final provider = context.read<ConsumerProvider>();
    final updatedBooking = await provider.fetchBookingDetails(
      _currentBooking.id,
    );
    if (updatedBooking != null && mounted) {
      setState(() {
        _currentBooking = updatedBooking;
      });
    }
  }

  void _showServicePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _ServicePickerSheet(
            categoryId: _currentBooking.categoryId ?? '',
            onServiceSelected: (serviceId) {
              Navigator.pop(context);
              _handleReassignChoice(
                'CHOOSE_ANOTHER_SERVICE',
                newServiceId: serviceId,
              );
            },
          ),
    );
  }

  Widget _buildTimeline(BookingStatus currentStatus) {
    final steps = [
      {'status': BookingStatus.assigned, 'label': 'Assigned'},
      {'status': BookingStatus.reached, 'label': 'Accepted'},
      {'status': BookingStatus.completed, 'label': 'Completed'},
    ];

    if (currentStatus == BookingStatus.cancelled) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red),
          ),
          child: const Text(
            'Booking Cancelled',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    int currentStepIndex = 0;
    if (currentStatus == BookingStatus.reached) currentStepIndex = 1;
    if (currentStatus == BookingStatus.completed) currentStepIndex = 2;

    return Stack(
      children: [
        // Connector Lines
        Padding(
          padding: const EdgeInsets.only(top: 15), // Half of dot height
          child: Row(
            children: [
              const Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: Container(
                  height: 2,
                  color:
                      currentStepIndex >= 1
                          ? AppColors.primary
                          : Colors.grey.shade300,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 2,
                  color:
                      currentStepIndex >= 2
                          ? AppColors.primary
                          : Colors.grey.shade300,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
        // Dots and Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isActive = index <= currentStepIndex;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color:
                            isActive ? AppColors.primary : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isActive ? Icons.check : Icons.circle,
                      size: 16,
                      color: isActive ? Colors.white : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    steps[index]['label'] as String,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color:
                          isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ServicePickerSheet extends StatefulWidget {
  final Function(String) onServiceSelected;
  final String categoryId;

  const _ServicePickerSheet({
    required this.onServiceSelected,
    required this.categoryId,
  });

  @override
  State<_ServicePickerSheet> createState() => _ServicePickerSheetState();
}

class _ServicePickerSheetState extends State<_ServicePickerSheet> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConsumerProvider>();
      provider.fetchCategories();
      setState(() {
        _selectedCategoryId =
            widget.categoryId.isEmpty ? null : widget.categoryId;
      });
      if (_selectedCategoryId != null) {
        provider.fetchServicesByCategory(_selectedCategoryId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _selectedCategoryId == null ? 'Select Category' : 'Select Service',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<ConsumerProvider>(
              builder: (context, provider, child) {
                if (_selectedCategoryId == null) {
                  if (provider.isLoadingCategories) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.categoriesError != null) {
                    return Center(child: Text(provider.categoriesError!));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final category = provider.categories[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Iconsax.category,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: AppTextStyles.bodyLarge,
                        ),
                        trailing: const Icon(Iconsax.arrow_right_3, size: 16),
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                          });
                          provider.fetchServicesByCategory(category.id);
                        },
                      );
                    },
                  );
                } else {
                  if (provider.isLoadingServices) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.servicesError != null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.servicesError!),
                        TextButton(
                          onPressed:
                              () => setState(() => _selectedCategoryId = null),
                          child: const Text('Back to Categories'),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed:
                                  () => setState(
                                    () => _selectedCategoryId = null,
                                  ),
                            ),
                            const Text('Service List'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: provider.services.length,
                          itemBuilder: (context, index) {
                            final service = provider.services[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ListTile(
                                title: Text(
                                  service.name,
                                  style: AppTextStyles.bodyLarge,
                                ),
                                // subtitle: Text(
                                //   '₹${service.price}',
                                //   style: AppTextStyles.bodySmall,
                                // ),
                                trailing: const Icon(
                                  Iconsax.add_circle,
                                  color: AppColors.primary,
                                ),
                                onTap:
                                    () => widget.onServiceSelected(service.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
