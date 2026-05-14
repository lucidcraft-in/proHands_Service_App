import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/core/models/review_model.dart';
import '../../../core/services/locationTrack.dart';
import '../../home/widgets/timelinechip.dart';
import '../providers/service_boy_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/full_screen_image.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/services/location_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final _additionalAmountController = TextEditingController();
  final _additionalNoteController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isRedeemingPoints = false;
  int _pointsToRedeem = 0;
  final List<File> _images = [];
  final _picker = ImagePicker();
  String _paymentMode = 'CASH';
  bool _isCompleting = false;
  String? _resolvedPlaceName;
  bool _isResolvingPlace = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ServiceBoyProvider>();
      await provider.fetchBookingDetails(widget.booking.id);
      provider.fetchBookingLogs(widget.booking.id);
      _resolvePlaceName();

      // Initialize amount with the total from the booking
      if (provider.selectedBooking != null) {
        _amountController.text = provider.selectedBooking!.totalAmount
            .toStringAsFixed(0);
      } else {
        _amountController.text = widget.booking.totalAmount.toStringAsFixed(0);
      }
    });
  }

  Future<void> _resolvePlaceName() async {
    final provider = context.read<ServiceBoyProvider>();
    final booking = provider.selectedBooking ?? widget.booking;

    if (booking.coordinates != null && booking.coordinates!.length >= 2) {
      if (mounted) setState(() => _isResolvingPlace = true);

      try {
        // [longitude, latitude] -> (latitude, longitude)
        final result = await LocationService.getAddressFromLatLng(
          booking.coordinates![1],
          booking.coordinates![0],
        );

        if (mounted) {
          setState(() {
            _resolvedPlaceName = result?['address'];
            _isResolvingPlace = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isResolvingPlace = false);
      }
    }
  }

  Future<void> _launchMaps() async {
    final provider = context.read<ServiceBoyProvider>();
    final booking = provider.selectedBooking ?? widget.booking;

    if (booking.coordinates != null && booking.coordinates!.length >= 2) {
      // final googleMapsUrl = Uri.parse(
      //   "https://www.google.com/maps/search/?api=1&query=${booking.coordinates![1]},${booking.coordinates![0]}",
      // );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MapScreen(booking: booking)),
      );
      // try {
      //   if (await canLaunchUrl(googleMapsUrl)) {
      //     await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      //   } else {
      //     if (mounted) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text('Could not launch Google Maps')),
      //       );
      //     }
      //   }
      // } catch (e) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(
      //       context,
      //     ).showSnackBar(SnackBar(content: Text('Error: $e')));
      //   }
      // }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    _additionalAmountController.dispose();
    _additionalNoteController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Work Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: Consumer<ServiceBoyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBookingDetails) {
            return const _TaskDetailsShimmer();
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
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final booking = provider.selectedBooking ?? widget.booking;
          print("booking");
          print("--------------");
          print(booking.status);
          Color statusColor = AppColors.primary; // Default
          switch (booking.status) {
            case BookingStatus.assigned:
              statusColor = AppColors.warning;
              break;
            case BookingStatus.reached:
              statusColor = AppColors.primary;
              break;
            case BookingStatus.completed:
            case BookingStatus.closed:
            case BookingStatus.closedByCustomer:
            case BookingStatus.commissionPaymentPending:
              statusColor = AppColors.success;
              break;
            case BookingStatus.cancelled:
              statusColor = AppColors.error;
              break;
            case BookingStatus.delayRequested:
              statusColor = AppColors.warning;
              break;
            default:
              statusColor = AppColors.textTertiary;
          }

          final isCompletedState =
              booking.status == BookingStatus.completed ||
              booking.status == BookingStatus.closed ||
              booking.status == BookingStatus.closedByCustomer ||
              booking.status == BookingStatus.commissionPaymentPending;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                          Row(
                            children: [
                              Text(
                                booking.bookingId,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 14),
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
                                  booking.status
                                      .getDisplayStatus(true)
                                      .toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(booking.serviceName, style: AppTextStyles.h4),
                        ],
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

                    _buildDetailRow(
                      Iconsax.location,
                      'Place',
                      '',
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${booking.coordinates.toString()}",
                              // _isResolvingPlace
                              // ? 'Resolving...'
                              // : _resolvedPlaceName ??
                              //     (booking.location.isNotEmpty
                              //         ? booking.location
                              //         : 'Not available'),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (booking.coordinates != null)
                            IconButton(
                              onPressed: _launchMaps,
                              icon: Icon(
                                Iconsax.direct_right,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
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
                if (!isCompletedState) ...[
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
                if (isCompletedState &&
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
                      isCompletedState ? 'Job Proof Photos' : 'Work Photos',
                      style: AppTextStyles.labelLarge,
                    ),
                    if (!isCompletedState)
                      IconButton(
                        onPressed: _pickImage,
                        icon: Icon(
                          Iconsax.add_circle,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isCompletedState)
                  booking.jobProofImages.isEmpty
                      ? _buildEmptyPhotoPlaceholder('No proof photos available')
                      : _buildNetworkImageGallery(booking.jobProofImages)
                else
                  _images.isEmpty
                      ? _buildEmptyPhotoPlaceholder('No photos added yet')
                      : _buildLocalImageGallery(),

                const SizedBox(height: 24),

                // Payment Details (Only for completed)
                if (isCompletedState) ...[
                  Text('Payment Details', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    children: [
                      _buildDetailRow(
                        Iconsax.money_3,
                        'Payment Mode',
                        booking.paymentMode,
                      ),
                      const Divider(height: 24),
                      _buildPriceLine(
                        'Base Amount',
                        booking.totalAmount -
                            booking.additionalAmount +
                            booking.pointsValue,
                      ),
                      // if (booking.additionalAmount > 0)
                      _buildPriceLine(
                        'Additional Amount',
                        booking.additionalAmount,
                      ),
                      if (booking.pointsValue > 0)
                        _buildPriceLine(
                          'Points Discount',
                          -booking.pointsValue,
                          isDiscount: true,
                        ),
                      const SizedBox(height: 8),
                      _buildPriceLine(
                        'Final Total',
                        booking.totalAmount,
                        isTotal: true,
                      ),
                    ],
                  ),
                ],

                // Customer Review Section
                if (isCompletedState && booking.review != null) ...[
                  const SizedBox(height: 24),
                  Text('Customer Review', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 16),
                  _buildCustomerReviewDisplay(booking.review!),
                ],

                // // Rate Customer Section
                // if (booking.status == BookingStatus.closedByCustomer &&
                //     !_reviewSubmitted) ...[
                //   const SizedBox(height: 24),
                //   _buildRateCustomerSection(booking.id),
                // ],
                const SizedBox(height: 15),
                if (booking.status == BookingStatus.assigned)
                  CustomButton(
                    text: 'Delay Request',
                    onPressed:
                        () => _showDelayRequestDialog(context, booking.id),
                    isOutlined: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    textColor: AppColors.warning,
                    height: 50,
                    fontSize: 13,
                  ),
                const SizedBox(height: 15),
                // A const SizedBox(height: 16),ction Buttons
                if (booking.status == BookingStatus.assigned)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Decline',
                              onPressed:
                                  () => _showDeclineDialog(
                                    context,
                                    booking.id,
                                    true,
                                  ),
                              isOutlined: true,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              textColor: AppColors.textPrimary,
                              height: 50,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer<ServiceBoyProvider>(
                              builder: (context, provider, child) {
                                return CustomButton(
                                  text: 'Accept',
                                  isLoading: provider.isAccepting,
                                  onPressed: () async {
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);
                                    final success = await provider
                                        .acceptBooking(booking.id);

                                    if (success && mounted) {
                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Work accepted successfully!',
                                          ),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else if (mounted) {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.bookingsError ??
                                                'Failed to accept work',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: AppColors.primary,
                                  height: 50,
                                  fontSize: 13,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else if (booking.status == BookingStatus.accepted)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Consumer<ServiceBoyProvider>(
                              builder: (context, provider, child) {
                                return CustomButton(
                                  text: 'Mark as Arrived',
                                  isLoading: provider.isReaching,
                                  onPressed: () async {
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);
                                    final success = await provider
                                        .reachedBooking(booking.id);

                                    if (success && mounted) {
                                      scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Work marked as arrived!',
                                          ),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else if (mounted) {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            provider.bookingsError ??
                                                'Failed to update status',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: AppColors.primary,
                                  height: 50,
                                  fontSize: 13,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else if (booking.status == BookingStatus.reached)
                  Column(
                    children: [
                      _buildDetailRow(
                        Iconsax.money_3,
                        'Base Amount',
                        '',
                        child: CustomTextField(
                          hint: '0.00',
                          readOnly: true,
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.currency_rupee),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Iconsax.add_circle,
                        'Additional Amount',
                        '',
                        child: CustomTextField(
                          hint: '0.00',
                          controller: _additionalAmountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.add),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        Iconsax.note,
                        'Additional Note',
                        '',
                        child: CustomTextField(
                          hint: 'Reason for extra charge...',
                          controller: _additionalNoteController,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Points Redemption
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _isRedeemingPoints,
                                  onChanged: (val) {
                                    setState(() {
                                      _isRedeemingPoints = val ?? false;
                                      if (_isRedeemingPoints) {
                                        _pointsToRedeem =
                                            booking.redeemedPoints > 0
                                                ? booking.redeemedPoints
                                                : 0;
                                      }
                                    });
                                  },
                                  activeColor: Colors.amber,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Redeem Points',
                                            style: AppTextStyles.labelMedium,
                                          ),
                                          Text(
                                            'Available: ${booking.customerPoints} pts',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '1 point = ₹40',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: Colors.amber.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (_isRedeemingPoints) ...[
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Points to use:'),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        hintText: 'Qty',
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _pointsToRedeem =
                                              int.tryParse(val) ?? 0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Discount:',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    '- ₹${(_pointsToRedeem * 40).toStringAsFixed(2)}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Final Amount Calculation Display
                      Column(
                        children: [
                          _buildPriceLine(
                            'Work Amount',
                            double.tryParse(_amountController.text) ?? 0,
                          ),
                          _buildPriceLine(
                            'Additional',
                            double.tryParse(_additionalAmountController.text) ??
                                0,
                          ),
                          if (_isRedeemingPoints)
                            _buildPriceLine(
                              'Points Discount',
                              -(_pointsToRedeem * 40.0),
                              isDiscount: true,
                            ),
                          const Divider(),
                          _buildPriceLine(
                            'Final Total',
                            (double.tryParse(_amountController.text) ?? 0) +
                                (double.tryParse(
                                      _additionalAmountController.text,
                                    ) ??
                                    0) -
                                (_isRedeemingPoints
                                    ? (_pointsToRedeem * 40.0)
                                    : 0),
                            isTotal: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                        prefixIcon: Icon(Iconsax.lock),
                      ),
                      const SizedBox(height: 24),
                      Consumer<ServiceBoyProvider>(
                        builder: (context, provider, child) {
                          return CustomButton(
                            text: 'Complete Work',
                            isLoading: provider.isVerifyingOtp,
                            onPressed:
                                provider.isVerifyingOtp ? null : _completeTask,
                            backgroundColor: AppColors.success,
                            height: 44,
                            fontSize: 14,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Delay Request',
                        onPressed:
                            () => _showDelayRequestDialog(context, booking.id),
                        isOutlined: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        textColor: AppColors.warning,
                        height: 44,
                        fontSize: 13,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                _buildLogsTimeline(),
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
        color: Theme.of(context).colorScheme.surface,
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
          color:
              isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.surface
                      : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, String bookingId, bool type) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedReason = 'Schedule Conflict';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Decline Work'),
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select a reason for declining this work:'),
                  const SizedBox(height: 16),
                  ...[
                    'Schedule Conflict',
                    'Location too far',
                    'Technical Issues',
                    'Other',
                  ].map(
                    (reason) => RadioListTile<String>(
                      title: Text(reason, style: AppTextStyles.bodyMedium),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedReason = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Consumer<ServiceBoyProvider>(
                  builder: (context, provider, child) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: CustomButton(
                        text: 'Submit',
                        isLoading: provider.isReassigning,
                        onPressed: () async {
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            this.context,
                          );
                          final success = await provider.reassignBookingRequest(
                            bookingId,
                            selectedReason,
                          );

                          if (mounted) {
                            Navigator.pop(context); // Close dialog
                            if (success) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cancellation request submitted.',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              Navigator.pop(this.context); // Go back to list
                            } else {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.bookingsError ??
                                        'Failed to submit request',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        width: 100,
                        height: 40,
                        backgroundColor: AppColors.primary,
                        fontSize: 13,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget _buildLogsTimeline() {
  //   return Consumer<ServiceBoyProvider>(
  //     builder: (context, provider, child) {
  //       if (provider.isLoadingBookingLogs) {
  //         return Padding(
  //           padding: EdgeInsets.symmetric(vertical: 20),
  //           child: ListCardShimmer(),
  //         );
  //       }

  //       if (provider.bookingLogs.isEmpty) {
  //         return const SizedBox.shrink();
  //       }

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Booking Timeline', style: AppTextStyles.h4),
  //           const SizedBox(height: 16),
  //           ListView.builder(
  //             shrinkWrap: true,
  //             physics: const NeverScrollableScrollPhysics(),
  //             itemCount: provider.bookingLogs.length,
  //             itemBuilder: (context, index) {
  //               final log = provider.bookingLogs[index];
  //               final isLast = index == provider.bookingLogs.length - 1;

  //               DateTime? dateTime;
  //               try {
  //                 dateTime = DateTime.parse(log.createdAt).toLocal();
  //               } catch (_) {}

  //               final dateStr =
  //                   dateTime != null
  //                       ? "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}"
  //                       : log.createdAt;

  //               return IntrinsicHeight(
  //                 child: Row(
  //                   children: [
  //                     Column(
  //                       children: [
  //                         Container(
  //                           width: 12,
  //                           height: 12,
  //                           decoration: BoxDecoration(
  //                             color: AppColors.primary,
  //                             shape: BoxShape.circle,
  //                           ),
  //                         ),
  //                         if (!isLast)
  //                           Expanded(
  //                             child: Container(
  //                               width: 2,
  //                               color: AppColors.primary.withValues(alpha: 0.3),
  //                             ),
  //                           ),
  //                       ],
  //                     ),
  //                     const SizedBox(width: 16),
  //                     Expanded(
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(bottom: 24),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Row(
  //                               mainAxisAlignment:
  //                                   MainAxisAlignment.spaceBetween,
  //                               children: [
  //                                 Text(
  //                                   log.createdByUserType,
  //                                   style: AppTextStyles.bodyLarge.copyWith(
  //                                     fontWeight: FontWeight.bold,
  //                                   ),
  //                                 ),
  //                                 Text(
  //                                   dateStr,
  //                                   style: AppTextStyles.bodySmall.copyWith(
  //                                     color: AppColors.textTertiary,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             const SizedBox(height: 4),
  //                             Text(
  //                               log.notes,
  //                               style: AppTextStyles.bodyMedium.copyWith(
  //                                 color: AppColors.textSecondary,
  //                               ),
  //                             ),
  //                             const SizedBox(height: 4),
  //                             Text(
  //                               "By: ${log.createdByName}",
  //                               style: AppTextStyles.labelSmall.copyWith(
  //                                 color: AppColors.textTertiary,
  //                                 fontStyle: FontStyle.italic,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  Widget _buildLogsTimeline() {
    return Consumer<ServiceBoyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBookingLogs) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: ListCardShimmer(),
          );
        }

        if (provider.bookingLogs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BOOKING TIMELINE',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.bookingLogs.length,
              itemBuilder: (context, index) {
                final log = provider.bookingLogs[index];
                final isLast = index == provider.bookingLogs.length - 1;
                return TimelineItem(log: log, isLast: isLast);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDelayRequestDialog(BuildContext context, String bookingId) {
    final timeController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Request Delay'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                hint: 'Delay Time (e.g. 30 minutes)',
                controller: timeController,
                prefixIcon: Icon(Iconsax.clock),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hint: 'Reason for delay',
                controller: noteController,
                maxLines: 3,
                prefixIcon: Icon(Iconsax.note),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Consumer<ServiceBoyProvider>(
              builder: (consumerContext, provider, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: CustomButton(
                    text: 'Submit',
                    isLoading: provider.isRequestingDelay,
                    onPressed: () async {
                      if (timeController.text.isEmpty) {
                        ScaffoldMessenger.of(consumerContext).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter delay time'),
                          ),
                        );
                        return;
                      }
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await provider.requestDelay(
                        bookingId: bookingId,
                        delayTime: timeController.text.trim(),
                        delayNote: noteController.text.trim(),
                      );

                      if (!mounted) return;

                      // Always use the dialog context to pop the dialog
                      Navigator.of(dialogContext).pop();

                      if (success) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Delay request submitted'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.delayError ?? 'Failed to submit',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    width: 100,
                    height: 40,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ],
        );
      },
    ).then((_) {
      timeController.dispose();
      noteController.dispose();
    });
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
        // 'totalAmount':
        //     (double.tryParse(_amountController.text) ?? 0) +
        //     (double.tryParse(_additionalAmountController.text) ?? 0) -
        //     (_isRedeemingPoints ? (_pointsToRedeem * 40.0) : 0),
        'additionalAmount':
            double.tryParse(_additionalAmountController.text) ?? 0,
        'additionalNote': _additionalNoteController.text.trim(),
        'redeemedPoints': _isRedeemingPoints ? _pointsToRedeem : 0,
        'pointsValue': _isRedeemingPoints ? (_pointsToRedeem * 40.0) : 0,
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
        color: Theme.of(context).colorScheme.surface,
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
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).scaffoldBackgroundColor,
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

  Widget _buildCustomerReviewDisplay(ReviewModel review) {
    return _buildDetailSection(
      children: [
        Row(
          children: [
            _buildRatingStars(review.rating.toDouble(), size: 20),
            const SizedBox(width: 8),
            Text(
              '${review.rating}.0',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildRateCustomerSection(String bookingId) {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).colorScheme.surface,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.shadowLight,
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('Rate Customer', style: AppTextStyles.labelLarge),
  //         const SizedBox(height: 16),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: List.generate(5, (index) {
  //             return IconButton(
  //               onPressed:
  //                   () => setState(() => _ratingByProvider = index + 1.0),
  //               icon: Icon(
  //                 index < _ratingByProvider ? Icons.star : Icons.star_border,
  //                 color: Colors.amber,
  //                 size: 32,
  //               ),
  //             );
  //           }),
  //         ),
  //         const SizedBox(height: 16),
  //         CustomTextField(
  //           hint: 'Share your feedback about the customer...',
  //           controller: _reviewCommentController,
  //           maxLines: 3,
  //         ),
  //         const SizedBox(height: 24),
  //         CustomButton(
  //           text: 'Submit Rating',
  //           onPressed: _ratingByProvider == 0 ? null : _submitProviderReview,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _submitProviderReview() async {
  //   final provider = context.read<ServiceBoyProvider>();
  //   final success = await provider.submitReview(
  //     bookingId: widget.booking.id,
  //     rating: _ratingByProvider,
  //     comment: _reviewCommentController.text.trim(),
  //   );

  //   if (mounted) {
  //     if (success) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Review submitted successfully!'),
  //           backgroundColor: AppColors.success,
  //         ),
  //       );
  //       setState(() {
  //         _reviewSubmitted = true;
  //       });
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(provider.reviewError ?? 'Failed to submit review'),
  //           backgroundColor: AppColors.error,
  //         ),
  //       );
  //     }
  //   }
  // }

  Widget _buildRatingStars(double rating, {double size = 16}) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  // String _formatDate(DateTime date) {
  //   return '${date.day}/${date.month}/${date.year}';
  // }

  Widget _buildPriceLine(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTextStyles.h4 : AppTextStyles.bodyMedium,
          ),
          Text(
            isDiscount
                ? '- ₹${amount.abs().toStringAsFixed(2)}'
                : '₹${amount.toStringAsFixed(2)}',
            style: (isTotal ? AppTextStyles.h4 : AppTextStyles.bodyMedium)
                .copyWith(
                  color:
                      isDiscount
                          ? Colors.green
                          : (isTotal
                              ? AppColors.primary
                              : AppColors.textPrimary),
                ),
          ),
        ],
      ),
    );
  }
}

class _TaskDetailsShimmer extends StatelessWidget {
  const _TaskDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardShimmer(height: 120),
          const SizedBox(height: 24),
          TextShimmer(width: 150, height: 24),
          const SizedBox(height: 16),
          const CardShimmer(height: 150),
          const SizedBox(height: 24),
          TextShimmer(width: 180, height: 24),
          const SizedBox(height: 16),
          const CardShimmer(height: 200),
        ],
      ),
    );
  }
}
