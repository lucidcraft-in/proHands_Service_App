import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../services/consumer_service.dart';
import 'service_provider_detail_screen.dart';

import '../models/feed_model.dart';

class FullImageScreen extends StatefulWidget {
  final List<FeedModel> feeds;
  final int initialIndex;

  const FullImageScreen({
    super.key,
    required this.feeds,
    required this.initialIndex,
  });

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: widget.feeds.length,
            itemBuilder: (context, index) {
              final feed = widget.feeds[index];
              final imagePath =
                  feed.images.isNotEmpty
                      ? feed.images.first
                      : 'https://via.placeholder.com/300';
              final uploader = feed.provider;

              return Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap:
                                () => _fetchAndNavigateToProfile(
                                  context,
                                  uploader.id,
                                ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                uploader.serviceImage,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  uploader.name,
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
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
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
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
