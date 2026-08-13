import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../../../../core/widgets/full_screen_gallery_viewer.dart';
import '../../../../core/widgets/gallery_grid_screen.dart';
import '../../../core/models/user_model.dart';
import '../models/service_product_model.dart';
import '../../booking/screens/booking_checkout_screen.dart';
import '../../booking/screens/request_quotation_screen.dart';
import '../providers/consumer_provider.dart';
import '../services/consumer_service.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class ServiceProductDetailScreen extends StatefulWidget {
  final ServiceProductModel service;

  const ServiceProductDetailScreen({super.key, required this.service});

  static Future<void> navigateWithProviderId(
    BuildContext context,
    String providerId,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final consumerService = ConsumerService();
      final services = await consumerService.getAllServices();
      final providerServices =
          services.where((s) => s.providerId == providerId).toList();

      if (context.mounted) {
        Navigator.of(context).pop(); // Pop loading dialog
      }

      if (providerServices.isNotEmpty) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ServiceProductDetailScreen(
                    service: providerServices.first,
                  ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No services listed for this professional.'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading provider profile: $e')),
        );
      }
    }
  }

  @override
  State<ServiceProductDetailScreen> createState() =>
      _ServiceProductDetailScreenState();
}

class _ServiceProductDetailScreenState
    extends State<ServiceProductDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  UserModel? _providerDetails;
  bool _isLoadingProviderDetails = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerProvider>().fetchServiceDetails(widget.service.id);
      context.read<ConsumerProvider>().fetchAllServices();
      _fetchProviderDetails();
    });
  }

  Future<void> _fetchProviderDetails() async {
    if (widget.service.providerId.isEmpty) return;
    setState(() {
      _isLoadingProviderDetails = true;
    });
    try {
      final consumerService = ConsumerService();
      final provider = await consumerService.getProviderById(
        widget.service.providerId,
      );
      if (mounted) {
        setState(() {
          _providerDetails = provider;
          _isLoadingProviderDetails = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProviderDetails = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsumerProvider>(
      builder: (context, provider, child) {
        // Use fetched service if available, otherwise fallback to constructor service
        final service =
            (provider.currentService != null &&
                    provider.currentService!.id == widget.service.id)
                ? provider.currentService!
                : widget.service;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              // Header with Service Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeaderCarousel(context, service),
                      // Gradient Overlay
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (provider.isLoadingServiceDetails)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Name and Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.categoryName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  // style: AppTextStyles.h3.copyWith(
                                  //   fontSize: 18,
                                  //   color:
                                  //       Theme.of(context).colorScheme.onSurface,
                                  // ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service.name,
                        // "Electriction",
                        style: AppTextStyles.h3.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      // Rating and Info
                      // const SizedBox(height: 12),
                      // // Provider Info Section
                      // Text(
                      //   'Service Professional',
                      //   style: AppTextStyles.labelLarge.copyWith(
                      //     color: Theme.of(context).colorScheme.onSurface,
                      //   ),
                      // ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  service.providerImage.isNotEmpty
                                      ? NetworkImage(service.providerImage)
                                      : null,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child:
                                  service.providerImage.isEmpty
                                      ? const Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.providerName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    service.profession,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Iconsax.verify5,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.star1,
                            size: 18,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.rating > 0
                                ? service.rating.toStringAsFixed(1)
                                : 'New',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            ' (${service.reviewsCount} reviews)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Iconsax.clock,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.duration} mins',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // if (service.specialties.isNotEmpty) ...[
                      //   const SizedBox(height: 16),
                      //   Text(
                      //     'Specialties',
                      //     style: AppTextStyles.labelLarge.copyWith(
                      //       color: Theme.of(context).colorScheme.onSurface,
                      //     ),
                      //   ),
                      //   const SizedBox(height: 8),
                      //   Wrap(
                      //     spacing: 8,
                      //     runSpacing: 8,
                      //     children:
                      //         service.specialties
                      //             .map(
                      //               (s) =>
                      //                   _buildSkillChip(s, AppColors.primary),
                      //             )
                      //             .toList(),
                      //   ),
                      // ],
                      // if (service.subcategoryName.isNotEmpty ||
                      //     service.categoryName.isNotEmpty)
                      //   Text(
                      //     service.subcategoryName.isNotEmpty
                      //         ? service.subcategoryName
                      //         : service.categoryName,
                      //     style: AppTextStyles.bodyMedium.copyWith(
                      //       color: Theme.of(
                      //         context,
                      //       ).colorScheme.onSurface.withOpacity(0.6),
                      //     ),
                      //   ),
                      if (service.subcategories.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Services Offered',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              service.subcategories
                                  .map(
                                    (sub) => _buildSkillChip(
                                      sub.name,
                                      AppColors.primary,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                      if (service.servicesOffered.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Additional Skills',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              service.additionalSkills
                                  .map((s) => _buildSkillChip(s, Colors.blue))
                                  .toList(),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      if (service.gallery.isNotEmpty) ...[
                        Text(
                          'SERVICE GALLERY',
                          style: AppTextStyles.labelSmall.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),

                        SizedBox(
                          height: 240,
                          child: Row(
                            children: [
                              // Featured large tile
                              Expanded(
                                flex: 2,
                                child: _GalleryTile(
                                  imageUrl: service.gallery[0],
                                  heroTag: 'gallery_image_0',
                                  borderRadius: 14,
                                  onTap:
                                      () => _openImageViewer(
                                        context,
                                        service.gallery[0],
                                        'gallery_image_0',
                                        galleryImages: service.gallery,
                                        initialIndex: 0,
                                      ),
                                  badge: 'Featured',
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Right 2×2 grid
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (service.gallery.length > 1)
                                            Expanded(
                                              child: _GalleryTile(
                                                imageUrl: service.gallery[1],
                                                heroTag: 'gallery_image_1',
                                                borderRadius: 14,
                                                onTap:
                                                    () => _openImageViewer(
                                                      context,
                                                      service.gallery[1],
                                                      'gallery_image_1',
                                                      galleryImages:
                                                          service.gallery,
                                                      initialIndex: 1,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (service.gallery.length > 2)
                                            Expanded(
                                              child: _GalleryTile(
                                                imageUrl: service.gallery[2],
                                                heroTag: 'gallery_image_2',
                                                borderRadius: 14,
                                                onTap:
                                                    () => _openImageViewer(
                                                      context,
                                                      service.gallery[2],
                                                      'gallery_image_2',
                                                      galleryImages:
                                                          service.gallery,
                                                      initialIndex: 2,
                                                    ),
                                              ),
                                            ),
                                          if (service.gallery.length > 3) ...[
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: _MoreTile(
                                                imageUrl: service.gallery[3],
                                                remainingCount:
                                                    service.gallery.length - 3,
                                                borderRadius: 14,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => GalleryGridScreen(
                                                            images:
                                                                service.gallery,
                                                            title:
                                                                'Service Gallery',
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // const SizedBox(height: 24),
                      // if (service.gallery.isNotEmpty) ...[
                      //   Text(
                      //     'Service Gallery',
                      //     style: AppTextStyles.labelLarge.copyWith(
                      //       color: Theme.of(context).colorScheme.onSurface,
                      //     ),
                      //   ),
                      //   const SizedBox(height: 12),

                      //   SizedBox(
                      //     height: 100,
                      //     child: Row(
                      //       children: List.generate(
                      //         service.gallery.length > 3
                      //             ? 4
                      //             : service.gallery.length,
                      //         (index) {
                      //           // Show +N card
                      //           if (index == 3) {
                      //             final remainingCount =
                      //                 service.gallery.length - 3;

                      //             return Expanded(
                      //               child: GestureDetector(
                      //                 onTap: () {
                      //                   final heroTag = 'gallery_image_$index';
                      //                   _openImageViewer(
                      //                     context,
                      //                     service.gallery[3],
                      //                     heroTag,
                      //                     galleryImages: service.gallery,
                      //                     initialIndex: index,
                      //                   );
                      //                 },
                      //                 child: Container(
                      //                   child: ClipRRect(
                      //                     borderRadius: BorderRadius.circular(
                      //                       12,
                      //                     ),
                      //                     child: Stack(
                      //                       fit: StackFit.expand,
                      //                       children: [
                      //                         Image.network(
                      //                           service.gallery[3],
                      //                           fit: BoxFit.cover,
                      //                         ),
                      //                         Container(color: Colors.black54),
                      //                         Center(
                      //                           child: Text(
                      //                             '+$remainingCount',
                      //                             style: const TextStyle(
                      //                               color: Colors.white,
                      //                               fontSize: 30,
                      //                               fontWeight: FontWeight.bold,
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //                   //  ClipRRect(
                      //                   //   borderRadius: BorderRadius.circular(12),
                      //                   //   child: Stack(
                      //                   //     fit: StackFit.expand,
                      //                   //     children: [
                      //                   //       Image.network(
                      //                   //         service.gallery[3],
                      //                   //         fit: BoxFit.cover,
                      //                   //       ),

                      //                   //       // Glass Effect
                      //                   //       BackdropFilter(
                      //                   //         filter: ImageFilter.blur(
                      //                   //           sigmaX: 8,
                      //                   //           sigmaY: 8,
                      //                   //         ),
                      //                   //         child: Container(
                      //                   //           decoration: BoxDecoration(
                      //                   //             color: Colors.white
                      //                   //                 .withOpacity(0.15),
                      //                   //             borderRadius:
                      //                   //                 BorderRadius.circular(12),
                      //                   //             border: Border.all(
                      //                   //               color: Colors.white
                      //                   //                   .withOpacity(0.3),
                      //                   //               width: 1,
                      //                   //             ),
                      //                   //           ),
                      //                   //         ),
                      //                   //       ),

                      //                   //       Center(
                      //                   //         child: Text(
                      //                   //           '+$remainingCount',
                      //                   //           style: const TextStyle(
                      //                   //             color: Colors.white,
                      //                   //             fontSize: 28,
                      //                   //             fontWeight: FontWeight.bold,
                      //                   //             shadows: [
                      //                   //               Shadow(
                      //                   //                 blurRadius: 10,
                      //                   //                 color: Colors.black54,
                      //                   //               ),
                      //                   //             ],
                      //                   //           ),
                      //                   //         ),
                      //                   //       ),
                      //                   //     ],
                      //                   //   ),
                      //                   // ),
                      //                 ),
                      //               ),
                      //             );
                      //           }

                      //           //   return Expanded(
                      //           //     child: GestureDetector(
                      //           //       onTap: () {
                      //           //         final heroTag = 'gallery_image_$index';
                      //           //         _openImageViewer(
                      //           //           context,
                      //           //           service.gallery[3],
                      //           //           heroTag,
                      //           //           galleryImages: service.gallery,
                      //           //           initialIndex: index,
                      //           //         );
                      //           //       },
                      //           //       child: Container(
                      //           //         margin: const EdgeInsets.only(left: 8),
                      //           //         decoration: BoxDecoration(
                      //           //           color: const Color.fromARGB(
                      //           //             255,
                      //           //             255,
                      //           //             255,
                      //           //             255,
                      //           //           ),
                      //           //           borderRadius: BorderRadius.circular(
                      //           //             12,
                      //           //           ),
                      //           //           image: DecorationImage(
                      //           //             image: NetworkImage(
                      //           //               service.gallery[3],
                      //           //             ),
                      //           //             fit: BoxFit.cover,
                      //           //           ),
                      //           //         ),
                      //           //         child: Center(
                      //           //           child: Text(
                      //           //             '+$remainingCount',
                      //           //             style: const TextStyle(
                      //           //               color: Colors.white,
                      //           //               fontSize: 24,
                      //           //               fontWeight: FontWeight.bold,
                      //           //             ),
                      //           //           ),
                      //           //         ),
                      //           //       ),
                      //           //     ),
                      //           //   );
                      //           // }

                      //           final imageUrl = service.gallery[index];
                      //           final heroTag = 'gallery_image_$index';

                      //           return Expanded(
                      //             child: Padding(
                      //               padding: EdgeInsets.only(
                      //                 right: index < 2 ? 8 : 0,
                      //               ),
                      //               child: GestureDetector(
                      //                 onTap:
                      //                     () => _openImageViewer(
                      //                       context,
                      //                       imageUrl,
                      //                       heroTag,
                      //                       galleryImages: service.gallery,
                      //                       initialIndex: index,
                      //                     ),
                      //                 child: Hero(
                      //                   tag: heroTag,
                      //                   child: ClipRRect(
                      //                     borderRadius: BorderRadius.circular(
                      //                       12,
                      //                     ),
                      //                     child: Image.network(
                      //                       imageUrl,
                      //                       height: 100,
                      //                       width: 100,
                      //                       fit: BoxFit.cover,
                      //                       errorBuilder:
                      //                           (context, error, stackTrace) =>
                      //                               Container(
                      //                                 color: AppColors.surface,
                      //                                 child: const Icon(
                      //                                   Icons.broken_image,
                      //                                 ),
                      //                               ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // ],

                      // Gallery
                      // if (service.gallery.isNotEmpty) ...[
                      //   Text(
                      //     'Service Gallery',
                      //     style: AppTextStyles.labelLarge.copyWith(
                      //       color: Theme.of(context).colorScheme.onSurface,
                      //     ),
                      //   ),
                      //   const SizedBox(height: 12),
                      //   SizedBox(
                      //     height: 100,
                      //     child: ListView.builder(
                      //       scrollDirection: Axis.horizontal,
                      //       itemCount: service.gallery.length,
                      //       itemBuilder: (context, index) {
                      //         final imageUrl = service.gallery[index];
                      //         final heroTag = 'gallery_image_$index';
                      //         return Padding(
                      //           padding: const EdgeInsets.only(right: 12),
                      //           child: GestureDetector(
                      //             onTap:
                      //                 () => _openImageViewer(
                      //                   context,
                      //                   imageUrl,
                      //                   heroTag,
                      //                   galleryImages: service.gallery,
                      //                   initialIndex: index,
                      //                 ),
                      //             child: Hero(
                      //               tag: heroTag,
                      //               child: ClipRRect(
                      //                 borderRadius: BorderRadius.circular(12),
                      //                 child: Image.network(
                      //                   imageUrl,
                      //                   width: 140,
                      //                   height: 100,
                      //                   fit: BoxFit.cover,
                      //                   errorBuilder:
                      //                       (context, error, stackTrace) =>
                      //                           Container(
                      //                             width: 140,
                      //                             color: AppColors.surface,
                      //                             child: const Icon(
                      //                               Icons.broken_image,
                      //                             ),
                      //                           ),
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ],
                      if (_isLoadingProviderDetails)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_providerDetails != null) ...[
                        // const SizedBox(height: 24),
                        // const Divider(),
                        const SizedBox(height: 24),

                        // Stats
                        Row(
                          children: [
                            _buildStatItem(
                              Iconsax.verify,
                              'Verified',
                              'Identity',
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              Iconsax.message,
                              '${_providerDetails!.reviewsCount}',
                              'Reviews',
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              Iconsax.award,
                              _providerDetails!.experience.contains('Year')
                                  ? _providerDetails!.experience
                                  : '${_providerDetails!.experience} Years',
                              'Exp.',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // About me / Bio
                        // if (_providerDetails!.bio.isNotEmpty) ...[
                        //   Text(
                        //     'About Professional',
                        //     style: AppTextStyles.labelLarge.copyWith(
                        //       color: Theme.of(context).colorScheme.onSurface,
                        //     ),
                        //   ),
                        //   const SizedBox(height: 12),
                        //   Text(
                        //     _providerDetails!.bio,
                        //     style: AppTextStyles.bodyMedium.copyWith(
                        //       color: Theme.of(
                        //         context,
                        //       ).colorScheme.onSurface.withOpacity(0.7),
                        //       height: 1.5,
                        //     ),
                        //   ),
                        //   const SizedBox(height: 24),
                        // ],

                        // Services Offered
                        // if (_providerDetails!.servicesOffered.isNotEmpty) ...[
                        //   Text(
                        //     'Services Offered',
                        //     style: AppTextStyles.labelLarge.copyWith(
                        //       color: Theme.of(context).colorScheme.onSurface,
                        //     ),
                        //   ),
                        //   const SizedBox(height: 12),
                        //   Wrap(
                        //     spacing: 8,
                        //     runSpacing: 8,
                        //     children:
                        //         _providerDetails!.servicesOffered
                        //             .map(
                        //               (s) => _buildChip(s, AppColors.primary),
                        //             )
                        //             .toList(),
                        //   ),
                        //   const SizedBox(height: 24),
                        // ],

                        // Work Preference
                        if (_providerDetails!.workPreference.isNotEmpty) ...[
                          Text(
                            'Work Preference',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _providerDetails!.workPreference
                                    .map((s) => _buildChip(s, Colors.blue))
                                    .toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Preferred Work Locations
                        if (_providerDetails!
                            .workLocationPreferred
                            .isNotEmpty) ...[
                          Text(
                            'Preferred Work Locations',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _providerDetails!.workLocationPreferred.map((
                                  loc,
                                ) {
                                  String locName = '';
                                  try {
                                    if (loc is String) {
                                      if (loc.startsWith('{')) {
                                        final Map<String, dynamic> locMap =
                                            jsonDecode(loc);
                                        locName =
                                            locMap['location_name'] ??
                                            locMap['city'] ??
                                            loc;
                                      } else {
                                        locName = loc;
                                      }
                                    } else if (loc is Map) {
                                      locName =
                                          loc['location_name'] ??
                                          loc['city'] ??
                                          '';
                                    }
                                  } catch (_) {
                                    locName = loc.toString();
                                  }
                                  return _buildChip(locName, Colors.green);
                                }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Other services from this professional
                        Builder(
                          builder: (context) {
                            final providerServices =
                                provider.allServices
                                    .where(
                                      (s) =>
                                          s.providerId ==
                                              _providerDetails!.id &&
                                          s.id != service.id,
                                    )
                                    .toList();

                            if (providerServices.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Other Services by this Professional',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: providerServices.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final otherService =
                                        providerServices[index];
                                    return _buildServiceItem(
                                      context,
                                      otherService,
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Expanded(
                //   child: OutlinedButton(
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder:
                //               (context) => RequestQuotationScreen(
                //                 serviceId: service.id,
                //                 serviceName: service.name,
                //               ),
                //         ),
                //       );
                //     },
                //     style: OutlinedButton.styleFrom(
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //       side: const BorderSide(
                //         color: AppColors.primary,
                //         width: 2,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(16),
                //       ),
                //     ),
                //     child: const Text(
                //       'Request Quote',
                //       style: TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.bold,
                //         color: AppColors.primary,
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookingCheckoutScreen(
                                serviceName: service.name,
                                serviceId: service.id,
                                price: service.price,
                                serviceDescription: service.description,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCarousel(
    BuildContext context,
    ServiceProductModel service,
  ) {
    final List<String> allImages = [];
    if (service.image.isNotEmpty) {
      allImages.add(service.image);
    } else if (service.categoryImage.isNotEmpty) {
      allImages.add(service.categoryImage);
    }
    if (service.gallery.isNotEmpty) {
      allImages.addAll(service.gallery);
    }

    final uniqueImages = allImages.toSet().toList();

    if (uniqueImages.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: uniqueImages.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final imageUrl = uniqueImages[index];
            return GestureDetector(
              onTap:
                  () => _openImageViewer(
                    context,
                    imageUrl,
                    'header_image_$index',
                    galleryImages: uniqueImages,
                    initialIndex: index,
                    heroTagPrefix: 'header_image_',
                  ),
              child: Hero(
                tag: 'header_image_$index',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholder(),
                ),
              ),
            );
          },
        ),
        if (uniqueImages.length > 1)
          Positioned(
            bottom: 24, // Above the curved container in the body
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                uniqueImages.length,
                (index) => Container(
                  width: _currentImageIndex == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        _currentImageIndex == index
                            ? AppColors.primary
                            : Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Icon(Icons.image, size: 80, color: Colors.white),
    );
  }

  void _openImageViewer(
    BuildContext context,
    String imageUrl,
    String heroTag, {
    List<String>? galleryImages,
    int? initialIndex,
    String? heroTagPrefix,
  }) {
    print('galleryImages: $galleryImages');
    print('initialIndex: $initialIndex');
    print('heroTagPrefix: $heroTagPrefix');
    if (galleryImages != null &&
        galleryImages.isNotEmpty &&
        initialIndex != null) {
      print("----d");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder:
      //         (context) => FullScreenGalleryViewer(
      //           imagePaths: galleryImages,
      //           initialIndex: initialIndex,
      //           heroTagPrefix: heroTagPrefix ?? 'gallery_image_',
      //         ),
      //   ),
      // );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FullScreenGalleryViewer(
                imagePaths: galleryImages,
                initialIndex: initialIndex,
                heroTagPrefix: heroTagPrefix ?? 'gallery_image_',
              ),
        ),
      );
    } else {
      print('----dqqq');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FullScreenImageViewer(
                imagePath: imageUrl,
                tag: heroTag,
                isFile: true,
              ),
        ),
      );
    }
  }

  Widget _buildSkillChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C2E)
                  : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, ServiceProductModel service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceProductDetailScreen(service: service),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      service.image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.image,
                              color: AppColors.textTertiary,
                            ),
                          ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image, color: AppColors.primary),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${service.price}',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'View Details',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final double borderRadius;
  final VoidCallback onTap;
  final String? badge;

  const _GalleryTile({
    required this.imageUrl,
    required this.heroTag,
    required this.borderRadius,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image),
                    ),
              ),
              if (badge != null)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final String imageUrl;
  final int remainingCount;
  final double borderRadius;
  final VoidCallback onTap;

  const _MoreTile({
    required this.imageUrl,
    required this.remainingCount,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.72)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'more photos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
