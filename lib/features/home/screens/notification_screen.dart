import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/notification_provider.dart';
import '../../../core/models/notification_model.dart';
import '../providers/consumer_provider.dart';
import '../../service_boy/providers/service_boy_provider.dart';
import 'customer_booking_details_screen.dart';
import '../../service_boy/screens/service_boy_task_details_screen.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_type.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.h4),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<NotificationProvider>().markAllAsRead();
            },
            child: Text(
              'Mark all as read',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchNotifications(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.notification_status,
                    size: 64,
                    color: AppColors.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchNotifications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _NotificationCard(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }
        print("=======");
        // Handle navigation based on data
        if (notification.data?.bookingId != null) {
          final bookingId = notification.data!.bookingId!;
          final navigator = Navigator.of(context);
          final scaffoldMessenger = ScaffoldMessenger.of(context);

          // Determine user role and fetch booking details
          final userType = await StorageService.getUserType();
          final isServiceBoy = userType == UserType.serviceBoy;

          if (isServiceBoy) {
            final provider = context.read<ServiceBoyProvider>();
            // Show loading if needed, or just let the screen handle it
            // ServiceBoyTaskDetailsScreen handles fetching in initState if we pass a partial booking,
            // but we need a full BookingModel. Let's fetch it here for a smoother transition.

            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );

            try {
              await provider.fetchBookingDetails(bookingId);
              navigator.pop(); // Close loading dialog

              if (provider.selectedBooking != null) {
                navigator.push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            userType == UserType.serviceBoy
                                ? ServiceBoyTaskDetailsScreen(
                                  booking: provider.selectedBooking!,
                                )
                                : CustomerBookingDetailsScreen(
                                  booking: provider.selectedBooking!,
                                ),
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.bookingDetailsError ??
                          'Failed to load booking details',
                    ),
                  ),
                );
              }
            } catch (e) {
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          } else {
            final provider = context.read<ConsumerProvider>();

            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final booking = await provider.fetchBookingDetails(bookingId);
              navigator.pop(); // Close loading dialog

              if (booking != null) {
                navigator.push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CustomerBookingDetailsScreen(booking: booking),
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to load booking details'),
                  ),
                );
              }
            } catch (e) {
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              notification.isRead
                  ? AppColors.white
                  : AppColors.primary.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                notification.isRead
                    ? AppColors.divider.withOpacity(0.5)
                    : AppColors.primary.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconColor(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notification.type),
                color: _getIconColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            color:
                                notification.isRead
                                    ? AppColors.textPrimary
                                    : AppColors.primary,
                            fontWeight:
                                notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING':
        return Iconsax.calendar_tick;
      case 'PAYMENT':
        return Iconsax.wallet_2;
      case 'PROMOTION':
        return Iconsax.discount_shape;
      default:
        return Iconsax.notification;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING':
        return AppColors.primary;
      case 'PAYMENT':
        return AppColors.success;
      case 'PROMOTION':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
