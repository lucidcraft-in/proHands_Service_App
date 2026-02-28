import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/features/service_boy/screens/edit_service_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';

import '../../../core/widgets/full_screen_image_viewer.dart';
import 'service_boy_task_details_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';
import 'service_boy_overall_analytics_screen.dart';

import 'package:provider/provider.dart';
import '../../service_boy/providers/service_boy_provider.dart';
import '../../home/providers/consumer_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_type.dart';

class ServiceBoyDashboardScreen extends StatefulWidget {
  const ServiceBoyDashboardScreen({super.key});

  @override
  State<ServiceBoyDashboardScreen> createState() =>
      _ServiceBoyDashboardScreenState();
}

class _ServiceBoyDashboardScreenState extends State<ServiceBoyDashboardScreen> {
  String? _profileImage; // null means default person icon
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sbProvider = context.read<ServiceBoyProvider>();
      final consProvider = context.read<ConsumerProvider>();

      sbProvider.fetchBookings();
      sbProvider.fetchDashboardStats();
      sbProvider.fetchOverallAnalytics();
      sbProvider.fetchMyServices(); // Fetch my services instead of categories

      await consProvider.fetchUserProfile();
      final userId = consProvider.currentUser?.id;

      if (userId != null) {
        sbProvider.fetchGalleryImages(userId);
      }
    });
  }

  Future<void> _showAddGalleryImageDialog() async {
    final sbProvider = context.read<ServiceBoyProvider>();
    String? selectedServiceId;
    final TextEditingController descriptionController = TextEditingController();
    File? selectedFile;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Add Portfolio Image', style: AppTextStyles.h4),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Service Dropdown
                      Consumer<ServiceBoyProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoadingServices) {
                            return const CircularProgressIndicator();
                          }
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Select Service',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedServiceId,
                            items:
                                provider.myServices.map((service) {
                                  return DropdownMenuItem(
                                    value: service.id,
                                    child: Text(service.name),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setDialogState(() => selectedServiceId = value);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description Field
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'e.g., painting works done',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Image Picker
                      GestureDetector(
                        onTap: () async {
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setDialogState(
                              () => selectedFile = File(image.path),
                            );
                          }
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child:
                              selectedFile != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      selectedFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Iconsax.image,
                                        size: 40,
                                        color: AppColors.textTertiary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to pick image',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedServiceId == null ||
                          selectedFile == null ||
                          descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Capture the root context to show/hide loader and snackbars correctly
                      final dashboardContext = this.context;

                      Navigator.pop(context); // Close the input dialog

                      // Show loader on the dashboard context
                      showDialog(
                        context: dashboardContext,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      try {
                        final success = await sbProvider.uploadGalleryImage(
                          selectedFile!,
                          descriptionController.text,
                          selectedServiceId!,
                        );

                        if (!dashboardContext.mounted) return;
                        Navigator.pop(dashboardContext); // Hide loader

                        if (success) {
                          ScaffoldMessenger.of(dashboardContext).showSnackBar(
                            const SnackBar(
                              content: Text('Image uploaded successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          // Refresh Gallery
                          final userId =
                              dashboardContext
                                  .read<ConsumerProvider>()
                                  .currentUser
                                  ?.id;
                          if (userId != null) {
                            sbProvider.fetchGalleryImages(userId);
                          }
                        } else {
                          ScaffoldMessenger.of(dashboardContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                sbProvider.uploadGalleryError ??
                                    'Failed to upload',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      } catch (e) {
                        if (dashboardContext.mounted) {
                          Navigator.pop(dashboardContext); // Hide loader
                          ScaffoldMessenger.of(dashboardContext).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Profile Photo', style: AppTextStyles.h4),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionItem(
                      Iconsax.camera,
                      'Add',
                      AppColors.primary,
                      () {
                        setState(
                          () =>
                              _profileImage =
                                  'assets/images/placeholder_worker.png',
                        );
                        Navigator.pop(context);
                      },
                    ),
                    _buildOptionItem(
                      Iconsax.refresh,
                      'Update',
                      AppColors.success,
                      () {
                        // Update logic
                        Navigator.pop(context);
                      },
                    ),
                    _buildOptionItem(
                      Iconsax.trash,
                      'Remove',
                      AppColors.error,
                      () {
                        setState(() => _profileImage = null);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... Header and other widgets ...
              // I'll assume header and other static parts are fine, focusing on task list update
              // Re-injecting the header code for completeness or using a smaller chunk if possible
              // To avoid errors, I will replace the whole file structure or large chunks.
              // Since I need to wrap the task list in Consumer, it's better to update _buildTasksList.

              // Header
              Consumer<ConsumerProvider>(
                builder: (context, consumerProvider, child) {
                  final user =
                      consumerProvider.currentUser ??
                      UserModel(
                        id: 'guest',
                        name: 'Guest User',
                        phone: '',
                        userType: UserType.serviceBoy,
                      );

                  final hasName = user.name != null && user.name!.isNotEmpty;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasName ? 'Welcome back,' : 'Welcome',
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            user.name ?? 'Guest User',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // const Icon(
                              //   Icons.star,
                              //   color: Color(0xFFFFA928),
                              //   size: 14,
                              // ),
                              // const SizedBox(width: 4),
                              // Text(
                              //   user.isActive ? 'Active' : 'Inactive',
                              //   style: AppTextStyles.labelSmall.copyWith(
                              //     color:
                              //         !user.isActive
                              //             ? Colors.red
                              //             : Colors.green,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              // const SizedBox(width: 8),
                              // Text(
                              //   '(120 Reviews)',
                              //   style: AppTextStyles.caption.copyWith(
                              //     fontSize: 10,
                              //     color: AppColors.textTertiary,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primary,
                            backgroundImage:
                                _profileImage != null
                                    ? AssetImage(_profileImage!)
                                    : null,
                            child:
                                _profileImage == null
                                    ? const Icon(
                                      Icons.person,
                                      color: AppColors.white,
                                      size: 28,
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              // _showImageOptions,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowLight,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Iconsax.camera,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Complete Profile Card (Conditional)
              Consumer<ConsumerProvider>(
                builder: (context, consumerProvider, _) {
                  final user = consumerProvider.currentUser;
                  if (user == null) return const SizedBox.shrink();
                  final hasName = user.name != null && user.name!.isNotEmpty;
                  final isGuest = user.name == 'Guest';
                  final isIncomplete = !user.isProfileComplete;

                  if (!hasName || isGuest || isIncomplete) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.orangeGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete Your Profile',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add your services and experience to get more tasks.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Complete',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),

              // Overall Analytics Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const ServiceBoyOverallAnalyticsScreen(),
                    ),
                  );
                },
                child: Container(
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.status_up,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Analytics',
                              style: AppTextStyles.labelLarge,
                            ),
                            Text(
                              'Tap to view your full performance report',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stats Cards
              Consumer<ServiceBoyProvider>(
                builder: (context, provider, child) {
                  final stats = provider.dashboardStats;
                  final bookingsByStatus =
                      stats?['bookingsByStatus'] as Map<String, dynamic>?;

                  final pending =
                      (bookingsByStatus?['PENDING'] ?? 0) +
                      (bookingsByStatus?['ASSIGNED'] ?? 0);
                  final ongoing =
                      (bookingsByStatus?['ACCEPTED'] ?? 0) +
                      (bookingsByStatus?['ONGOING'] ?? 0);
                  final completed = bookingsByStatus?['COMPLETED'] ?? 0;
                  final cancelled = bookingsByStatus?['CANCELLED'] ?? 0;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Pending Work',
                              '$pending',
                              Iconsax.timer,
                              AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Ongoing Work',
                              '$ongoing',
                              Iconsax.activity,
                              AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Completed',
                              '$completed',
                              Iconsax.tick_circle,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Cancelled',
                              '$cancelled',
                              Iconsax.close_circle,
                              AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Work Gallery Section
              Consumer<ServiceBoyProvider>(
                builder: (context, provider, _) {
                  final galleryImages = provider.galleryImages;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Work Portfolio',
                            style: AppTextStyles.labelLarge,
                          ),
                          IconButton(
                            onPressed: _showAddGalleryImageDialog,
                            icon: const Icon(
                              Iconsax.add_circle,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            tooltip: 'Add Photo',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (provider.isLoadingGallery)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (galleryImages.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "No images in portfolio yet.",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                          itemCount: galleryImages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == galleryImages.length) {
                              return GestureDetector(
                                onTap: _showAddGalleryImageDialog,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadowLight,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Iconsax.add,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              );
                            }

                            final image = galleryImages[index];

                            return GestureDetector(
                              onTap: () {
                                print(image.imageUrl);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => FullScreenImageViewer(
                                          imagePath: image.imageUrl,
                                          tag: 'dashboard_gallery_${image.id}',
                                          isFile: true,
                                        ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'dashboard_gallery_${image.id}',
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: NetworkImage(image.imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.shadowLight,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Tasks Section (Single View)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active & Recent Work', style: AppTextStyles.labelLarge),
                  // TextButton(
                  //   onPressed: () {
                  //     // Navigate to Tasks tab if possible or just refresh
                  //   },
                  //   child: Text(
                  //     'See All',
                  //     style: AppTextStyles.bodySmall.copyWith(
                  //       color: AppColors.primary,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Tasks List from Provider
              Consumer<ServiceBoyProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingBookings) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.bookingsError != null) {
                    return Text(
                      'Error loading tasks: ${provider.bookingsError}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    );
                  }

                  final allTasks =
                      provider.bookings
                          .where((b) => b.status != BookingStatus.open)
                          .toList();

                  if (allTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No tasks found',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    );
                  }

                  // Show only first 3 recent tasks
                  final recentTasks = allTasks.take(3).toList();

                  return Column(
                    children:
                        recentTasks.map((booking) {
                          Color statusColor;
                          String statusText;
                          print(booking.status);
                          switch (booking.status) {
                            case BookingStatus.assigned:
                              statusColor = AppColors.warning;
                              statusText = 'Assigned';
                              break;
                            case BookingStatus.reached:
                              statusColor = AppColors.primary;
                              statusText = 'Ongoing';
                              break;
                            case BookingStatus.completed:
                              statusColor = AppColors.success;
                              statusText = 'Completed';
                              break;
                            case BookingStatus.cancelled:
                              statusColor = AppColors.error;
                              statusText = 'Cancelled';
                              break;
                            default:
                              statusColor = AppColors.textSecondary;
                              statusText = 'Unknown';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ServiceBoyTaskDetailsScreen(
                                              booking: booking,
                                            ),
                                  ),
                                );
                              },
                              child: _buildTaskCard(
                                booking,
                                statusText,
                                statusColor,
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Recent Reviews
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('Recent Reviews', style: AppTextStyles.labelLarge),
              //     TextButton(
              //       onPressed: () {},
              //       child: Text(
              //         'View all',
              //         style: AppTextStyles.bodySmall.copyWith(
              //           color: AppColors.primary,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // _buildReviewItem(
              //   'Siyed',
              //   5.0,
              //   'Great service, very professional!',
              // ),
              // _buildReviewItem(
              //   'Abi',
              //   4.5,
              //   'Quick response and fixed the issue.',
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BookingModel booking, String status, Color color) {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.bookingId,
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
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.background),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Iconsax.activity,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.calendar,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(booking.date, style: AppTextStyles.caption),
                          const SizedBox(width: 12),
                          const Icon(
                            Iconsax.clock,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Text(booking.time, style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.location,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              booking.location,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, double rating, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      name[0],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(name, style: AppTextStyles.labelSmall),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA928).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFA928), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: const Color(0xFFFFA928),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
