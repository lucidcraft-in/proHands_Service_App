import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/consumer_service.dart';
import 'service_provider_detail_screen.dart';

class FullImageScreen extends StatelessWidget {
  final String imagePath;
  final UserModel uploader;
  final bool isNetworkImage;

  const FullImageScreen({
    super.key,
    required this.imagePath,
    required this.uploader,
    this.isNetworkImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              _fetchAndNavigateToProfile(context, uploader.id);
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.white,
              backgroundImage:
                  (isNetworkImage
                          ? NetworkImage(uploader.serviceImage)
                          : AssetImage(uploader.serviceImage))
                      as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child:
                  isNetworkImage
                      ? Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                      )
                      : Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        (isNetworkImage
                                ? NetworkImage(uploader.serviceImage)
                                : AssetImage(uploader.serviceImage))
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          uploader.name!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          uploader.profession,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _fetchAndNavigateToProfile(context, uploader.id);
                    },
                    child: const Text(
                      'View Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAndNavigateToProfile(
    BuildContext context,
    String providerId,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final consumerService = ConsumerService();
      final provider = await consumerService.getProviderById(providerId);

      // Hide loading details
      if (context.mounted) {
        Navigator.of(context).pop(); // Pop loading dialog
      }

      // Navigate to detail screen
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => ServiceProviderDetailScreen(provider: provider),
          ),
        );
      }
    } catch (e) {
      // Hide loading details
      if (context.mounted) {
        Navigator.of(context).pop(); // Pop loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
      }
    }
  }
}
