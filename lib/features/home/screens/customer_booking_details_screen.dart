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
      bookingId: widget.booking.id,
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
    print(widget.booking.status);
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
            _buildTimeline(widget.booking.status),
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
                        widget.booking.bookingId,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(widget.booking.serviceName, style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text(
                    widget.booking.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Iconsax.calendar, widget.booking.date),
                  const SizedBox(height: 8),
                  _buildDetailRow(Iconsax.clock, widget.booking.time),
                  const SizedBox(height: 8),
                  _buildDetailRow(Iconsax.location, widget.booking.location),
                  const Divider(height: 24),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text('Total Amount', style: AppTextStyles.h4),
                  //     Text(
                  //       '₹${widget.booking.price.toStringAsFixed(0)}',
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
            if (widget.booking.providerName != null)
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
                              widget.booking.providerName!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.booking.providerProfession != null)
                              Text(
                                widget.booking.providerProfession!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (widget.booking.providerPhone != null &&
                        widget.booking.status == BookingStatus.ongoing)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Call functionality
                          },
                          icon: const Icon(Icons.call),
                          label: const Text('Call Provider'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            if (widget.booking.status == BookingStatus.completed)
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
                          widget.booking.paymentMode,
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
                          '₹${widget.booking.totalAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (widget.booking.status == BookingStatus.completed) ...[
              const SizedBox(height: 24),
              Text('Job Proof Photos', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              widget.booking.jobProofImages.isEmpty
                  ? _buildEmptyPhotoPlaceholder('No proof photos available')
                  : _buildNetworkImageGallery(widget.booking.jobProofImages),
            ],

            // Review Section
            if (widget.booking.status == BookingStatus.completed &&
                !_reviewSubmitted)
              _buildReviewSection(),

            // Cancel Booking Section
            if (widget.booking.status != BookingStatus.completed &&
                widget.booking.status != BookingStatus.cancelled)
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
      bookingId: widget.booking.id,
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

  Widget _buildTimeline(BookingStatus currentStatus) {
    final steps = [
      {'status': BookingStatus.pending, 'label': 'Pending'},
      {'status': BookingStatus.ongoing, 'label': 'Accepted'},
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
    if (currentStatus == BookingStatus.ongoing) currentStepIndex = 1;
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
