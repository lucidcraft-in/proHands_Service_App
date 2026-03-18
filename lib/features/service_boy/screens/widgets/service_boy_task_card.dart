import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../providers/service_boy_provider.dart';
import '../service_boy_task_details_screen.dart';

class ServiceBoyTaskCard extends StatefulWidget {
  final BookingModel booking;

  const ServiceBoyTaskCard({super.key, required this.booking});

  @override
  State<ServiceBoyTaskCard> createState() => _ServiceBoyTaskCardState();
}

class _ServiceBoyTaskCardState extends State<ServiceBoyTaskCard> {
  String? _declineId; // Local state to handle decline UI visibility if needed

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ServiceBoyTaskDetailsScreen(booking: widget.booking),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar/Icon Section
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.user,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.booking.serviceName,
                              style: AppTextStyles.h4.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            widget.booking.time,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.booking.customerName} • ${widget.booking.location}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action Buttons
            if (widget.booking.status == BookingStatus.assigned ||
                widget.booking.status == BookingStatus.reached)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    if (widget.booking.status == BookingStatus.assigned) ...[
                      Expanded(
                        child: CustomButton(
                          text:
                              _declineId == widget.booking.id
                                  ? 'Cancel'
                                  : 'Decline',
                          onPressed: () {
                            setState(() {
                              if (_declineId == widget.booking.id) {
                                _declineId = null;
                              } else {
                                _declineId = widget.booking.id;
                              }
                            });
                          },
                          isOutlined: true,
                          backgroundColor: AppColors.white,
                          textColor: AppColors.textPrimary,
                          height: 50,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Accept',
                          onPressed: () async {
                            final provider = context.read<ServiceBoyProvider>();
                            final scaffoldMessenger = ScaffoldMessenger.of(
                              context,
                            );
                            final success = await provider.acceptBooking(
                              widget.booking.id,
                            );
                            if (success) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Work accepted successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } else {
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
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          text: 'Delay',
                          onPressed:
                              () => _showDelayRequestDialog(
                                context,
                                widget.booking.id,
                              ),
                          isOutlined: true,
                          backgroundColor: AppColors.white,
                          textColor: AppColors.warning,
                          height: 50,
                          fontSize: 13,
                        ),
                      ),
                    ] else if (widget.booking.status == BookingStatus.reached)
                      Expanded(
                        child: CustomButton(
                          text: 'Complete Work',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ServiceBoyTaskDetailsScreen(
                                      booking: widget.booking,
                                    ),
                              ),
                            );
                          },
                          backgroundColor: AppColors.success,
                          height: 50,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),

            // Inline Decline Reasons
            if (_declineId == widget.booking.id)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Reason',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...['Schedule Conflict', 'Location too far', 'Other'].map(
                      (reason) => InkWell(
                        onTap: () async {
                          final provider = context.read<ServiceBoyProvider>();
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );
                          setState(() => _declineId = null);
                          final success = await provider.cancelBookingRequest(
                            widget.booking.id,
                            reason,
                          );
                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cancellation request submitted.',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.bookingsError ?? 'Failed to submit.',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(reason, style: AppTextStyles.bodySmall),
                              const Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDelayRequestDialog(BuildContext context, String bookingId) {
    final timeController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Request Delay'),
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  hintText: 'Delay Time (e.g. 30 minutes)',
                  prefixIcon: Icon(Iconsax.clock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Reason for delay',
                  prefixIcon: Icon(Iconsax.note),
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
                return TextButton(
                  onPressed:
                      provider.isRequestingDelay
                          ? null
                          : () async {
                            if (timeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter delay time'),
                                ),
                              );
                              return;
                            }
                            final success = await provider.requestDelay(
                              bookingId: bookingId,
                              delayTime: timeController.text.trim(),
                              delayNote: noteController.text.trim(),
                            );

                            if (mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Delay request submitted'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      provider.delayError ?? 'Failed to submit',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                  child: Text(
                    provider.isRequestingDelay ? 'Submitting...' : 'Submit',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
