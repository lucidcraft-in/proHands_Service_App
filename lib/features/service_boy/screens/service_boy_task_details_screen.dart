import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/service_boy_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/full_screen_image.dart';

class ServiceBoyTaskDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const ServiceBoyTaskDetailsScreen({super.key, required this.booking});

  @override
  State<ServiceBoyTaskDetailsScreen> createState() =>
      _ServiceBoyTaskDetailsScreenState();
}

class _ServiceBoyTaskDetailsScreenState
    extends State<ServiceBoyTaskDetailsScreen> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  final _otpController = TextEditingController();
  final List<File> _images = [];
  final _picker = ImagePicker();
  String _paymentMode = 'CASH';
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceBoyProvider>().fetchBookingDetails(widget.booking.id);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Task Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: Consumer<ServiceBoyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBookingDetails) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.bookingDetailsError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchBookingDetails(widget.booking.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final booking = provider.selectedBooking ?? widget.booking;
          print(booking);
          Color statusColor = AppColors.primary; // Default
          switch (booking.status) {
            case BookingStatus.pending:
              statusColor = AppColors.warning;
              break;
            case BookingStatus.ongoing:
              statusColor = AppColors.primary;
              break;
            case BookingStatus.completed:
              statusColor = AppColors.success;
              break;
            case BookingStatus.cancelled:
              statusColor = AppColors.error;
              break;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.bookingId,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(booking.serviceName, style: AppTextStyles.h4),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          booking.status.name.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Work Details Section
                Text('Work Details', style: AppTextStyles.labelLarge),
                const SizedBox(height: 16),
                _buildDetailSection(
                  children: [
                    _buildDetailRow(Iconsax.calendar, 'Date', booking.date),
                    _buildDetailRow(Iconsax.clock, 'Time', booking.time),
                    _buildDetailRow(
                      Iconsax.location,
                      'Location',
                      booking.location,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Customer Details Section
                Text('Customer Details', style: AppTextStyles.labelLarge),
                const SizedBox(height: 16),
                _buildDetailSection(
                  children: [
                    _buildDetailRow(
                      Iconsax.user,
                      'Customer Name',
                      booking.customerName,
                    ),
                    _buildDetailRow(
                      Iconsax.call,
                      'Phone Number',
                      booking.customerPhone.isNotEmpty
                          ? booking.customerPhone
                          : 'Not available',
                    ),
                    _buildDetailRow(
                      Iconsax.location,
                      'Address',
                      booking.location,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 24),

                // Note Section (Only for non-completed)
                if (booking.status != BookingStatus.completed) ...[
                  Text('Add Note', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Type your note here...',
                    controller: _noteController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                ],

                // Completion Notes (Only for completed)
                if (booking.status == BookingStatus.completed &&
                    booking.completionNotes != null &&
                    booking.completionNotes!.isNotEmpty) ...[
                  Text('Completion Notes', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  _buildDetailSection(
                    children: [
                      Text(
                        booking.completionNotes!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Images Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.status == BookingStatus.completed
                          ? 'Job Proof Photos'
                          : 'Task Photos',
                      style: AppTextStyles.labelLarge,
                    ),
                    if (booking.status != BookingStatus.completed)
                      IconButton(
                        onPressed: _pickImage,
                        icon: const Icon(
                          Iconsax.add_circle,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (booking.status == BookingStatus.completed)
                  booking.jobProofImages.isEmpty
                      ? _buildEmptyPhotoPlaceholder('No proof photos available')
                      : _buildNetworkImageGallery(booking.jobProofImages)
                else
                  _images.isEmpty
                      ? _buildEmptyPhotoPlaceholder('No photos added yet')
                      : _buildLocalImageGallery(),

                const SizedBox(height: 24),

                // Payment Details (Only for completed)
                if (booking.status == BookingStatus.completed) ...[
                  Text('Payment Details', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    children: [
                      _buildDetailRow(
                        Iconsax.money_3,
                        'Payment Mode',
                        booking.paymentMode,
                      ),
                      _buildDetailRow(
                        Iconsax.money_send,
                        'Total Amount',
                        '₹${booking.totalAmount.toStringAsFixed(2)}',
                        valueStyle: AppTextStyles.h4.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),

                // Action Buttons
                if (booking.status == BookingStatus.pending)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Decline',
                          onPressed: () {},
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(text: 'Accept', onPressed: () {}),
                      ),
                    ],
                  )
                else if (booking.status == BookingStatus.ongoing)
                  Column(
                    children: [
                      _buildDetailRow(
                        Iconsax.money_3,
                        'Enter Total Amount',
                        '',
                        child: CustomTextField(
                          hint: '0.00',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.currency_rupee),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Payment Mode', style: AppTextStyles.labelMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChip(
                              'CASH',
                              _paymentMode == 'CASH',
                              () => setState(() => _paymentMode = 'CASH'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChoiceChip(
                              'ONLINE',
                              _paymentMode == 'ONLINE',
                              () => setState(() => _paymentMode = 'ONLINE'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        hint: 'Enter OTP from customer',
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Iconsax.lock),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: _isCompleting ? 'Completing...' : 'Complete Task',
                        onPressed: _isCompleting ? null : _completeTask,
                        backgroundColor: AppColors.success,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection({required List<Widget> children}) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _images.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _completeTask() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter OTP')));
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter total amount')),
      );
      return;
    }

    setState(() => _isCompleting = true);

    try {
      final provider = context.read<ServiceBoyProvider>();
      final List<String> imageUrls = [];

      // 1. Upload images first
      for (var imageFile in _images) {
        final url = await provider.uploadServiceImage(imageFile);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      // 2. Verify OTP with all data
      final Map<String, dynamic> verificationData = {
        'otp': _otpController.text.trim(),
        'completionNotes': _noteController.text.trim(),
        'jobProofImages': imageUrls,
        'totalAmount': double.tryParse(_amountController.text) ?? 0,
        'paymentMode': _paymentMode,
      };

      final success = await provider.verifyBookingOtp(
        widget.booking.id,
        verificationData,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job completed successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.bookingsError ?? 'Verification failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
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
          Icon(
            Iconsax.image,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildLocalImageGallery() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FullScreenImage(
                              imageFile: _images[index],
                              isNetworkImage: false,
                            ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: _images[index].path,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _images[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _images.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
              color: AppColors.primary.withValues(alpha: 0.05),
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
                        (context, error, stackTrace) => Center(
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? valueStyle,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                if (child != null)
                  child
                else
                  Text(
                    value,
                    style:
                        valueStyle ??
                        AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
