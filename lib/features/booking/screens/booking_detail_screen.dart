import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String status;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.serviceName,
    required this.status,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final List<String> _uploadedMedia = []; // For demo purposes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Booking Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking ID', style: AppTextStyles.caption),
                      Text(widget.bookingId, style: AppTextStyles.labelLarge),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Work Progress
            Text('Work Progress', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            _buildProgressStep('Request Accepted', '22 Feb, 10:30 AM', true),
            _buildProgressStep(
              'Assigning Serviceman',
              '22 Feb, 11:15 AM',
              true,
            ),
            _buildProgressStep('Work in Progress', '23 Feb, 09:00 AM', true),
            _buildProgressStep('Finalizing', '-', false),

            const SizedBox(height: 32),

            // Work Details / Media Upload
            Text('Work Photos & Videos', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Text(
              'Upload photos or videos of the work being done',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Media Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _uploadedMedia.length + 1,
              itemBuilder: (context, index) {
                if (index == _uploadedMedia.length) {
                  return _buildUploadButton();
                }
                return _buildMediaItem(index);
              },
            ),

            const SizedBox(height: 40),

            CustomButton(
              text: 'Download Invoice',
              onPressed: () {},
              isOutlined: true,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(String title, String subtitle, bool isCompleted) {
    return Row(
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? AppColors.success : AppColors.border,
              size: 20,
            ),
            Container(width: 1, height: 30, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            Text(subtitle, style: AppTextStyles.caption),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _handleUpload,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.none),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.add_square, color: AppColors.primary),
              SizedBox(height: 4),
              Text(
                'Upload',
                style: TextStyle(fontSize: 10, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaItem(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/cleaning_service.png',
          ), // Placeholder
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: () => setState(() => _uploadedMedia.removeAt(index)),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.error,
                child: Icon(Icons.close, color: AppColors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpload() {
    // For demo: add a fake entry
    setState(() {
      _uploadedMedia.add('media_${_uploadedMedia.length}');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Media uploaded successfully')),
    );
  }
}
