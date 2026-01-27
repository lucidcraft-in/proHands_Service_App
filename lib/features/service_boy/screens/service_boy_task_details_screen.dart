import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../chat/screens/chat_screen.dart';

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
  final List<String> _images = [];

  @override
  void dispose() {
    _noteController.dispose();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Task Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                        widget.booking.id,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.booking.serviceName, style: AppTextStyles.h4),
                    ],
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
                      widget.booking.status.name.toUpperCase(),
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
                _buildDetailRow(Iconsax.calendar, 'Date', widget.booking.date),
                _buildDetailRow(Iconsax.clock, 'Time', widget.booking.time),
                _buildDetailRow(
                  Iconsax.location,
                  'Location',
                  widget.booking.location,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Customer Details Section
            Text('Customer Details', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            _buildDetailSection(
              children: [
                _buildDetailRow(Iconsax.user, 'Customer Name', 'John Doe'),
                _buildDetailRow(Iconsax.call, 'Phone Number', '+1 234 567 890'),
              ],
            ),

            const SizedBox(height: 16),

            // Chat with Customer Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            currentUserId: 'service_boy_1',
                            currentUserName: 'Service Provider',
                            otherUserId: 'customer_1',
                            otherUserName: 'John Doe',
                            otherUserImage: '',
                          ),
                    ),
                  );
                },
                icon: const Icon(Iconsax.message),
                label: const Text('Chat with Customer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Note Section
            Text('Add Note', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            CustomTextField(
              hint: 'Type your note here...',
              controller: _noteController,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Images Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Task Photos', style: AppTextStyles.labelLarge),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _images.add('Simulated Image ${_images.length + 1}');
                    });
                  },
                  icon: const Icon(
                    Iconsax.add_circle,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _images.isEmpty
                ? Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.image,
                        color: AppColors.textTertiary.withOpacity(0.5),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text('No photos added yet', style: AppTextStyles.caption),
                    ],
                  ),
                )
                : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Iconsax.image,
                                color: AppColors.primary,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        setState(() => _images.removeAt(index)),
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
                ),

            const SizedBox(height: 24),

            // Payment Summary
            Text('Payment Summary', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            _buildDetailSection(
              children: [
                _buildDetailRow(Iconsax.wallet, 'Service Cost', '\$45.00'),
                _buildDetailRow(Iconsax.ticket_discount, 'Discount', '-\$5.00'),
                const Divider(height: 24),
                _buildDetailRow(
                  Iconsax.wallet_2,
                  'Total Amount',
                  '\$40.00',
                  valueStyle: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Action Buttons
            if (widget.booking.status == BookingStatus.pending)
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
            else if (widget.booking.status == BookingStatus.ongoing)
              CustomButton(
                text:
                    widget.booking.isOTPRequested
                        ? 'Verify OTP'
                        : 'Request OTP',
                onPressed: () {},
              ),
          ],
        ),
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? valueStyle,
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
