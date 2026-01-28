import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/dummy_data_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'service_boy_task_details_screen.dart';

class ServiceBoyTasksScreen extends StatefulWidget {
  const ServiceBoyTasksScreen({super.key});

  @override
  State<ServiceBoyTasksScreen> createState() => _ServiceBoyTasksScreenState();
}

class _ServiceBoyTasksScreenState extends State<ServiceBoyTasksScreen> {
  final _dummyService = DummyDataService.instance;
  final TextEditingController _otpController = TextEditingController();
  String? _decliningBookingId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('My Tasks', style: AppTextStyles.h4),
          centerTitle: true,
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
            labelStyle: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.labelSmall,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildTasksList(BookingStatus.pending),
            _buildTasksList(BookingStatus.ongoing),
            _buildTasksList(BookingStatus.completed),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(BookingStatus status) {
    final tasks = _dummyService.getBookingsByStatus(status);

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == BookingStatus.completed
                  ? Iconsax.tick_circle
                  : Iconsax.task,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status.name} tasks found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) => _buildTaskItem(tasks[index]),
    );
  }

  Widget _buildTaskItem(BookingModel booking) {
    Color statusColor;
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
      default:
        statusColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceBoyTaskDetailsScreen(booking: booking),
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
                    booking.id,
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
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      booking.status.name.toUpperCase(),
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
                      color: AppColors.primary.withOpacity(0.08),
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
                          booking.serviceName,
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
                            Text(booking.date, style: AppTextStyles.bodySmall),
                            const SizedBox(width: 16),
                            const Icon(
                              Iconsax.clock,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(booking.time, style: AppTextStyles.bodySmall),
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
                      booking.location,
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
            if (booking.status == BookingStatus.pending)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text:
                            _decliningBookingId == booking.id
                                ? 'Cancel'
                                : 'Decline',
                        onPressed: () {
                          setState(() {
                            if (_decliningBookingId == booking.id) {
                              _decliningBookingId = null;
                            } else {
                              _decliningBookingId = booking.id;
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
                        onPressed: () {
                          setState(() {
                            _dummyService.updateBookingStatus(
                              booking.id,
                              BookingStatus.ongoing,
                            );
                          });
                        },
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),

            if (booking.status == BookingStatus.ongoing)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child:
                    !booking.isCompleteClicked
                        ? CustomButton(
                          text: 'Complete',
                          onPressed: () {
                            setState(() {
                              _dummyService.updateBookingAction(
                                booking.id,
                                isCompleteClicked: true,
                              );
                            });
                          },
                          backgroundColor: AppColors.success,
                          width: double.infinity,
                          height: 50,
                        )
                        : !booking.isOTPRequested
                        ? CustomButton(
                          text: 'Request OTP',
                          onPressed: () {
                            setState(() {
                              _dummyService.updateBookingAction(
                                booking.id,
                                isOTPRequested: true,
                              );
                            });
                          },
                          width: double.infinity,
                          height: 50,
                        )
                        : Column(
                          children: [
                            CustomTextField(
                              controller: _otpController,
                              hint: 'Enter OTP (123456)',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(
                                Iconsax.password_check,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Verify & Complete',
                              onPressed: () {
                                if (_otpController.text == '123456') {
                                  setState(() {
                                    _dummyService.updateBookingStatus(
                                      booking.id,
                                      BookingStatus.completed,
                                    );
                                    _otpController.clear();
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Invalid OTP. Use 123456 for demo.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              width: double.infinity,
                              height: 50,
                            ),
                          ],
                        ),
              ),

            // Inline Decline Reasons Section
            if (_decliningBookingId == booking.id)
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
                          setState(() {
                            _dummyService.updateBookingStatus(
                              booking.id,
                              BookingStatus.cancelled,
                            );
                            _decliningBookingId = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Task declined: $reason')),
                          );
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
