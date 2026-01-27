import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/services/dummy_data_service.dart';
import 'service_boy_signup_screen.dart';
import 'service_boy_task_details_screen.dart';

class ServiceBoyDashboardScreen extends StatefulWidget {
  const ServiceBoyDashboardScreen({super.key});

  @override
  State<ServiceBoyDashboardScreen> createState() =>
      _ServiceBoyDashboardScreenState();
}

class _ServiceBoyDashboardScreenState extends State<ServiceBoyDashboardScreen> {
  String? _profileImage; // null means default person icon
  final List<String> _galleryImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _galleryImages.add(image.path);
      });
    }
  }

  Future<void> _updateGalleryImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _galleryImages[index] = image.path;
      });
    }
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galleryImages.removeAt(index);
    });
  }

  void _showGalleryActions(int index) {
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
                Text('Gallery Image', style: AppTextStyles.h4),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionItem(
                      Iconsax.refresh,
                      'Update',
                      AppColors.success,
                      () {
                        Navigator.pop(context);
                        _updateGalleryImage(index);
                      },
                    ),
                    _buildOptionItem(
                      Iconsax.trash,
                      'Remove',
                      AppColors.error,
                      () {
                        Navigator.pop(context);
                        _removeGalleryImage(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: AppTextStyles.bodySmall),
                      Text('Amal Provider', style: AppTextStyles.h4),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFA928),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: const Color(0xFFFFA928),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(120 Reviews)',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
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
                          onTap: _showImageOptions,
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
              ),

              const SizedBox(height: 24),

              // Signup Promo Card
              Container(
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
                                (context) => const ServiceBoySignUpScreen(),
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
                        'Start Now',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Tasks',
                      '24',
                      Iconsax.task,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Earnings',
                      '\$1,240',
                      Iconsax.wallet,
                      AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Work Gallery Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Work Portfolio', style: AppTextStyles.labelLarge),
                  IconButton(
                    onPressed: _pickGalleryImage,
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
              _galleryImages.isEmpty
                  ? GestureDetector(
                    onTap: _pickGalleryImage,
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.gallery_add,
                            color: AppColors.textTertiary.withOpacity(0.5),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your work samples',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _galleryImages.length,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showGalleryActions(index),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(File(_galleryImages[index])),
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
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Iconsax.edit_2,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

              const SizedBox(height: 32),

              // Tasks Section (Single View)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active & Recent Tasks',
                    style: AppTextStyles.labelLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Tasks tab if possible or just refresh
                    },
                    child: Text(
                      'See All',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._buildTasksList(context),

              const SizedBox(height: 32),

              // Recent Reviews
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Reviews', style: AppTextStyles.labelLarge),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View all',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              _buildReviewItem(
                'Siyed',
                5.0,
                'Great service, very professional!',
              ),
              _buildReviewItem(
                'Abi',
                4.5,
                'Quick response and fixed the issue.',
              ),
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

  List<Widget> _buildTasksList(BuildContext context) {
    final dummyService = DummyDataService.instance;
    final pendingTasks = dummyService.getBookingsByStatus(
      BookingStatus.pending,
    );
    final ongoingTasks = dummyService.getBookingsByStatus(
      BookingStatus.ongoing,
    );
    final completedTasks = dummyService.getBookingsByStatus(
      BookingStatus.completed,
    );

    // Combine all tasks for a "Single View"
    final allTasks = [...pendingTasks, ...ongoingTasks, ...completedTasks];

    if (allTasks.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('No tasks found', style: AppTextStyles.bodySmall),
          ),
        ),
      ];
    }

    return allTasks.map((booking) {
      Color statusColor;
      String statusText;

      switch (booking.status) {
        case BookingStatus.pending:
          statusColor = AppColors.warning;
          statusText = 'Pending';
          break;
        case BookingStatus.ongoing:
          statusColor = AppColors.primary;
          statusText = 'Ongoing';
          break;
        case BookingStatus.completed:
          statusColor = AppColors.success;
          statusText = 'Completed';
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
                    (context) => ServiceBoyTaskDetailsScreen(booking: booking),
              ),
            );
          },
          child: _buildTaskCard(booking, statusText, statusColor),
        ),
      );
    }).toList();
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
