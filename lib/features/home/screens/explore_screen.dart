import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/expert_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../providers/consumer_provider.dart';
import '../models/service_product_model.dart';
import '../services/consumer_service.dart';
import 'service_product_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLeaderboardExpanded = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _controller.forward();

    // Fetch leaderboard on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsumerProvider>().fetchLeaderboard(true);
      context.read<ConsumerProvider>().fetchTrendingServices();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Explore',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Inter',
          ),
        ),

        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),

      body: Consumer<ConsumerProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Autocomplete<ServiceProductModel>(
                    displayStringForOption: (option) => option.name,

                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.trim().isEmpty) {
                        return const Iterable<ServiceProductModel>.empty();
                      }

                      await provider.searchServices(textEditingValue.text);

                      if (provider.searchResults.isEmpty) {
                        return [
                          ServiceProductModel(
                            id: 'empty',
                            name: 'No services found',
                            description: '',
                            price: 0,
                            duration: 0,
                            providerName: '',
                            providerImage: '',
                            providerId: '',
                            image: '',
                          ),
                        ];
                      }

                      return provider.searchResults;
                    },

                    onSelected: (ServiceProductModel selection) {
                      if (selection.id == 'empty') {
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ServiceProductDetailScreen(
                                service: selection,
                              ),
                        ),
                      );
                    },

                    fieldViewBuilder: (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextField(
                        controller: textEditingController,

                        focusNode: focusNode,

                        decoration: InputDecoration(
                          hintText: 'Search for services...',

                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),

                          suffixIcon:
                              textEditingController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textTertiary,
                                      size: 20,
                                    ),

                                    onPressed: () {
                                      textEditingController.clear();
                                    },
                                  )
                                  : null,

                          border: InputBorder.none,

                          hintStyle: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },

                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,

                        child: Material(
                          elevation: 10,

                          borderRadius: BorderRadius.circular(16),

                          child: Container(
                            width: MediaQuery.of(context).size.width - 40,

                            constraints: const BoxConstraints(maxHeight: 300),

                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,

                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: ListView.builder(
                              padding: EdgeInsets.zero,

                              shrinkWrap: true,

                              itemCount: options.length,

                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);

                                if (option.id == 'empty') {
                                  return ListTile(
                                    title: Center(
                                      child: Text(
                                        option.name,

                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textSecondary,

                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                    ),
                                  );
                                }

                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),

                                    child:
                                        option.image.isNotEmpty
                                            ? Image.network(
                                              option.image,

                                              width: 50,
                                              height: 50,

                                              fit: BoxFit.cover,

                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 50,
                                                    height: 50,

                                                    color: AppColors.background,

                                                    child: const Icon(
                                                      Icons.broken_image,
                                                    ),
                                                  ),
                                            )
                                            : Container(
                                              width: 50,
                                              height: 50,

                                              color: AppColors.background,

                                              child: const Icon(Icons.image),
                                            ),
                                  ),

                                  title: Text(
                                    option.name,

                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  subtitle: Text(
                                    option.providerName,

                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),

                                  // trailing: Text(
                                  //   '₹${option.price}',

                                  // style: AppTextStyles.bodySmall.copyWith(
                                  //   fontWeight: FontWeight.bold,

                                  //   color: AppColors.primary,
                                  // ),
                                  // ),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildExpandableLeaderboard(provider),
                const SizedBox(height: 32),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Trending Technicians', style: AppTextStyles.h4),
                //   ],
                // ),
                // Consumer<ConsumerProvider>(
                //   builder: (context, provider, child) {
                //     if (provider.isLoadingTrendingServices) {
                //       return ListView.builder(
                //         shrinkWrap: true,
                //         physics: const NeverScrollableScrollPhysics(),
                //         itemCount: 3,
                //         itemBuilder:
                //             (context, index) => const ListCardShimmer(),
                //       );
                //     }

                //     if (provider.trendingServicesError != null) {
                //       return Center(
                //         child: Text(
                //           'Error: ${provider.trendingServicesError}',
                //           style: const TextStyle(color: Colors.red),
                //         ),
                //       );
                //     }

                //     if (provider.trendingServices.isEmpty) {
                //       return const EmptyStateWidget(
                //         icon: Iconsax.user_tag,
                //         title: 'No Trending Technicians',
                //         subtitle:
                //             'We couldn\'t find any trending technicians at the moment. Check back soon!',
                //         iconSize: 48,
                //       );
                //     }

                //     return ListView.builder(
                //       shrinkWrap: true,
                //       physics: const NeverScrollableScrollPhysics(),
                //       itemCount: provider.trendingServices.length,
                //       itemBuilder: (context, index) {
                //         final service = provider.trendingServices[index];
                //         return AnimatedBuilder(
                //           animation: _controller,
                //           builder: (context, child) {
                //             final delay = 0.4 + (index * 0.1);
                //             final curve = CurvedAnimation(
                //               parent: _controller,
                //               curve: Interval(
                //                 delay.clamp(0.0, 1.0),
                //                 (delay + 0.5).clamp(0.0, 1.0),
                //                 curve: Curves.easeOut,
                //               ),
                //             );
                //             return Opacity(
                //               opacity: curve.value,
                //               child: Transform.translate(
                //                 offset: Offset(0, 30 * (1 - curve.value)),
                //                 child: child,
                //               ),
                //             );
                //           },
                //           child: Padding(
                //             padding: const EdgeInsets.only(bottom: 16),
                //             child: ExpertCard(
                //               name: service.providerName,
                //               image: service.providerImage,
                //               profession: service.profession,
                //               rating: service.rating,
                //               reviews: service.reviewsCount,
                //               onTap: () {
                //                 // Construct a partial UserModel to navigate
                //                 final providerUser = UserModel(
                //                   id: service.providerId,
                //                   name: service.providerName,
                //                   phone: '', // Not available in service model
                //                   userType: UserType.serviceBoy,
                //                   profession: service.profession,
                //                   rating: service.rating,
                //                   reviewsCount: service.reviewsCount,
                //                   serviceImage: service.image,
                //                   // Add other fields with default/empty values
                //                 );
                //                 navigateToProviderDetail(providerUser);
                //               },
                //             ),
                //           ),
                //         );
                //       },
                //     );
                //   },
                // ),

                // const SizedBox(height: 32),

                /// FEATURED
                Text('Featured', style: AppTextStyles.h4),

                const SizedBox(height: 16),

                SizedBox(
                  height: 200,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,

                    itemCount: 3,

                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> exploreItems = [
                        {
                          'title': 'Home Deep Cleaning',
                          'subtitle': 'Top Choice this week',
                          'image': 'assets/images/cleaning_service.png',
                          'color': const Color(0xFF4A90E2),
                        },

                        {
                          'title': 'Express AC Service',
                          'subtitle': 'Professional Care',
                          'image': 'assets/images/ac_repair_service.png',
                          'color': const Color(0xFFF5A623),
                        },

                        {
                          'title': 'Professional Painting',
                          'subtitle': 'Wall to Wall perfection',
                          'image': 'assets/images/painting_service.png',
                          'color': const Color(0xFF7ED321),
                        },
                      ];

                      final item = exploreItems[index];

                      return Container(
                        width: 280,

                        margin: const EdgeInsets.only(right: 16),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),

                              blurRadius: 10,

                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),

                          child: Stack(
                            children: [
                              Image.asset(
                                item['image'],

                                width: double.infinity,

                                height: double.infinity,

                                fit: BoxFit.cover,
                              ),

                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,

                                    end: Alignment.centerRight,

                                    colors: [
                                      Colors.black.withOpacity(0.8),

                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(20),

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),

                                      decoration: BoxDecoration(
                                        color: item['color'],

                                        borderRadius: BorderRadius.circular(8),
                                      ),

                                      child: const Text(
                                        'FEATURED',

                                        style: TextStyle(
                                          color: Colors.white,

                                          fontSize: 10,

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      item['title'],

                                      style: AppTextStyles.h4.copyWith(
                                        color: Colors.white,

                                        fontSize: 18,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      item['subtitle'],

                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
                Text('New Arrivals', style: AppTextStyles.h4),
                const SizedBox(height: 16),

                // New Arrivals List (Existing Code)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final List<Map<String, dynamic>> newArrivals = [
                      {
                        'title': 'Smart Home Installation',
                        'subtitle':
                            'Upgrade your living space with smart tech.',
                        'image': 'assets/images/smart_home_install.png',
                      },
                      {
                        'title': 'Garden Maintenance',
                        'subtitle': 'Keep your garden green and healthy.',
                        'image': 'assets/images/garden_maintenance.png',
                      },
                      {
                        'title': 'Premium Kitchen Cleaning',
                        'subtitle':
                            'Get your kitchen spotless with our expert team.',
                        'image': 'assets/images/cleaning_service.png',
                      },
                    ];
                    final item = newArrivals[index];

                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final delay = 0.3 + (index * 0.1);
                        final curve = CurvedAnimation(
                          parent: _controller,
                          curve: Interval(
                            delay.clamp(0.0, 1.0),
                            (delay + 0.5).clamp(0.0, 1.0),
                            curve: Curves.easeOut,
                          ),
                        );
                        return Opacity(
                          opacity: curve.value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - curve.value)),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: AssetImage(item['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: AppTextStyles.h4.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle'],
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void navigateToProviderDetail(UserModel userData) {
    ServiceProductDetailScreen.navigateWithProviderId(context, userData.id);
  }

  Widget _buildExpandableLeaderboard(ConsumerProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isLeaderboardExpanded = !_isLeaderboardExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.cup,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Leaderboard',
                          style: AppTextStyles.h4.copyWith(fontSize: 16),
                        ),
                        Text(
                          'Top performing partners this month',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isLeaderboardExpanded
                        ? Iconsax.arrow_up_1
                        : Iconsax.arrow_down_1,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isLeaderboardExpanded) ...[
            const Divider(height: 1),
            if (provider.isLoadingLeaderboard && provider.leaderboard.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.leaderboard.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No leaderboard data available')),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Podium
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (provider.leaderboard.length >= 2)
                          _buildPodiumItem(
                            user: provider.leaderboard[1],
                            rank: 2,
                            size: 70,
                          ),
                        const SizedBox(width: 16),
                        if (provider.leaderboard.isNotEmpty)
                          _buildPodiumItem(
                            user: provider.leaderboard[0],
                            rank: 1,
                            size: 90,
                            isFirst: true,
                          ),
                        const SizedBox(width: 16),
                        if (provider.leaderboard.length >= 3)
                          _buildPodiumItem(
                            user: provider.leaderboard[2],
                            rank: 3,
                            size: 60,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          provider.leaderboard.length > 3
                              ? provider.leaderboard.length - 3
                              : 0,
                      itemBuilder: (context, index) {
                        final user = provider.leaderboard[index + 3];
                        return _buildLeaderboardTile(user, index + 4);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required UserModel user,
    required int rank,
    required double size,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFirst ? Colors.amber : Colors.grey.shade300,
                  width: 3,
                ),
                boxShadow:
                    isFirst
                        ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: ClipOval(
                child:
                    user.profilePhoto.isNotEmpty
                        ? Image.network(
                          user.profilePhoto,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Iconsax.user, size: 30),
                        )
                        : const Icon(Iconsax.user, size: 30),
              ),
            ),
            if (isFirst)
              Positioned(
                top: -10,
                child: const Icon(Iconsax.crown, color: Colors.amber, size: 24),
              ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isFirst ? Colors.amber : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name ?? 'Partner',
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user.points} pts',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(UserModel user, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textTertiary,
              ),
            ),
          ),

          CircleAvatar(
            radius: 16,
            // backgroundImage:
            //     user.profilePhoto.isNotEmpty
            //         ? NetworkImage(user.profilePhoto)
            //         : null,
            child:
                user.profilePhoto.isNotEmpty
                    ? Image.network(
                      user.profilePhoto,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Iconsax.user, size: 16),
                    )
                    : const Icon(Iconsax.user, size: 16),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.name ?? 'Partner',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${user.points} pts',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
