import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import 'widgets/service_boy_task_card.dart';
import '../../service_boy/providers/service_boy_provider.dart';
import '../../../core/widgets/shimmer_loading.dart';

class ServiceBoyTasksScreen extends StatefulWidget {
  const ServiceBoyTasksScreen({super.key});

  @override
  State<ServiceBoyTasksScreen> createState() => _ServiceBoyTasksScreenState();
}

class _ServiceBoyTasksScreenState extends State<ServiceBoyTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceBoyProvider>().fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshBookings() async {
    await context.read<ServiceBoyProvider>().fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Work', style: AppTextStyles.h4),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ServiceBoyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBookings) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) => const ListCardShimmer(),
            );
          }

          if (provider.bookingsError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading work',
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

          return Column(
            children: [
              _buildScrollableTabs(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRefreshableList(
                      provider.assignedBookings,
                      BookingStatus.assigned,
                    ),
                    _buildRefreshableList(
                      provider.acceptedBookings,
                      BookingStatus.accepted,
                    ),
                    _buildRefreshableList(
                      provider.ongoingBookings,
                      BookingStatus.reached,
                    ),
                    _buildRefreshableList(
                      provider.delayRequestedBookings,
                      BookingStatus.delayRequested,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScrollableTabs(ServiceBoyProvider provider) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildTabChip(
              label: 'Assigned',
              count: provider.assignedBookings.length,
              index: 0,
              color: AppColors.info,
              lightColor: AppColors.infoLight,
            ),
            _buildTabChip(
              label: 'Accepted',
              count: provider.acceptedBookings.length,
              index: 1,
              color: AppColors.success,
              lightColor: AppColors.successLight,
            ),
            _buildTabChip(
              label: 'Ongoing',
              count: provider.ongoingBookings.length,
              index: 2,
              color: AppColors.success,
              lightColor: AppColors.successLight,
            ),
            _buildTabChip(
              label: 'Delayed',
              count: provider.delayRequestedBookings.length,
              index: 3,
              color: AppColors.warning,
              lightColor: AppColors.warningLight,
            ),
            _buildTabChip(
              label: 'Completed',
              count: provider.completedBookings.length,
              index: 4,
              color: AppColors.primary,
              lightColor: AppColors.primaryLight.withValues(alpha: 0.1),
            ),
            _buildTabChip(
              label: 'Canceled',
              count: provider.cancelledBookings.length,
              index: 5,
              color: AppColors.error,
              lightColor: AppColors.errorLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip({
    required String label,
    required int count,
    required int index,
    required Color color,
    required Color lightColor,
  }) {
    final bool isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? lightColor : AppColors.background,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              '$count ',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.textTertiary,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textTertiary,
              ),
            ),
          ],
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
                'No ${status.getDisplayStatus(true)} work found',
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
