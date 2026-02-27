import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import 'widgets/service_boy_task_card.dart';
import '../../service_boy/providers/service_boy_provider.dart';

class ServiceBoyTasksScreen extends StatefulWidget {
  const ServiceBoyTasksScreen({super.key});

  @override
  State<ServiceBoyTasksScreen> createState() => _ServiceBoyTasksScreenState();
}

class _ServiceBoyTasksScreenState extends State<ServiceBoyTasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceBoyProvider>().fetchBookings();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshBookings() async {
    await context.read<ServiceBoyProvider>().fetchBookings();
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
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            tabs: const [
              // Tab(text: 'Pending'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'), // Added
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
        body: Consumer<ServiceBoyProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingBookings) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.bookingsError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading tasks',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshBookings,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                // _buildRefreshableList(
                //   provider.pendingBookings,
                //   BookingStatus.pending,
                // ),
                _buildRefreshableList(
                  provider.ongoingBookings,
                  BookingStatus.ongoing,
                ),
                _buildRefreshableList(
                  provider.completedBookings,
                  BookingStatus.completed,
                ),
                _buildRefreshableList(
                  provider.cancelledBookings,
                  BookingStatus.cancelled,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRefreshableList(List<BookingModel> tasks, BookingStatus status) {
    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: _buildTasksList(tasks, status),
    );
  }

  Widget _buildTasksList(List<BookingModel> tasks, BookingStatus status) {
    print("----------");
    print(tasks);
    if (tasks.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                status == BookingStatus.completed
                    ? Iconsax.tick_circle
                    : Iconsax.task,
                size: 64,
                color: AppColors.textTertiary.withValues(alpha: 0.3),
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
    return ServiceBoyTaskCard(booking: booking);
  }
}
