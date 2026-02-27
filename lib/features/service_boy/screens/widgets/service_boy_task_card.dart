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
    Color statusColor;
    switch (widget.booking.status) {
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
        margin: const EdgeInsets.only(bottom: 20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Booking ID and Status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.booking.bookingId,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
                      widget.booking.status.name.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: AppColors.background),

            // Content: Icon, Name, Date/Time
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.cleaning_services_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.serviceName,
                          style: AppTextStyles.h4.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.calendar,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.booking.date,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Iconsax.clock,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.booking.time,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.location5,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.booking.location,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            if (widget.booking.status == BookingStatus.pending)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
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
                        backgroundColor: AppColors.error,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                content: Text('Task accepted successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.bookingsError ??
                                      'Failed to accept task',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),

            // Completion Navigation for Ongoing Tasks
            if (widget.booking.status == BookingStatus.ongoing)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: CustomButton(
                  text: 'Complete Job',
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
                  width: double.infinity,
                  height: 50,
                ),
              ),

            // Inline Decline Reasons Section
            if (_declineId == widget.booking.id)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Reason for Declining',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      'Schedule Conflict',
                      'Location too far',
                      'Technical Issues',
                      'Other',
                    ].map(
                      (reason) => InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Decline reason selected: $reason (Not implemented)',
                              ),
                            ),
                          );
                          setState(() {
                            _declineId = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.border),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(reason, style: AppTextStyles.bodySmall),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
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
}
