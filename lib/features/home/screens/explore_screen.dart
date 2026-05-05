import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../cart/screens/cart_screen.dart';
import '../providers/consumer_provider.dart';
import '../models/service_product_model.dart';
import 'service_product_detail_screen.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/getCurrentLocation.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  Timer? _debounce;
  Timer? _locationDebounce;
  bool _isSearchActive = false;
  bool _isLocationActive = false;
  bool _isLocationSearchDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();

    // Auto-fetch current location results on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useCurrentLocation();
      context.read<ConsumerProvider>().fetchLeaderboard();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _locationController.dispose();
    _debounce?.cancel();
    _locationDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearchActive = query.isNotEmpty;
        });
        context.read<ConsumerProvider>().searchServices(query);
      }
    });
  }

  void _onLocationChanged(String query) {
    if (_locationDebounce?.isActive ?? false) _locationDebounce!.cancel();
    _locationDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLocationSearchDropdownVisible = query.isNotEmpty;
          _isLocationActive = query.isNotEmpty;
        });
        context.read<ConsumerProvider>().fetchLocationSuggestions(query);
      }
    });
  }

  void _selectLocation(String description, String placeId) async {
    setState(() {
      _locationController.text = description;
      _isLocationSearchDropdownVisible = false;
    });

    final latLng = await LocationService.getLatLngFromPlaceId(placeId);
    if (latLng != null && mounted) {
      context.read<ConsumerProvider>().fetchServicesNearLocation(
        latLng.latitude,
        latLng.longitude,
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final latLng = await getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationController.text = "Current Location";
          _isLocationSearchDropdownVisible = false;
          _isLocationActive = true;
        });
        context.read<ConsumerProvider>().fetchServicesNearLocation(
          latLng.latitude,
          latLng.longitude,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
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
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Iconsax.shopping_cart,
        //       color: AppColors.textPrimary,
        //     ),
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(builder: (context) => const CartScreen()),
        //       );
        //     },
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: Consumer<ConsumerProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
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
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search for services...',
                          prefixIcon: const Icon(
                            Iconsax.search_normal,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textTertiary,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                  : null,
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).dividerColor.withOpacity(0.3),
                      ),
                      TextField(
                        controller: _locationController,
                        onChanged: _onLocationChanged,
                        decoration: InputDecoration(
                          hintText: 'Near Location...',
                          prefixIcon: const Icon(
                            Iconsax.location,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_locationController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.textTertiary,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _locationController.clear();
                                    _onLocationChanged('');
                                    provider.clearLocationSearch();
                                  },
                                ),
                              IconButton(
                                icon: const Icon(
                                  Iconsax.gps,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                onPressed: _useCurrentLocation,
                              ),
                            ],
                          ),
                          border: InputBorder.none,
                          hintStyle: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Location suggestions dropdown
                if (_isLocationSearchDropdownVisible &&
                    provider.locationSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: provider.locationSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = provider.locationSuggestions[index];
                        return ListTile(
                          leading: const Icon(
                            Iconsax.location,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          title: Text(
                            suggestion['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            _selectLocation(
                              suggestion['description'],
                              suggestion['place_id'],
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                if (_isSearchActive || _isLocationActive) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isLocationActive
                            ? 'Services Near Location'
                            : 'Suggested',
                        style: AppTextStyles.h4,
                      ),
                      if (provider.isSearching ||
                          provider.isFetchingNearLocation)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if ((provider.isSearching &&
                          provider.searchResults.isEmpty) ||
                      (provider.isFetchingNearLocation &&
                          provider.nearLocationResults.isEmpty))
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('Searching...'),
                      ),
                    )
                  else if (_isLocationActive &&
                      provider.nearLocationResults.isEmpty &&
                      !provider.isFetchingNearLocation)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No services found in this location'),
                      ),
                    )
                  else if (_isSearchActive &&
                      provider.searchResults.isEmpty &&
                      !provider.isSearching)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No services found'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          _isLocationActive
                              ? provider.nearLocationResults.length
                              : provider.searchResults.length,
                      itemBuilder: (context, index) {
                        final service =
                            _isLocationActive
                                ? provider.nearLocationResults[index]
                                : provider.searchResults[index];
                        return _SearchServiceCard(service: service);
                      },
                    ),
                ] else ...[
                  // Customer Leaderboard Section
                  Center(
                    child: Text(
                      'Leaderboard',
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 22,
                        color: const Color(0xFF8B4513),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (provider.isLoadingLeaderboard &&
                      provider.leaderboard.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (provider.leaderboardError != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Error: ${provider.leaderboardError}',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    )
                  else if (provider.leaderboard.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No leaderboard data available'),
                      ),
                    )
                  else ...[
                    // Podium for Top 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Rank 2
                        if (provider.leaderboard.length >= 2)
                          _buildPodiumItem(
                            user: provider.leaderboard[1],
                            rank: 2,
                            color: const Color(0xFFF2786D),
                            size: 80,
                          ),
                        const SizedBox(width: 12),
                        // Rank 1
                        if (provider.leaderboard.isNotEmpty)
                          _buildPodiumItem(
                            user: provider.leaderboard[0],
                            rank: 1,
                            color: const Color(0xFFF2786D),
                            size: 100,
                            hasCrown: true,
                          ),
                        const SizedBox(width: 12),
                        // Rank 3
                        if (provider.leaderboard.length >= 3)
                          _buildPodiumItem(
                            user: provider.leaderboard[2],
                            rank: 3,
                            color: const Color(0xFFF2786D),
                            size: 70,
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Rest of the list
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            provider.leaderboard.length > 3
                                ? provider.leaderboard.length - 3
                                : 0,
                        itemBuilder: (context, index) {
                          final user = provider.leaderboard[index + 3];
                          final rank = index + 4;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF2786D).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  rank.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFF2786D),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    user.name ?? 'Guest',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${user.points} pts',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF6B4226),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodiumItem({
    required UserModel user,
    required int rank,
    required Color color,
    required double size,
    bool hasCrown = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: ClipOval(
                      child: Container(
                        color: color,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, 10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B4226),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        rank.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasCrown)
              Transform.translate(
                offset: const Offset(0, -5),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFF6B4226),
                  size: 24,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name ?? 'Guest',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          '${user.points} pts',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFF2786D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SearchServiceCard extends StatelessWidget {
  final ServiceProductModel service;

  const _SearchServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ServiceProductDetailScreen(service: service),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  service.image.isNotEmpty
                      ? Image.network(
                        service.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 70,
                              height: 70,
                              color: AppColors.background,
                              child: const Icon(
                                Icons.broken_image,
                                color: AppColors.textTertiary,
                              ),
                            ),
                      )
                      : Container(
                        width: 70,
                        height: 70,
                        color: AppColors.background,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.textTertiary,
                        ),
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        service.rating > 0
                            ? service.rating.toStringAsFixed(1)
                            : 'New',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service.providerName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
