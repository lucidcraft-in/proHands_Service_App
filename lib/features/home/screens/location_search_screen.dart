import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
// import '../../../core/widgets/gradient_button.dart';
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
  double _radius = 5.0; // km
  bool _isLocating = false;

  final List<double> _radiusOptions = [1, 3, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      // LocationPermission permission = await Geolocator.checkPermission();
      // if (permission == LocationPermission.denied) {
      //   permission = await Geolocator.requestPermission();
      // }

      // if (permission == LocationPermission.whileInUse ||
      //     permission == LocationPermission.always) {
      //   Position position = await Geolocator.getCurrentPosition();
      Position? position = await LocationService.getCurrentPosition(context);
      if (position != null) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
        _fetchNearbyServices();
      }
    } catch (e) {
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _fetchNearbyServices() {
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
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Iconsax.refresh, color: Colors.black),
                onPressed: _fetchNearbyServices,
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
              setState(() {
                _center = position.target;
              });
            },
            onCameraIdle: () {
              _fetchNearbyServices();
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

          // Center Pin (Fixed in middle)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),

          // Bottom Sheet / UI Overlay
          Align(alignment: Alignment.bottomCenter, child: _buildBottomUI()),

          if (_isLocating) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildBottomUI() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search around me', style: AppTextStyles.h4),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _radiusOptions.map((r) {
                          final isSelected = _radius == r;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${r.toInt()}km'),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _radius = r);
                                  _fetchNearbyServices();
                                }
                              },
                              selectedColor: AppColors.primary.withOpacity(0.2),
                              labelStyle: AppTextStyles.bodyMedium.copyWith(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.black,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : Colors.grey[300]!,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: Colors.white,
                    overlayColor: AppColors.primary.withOpacity(0.1),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: _radius,
                    min: 1,
                    max: 30,
                    onChanged: (value) {
                      setState(() => _radius = value);
                    },
                    onChangeEnd: (value) {
                      _fetchNearbyServices();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<ConsumerProvider>(
                  builder: (context, provider, child) {
                    if (provider.isFetchingNearLocation) {
                      return const Center(child: LinearProgressIndicator());
                    }
                    return Text(
                      '${provider.nearLocationResults.length} services found within ${_radius.toStringAsFixed(1)} km',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
                  child: Consumer<ConsumerProvider>(
                    builder: (context, provider, child) {
                      if (provider.nearLocationResults.isEmpty) {
                        return const Center(
                          child: Text('No services found in this area'),
                        );
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.nearLocationResults.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SizedBox(
                              width: 300,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
