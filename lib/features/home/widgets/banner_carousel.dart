import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/banner_model.dart';
import '../providers/consumer_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/shimmer_loading.dart';

class BannerCarousel extends StatefulWidget {
  final String linkType;
  const BannerCarousel({super.key, required this.linkType});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerProvider>().fetchBanners(widget.linkType);
    });
  }

  void _startAutoScroll(int count) {
    _timer?.cancel();
    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < count - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsumerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingBanners) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: CardShimmer(borderRadius: 16),
                  );
                },
              ),
            ),
          );
        }

        if (provider.banners.isEmpty) {
          if (provider.bannersError != null) {
            return const SizedBox.shrink(); // Or show error text if preferred
          }
          return const SizedBox.shrink();
        }

        // Start timer once banners are loaded
        if (_timer == null) {
          _startAutoScroll(provider.banners.length);
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: provider.banners.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final banner = provider.banners[index];
                  return _buildBannerItem(banner);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                provider.banners.length,
                (index) => Container(
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        _currentPage == index
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return child!;
      },
      child: GestureDetector(
        onTap: () {
          // Handle banner click based on linkType and linkId
          print('Banner clicked: ${banner.title}');
        },
        child: Container(
          // margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  banner.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
                // Overlay for text readability if needed
                // if (banner.title.isNotEmpty || banner.description.isNotEmpty)
                //   Positioned(
                //     bottom: 0,
                //     left: 0,
                //     right: 0,
                //     child: Container(
                //       padding: const EdgeInsets.all(16),
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter,
                //           colors: [
                //             Colors.transparent,
                //             Colors.black.withValues(alpha: 0.7),
                //           ],
                //         ),
                //       ),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           if (banner.title.isNotEmpty)
                //             Text(
                //               banner.title,
                //               style: AppTextStyles.h4.copyWith(
                //                 color: Colors.white,
                //                 fontSize: 18,
                //               ),
                //             ),
                //           if (banner.description.isNotEmpty)
                //             Text(
                //               banner.description,
                //               style: AppTextStyles.bodySmall.copyWith(
                //                 color: Colors.white.withValues(alpha: 0.9),
                //               ),
                //               maxLines: 1,
                //               overflow: TextOverflow.ellipsis,
                //             ),
                //         ],
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
