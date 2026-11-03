import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/consumer_provider.dart';
import '../widgets/service_card_horizontal.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(11.5609697, 75.5989469); // Default location
  LatLng _cameraTarget = const LatLng(11.5609697, 75.5989469);
  double _radius = 5.0; // km
  bool _isLocating = false;
  bool _isBottomUIOpen = true;

  Timer? _debounceTimer;
  double? _lastFetchedLat;
  double? _lastFetchedLng;
  double? _lastFetchedRadius;

  final List<double> _radiusOptions = [1, 3, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLocating = true);
    try {
      Position? position = await LocationService.getCurrentPosition(context);
      if (!mounted) return;
      if (position != null) {
        final newCenter = LatLng(position.latitude, position.longitude);
        setState(() {
          _center = newCenter;
          _cameraTarget = newCenter;
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newCenter, zoom: 13),
          ),
        );
        _debouncedFetchNearbyServices(force: true);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _debouncedFetchNearbyServices({bool force = false}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (!force &&
          _lastFetchedLat != null &&
          _lastFetchedLng != null &&
          _lastFetchedRadius == _radius &&
          (_lastFetchedLat! - _center.latitude).abs() < 0.0001 &&
          (_lastFetchedLng! - _center.longitude).abs() < 0.0001) {
        return;
      }
      _lastFetchedLat = _center.latitude;
      _lastFetchedLng = _center.longitude;
      _lastFetchedRadius = _radius;
      _fetchNearbyServices();
    });
  }

  void _fetchNearbyServices() {
    if (!mounted) return;
    context.read<ConsumerProvider>().searchServicesNearLocation(
      latitude: _center.latitude,
      longitude: _center.longitude,
      radius: _radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color ?? Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: IconButton(
                icon: Icon(
                  Iconsax.refresh,
                  color: Theme.of(context).iconTheme.color ?? Colors.black,
                ),
                onPressed: () => _debouncedFetchNearbyServices(force: true),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 12),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              // Update camera target without calling setState continuously to prevent dragging jitter
              _cameraTarget = position.target;
            },
            onCameraIdle: () {
              if (_center.latitude != _cameraTarget.latitude ||
                  _center.longitude != _cameraTarget.longitude) {
                setState(() {
                  _center = _cameraTarget;
                });
              }
              _debouncedFetchNearbyServices();
            },
            circles: {
              Circle(
                circleId: const CircleId('search_radius'),
                center: _center,
                radius: _radius * 1000, // Convert km to meters
                fillColor: AppColors.primary.withOpacity(0.2),
                strokeColor: AppColors.primary,
                strokeWidth: 2,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Center Pin (Fixed in middle, IgnorePointer so touches pass through)
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_radius.toInt()} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Sheet / UI Overlay with Floating Location Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Floating GPS location button
                Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 12),
                  child: FloatingActionButton.small(
                    heroTag: 'map_current_loc_fab',
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 3,
                    onPressed: _isLocating ? null : _getCurrentLocation,
                    child: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.my_location,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                _buildBottomUI(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomUI() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: _isBottomUIOpen ? _buildOpenSheet() : _buildClosedSheet(),
      ),
    );
  }

  Widget _buildClosedSheet() {
    return GestureDetector(
      onTap: () => setState(() => _isBottomUIOpen = true),
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -100) {
          setState(() => _isBottomUIOpen = true);
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.radar_1,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<ConsumerProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Search around me',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            provider.isFetchingNearLocation
                                ? 'Searching nearby...'
                                : '${provider.nearLocationResults.length} services found (${_radius.toInt()} km)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => setState(() => _isBottomUIOpen = true),
                  icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
                  label: const Text('Open'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle & Header
        GestureDetector(
          onTap: () => setState(() => _isBottomUIOpen = false),
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 100) {
              setState(() => _isBottomUIOpen = false);
            }
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.radar_1,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Search around me',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                  ),
                ),
                tooltip: 'Close',
                onPressed: () => setState(() => _isBottomUIOpen = false),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _radiusOptions.map((r) {
                    final isSelected = _radius == r;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${r.toInt()} km'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _radius = r);
                            _debouncedFetchNearbyServices(force: true);
                          }
                        },
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        labelStyle: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.3),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor:
                      Theme.of(context).dividerColor.withOpacity(0.2),
                  thumbColor: Colors.white,
                  overlayColor: AppColors.primary.withOpacity(0.1),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  value: _radius,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '${_radius.toInt()} km',
                  onChanged: (value) {
                    setState(() => _radius = value);
                  },
                  onChangeEnd: (value) {
                    _debouncedFetchNearbyServices(force: true);
                  },
                ),
              ),
              const SizedBox(height: 6),
              Consumer<ConsumerProvider>(
                builder: (context, provider, child) {
                  if (provider.isFetchingNearLocation) {
                    return Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Searching nearby services...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }
                  if (provider.nearLocationError != null) {
                    return Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            provider.nearLocationError!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _debouncedFetchNearbyServices(force: true),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  return Text(
                    '${provider.nearLocationResults.length} services found within ${_radius.toInt()} km',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 125,
                child: Consumer<ConsumerProvider>(
                  builder: (context, provider, child) {
                    if (provider.isFetchingNearLocation) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.nearLocationResults.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.info_circle,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No services found within ${_radius.toInt()} km',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.nearLocationResults.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 290,
                            child: ServiceCardHorizontal(
                              service: provider.nearLocationResults[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
