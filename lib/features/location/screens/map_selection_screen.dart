import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/custom_button.dart';

class MapSelectionScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapSelectionScreen({super.key, this.initialLocation});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;
  String _address = 'Fetching address...';
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? const LatLng(10.0101, 76.3630); // Default to Kochi if not provided
    if (widget.initialLocation != null) {
      _fetchAddress(widget.initialLocation!);
    }
  }

  Future<void> _fetchAddress(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
      _address = 'Fetching address...';
    });

    try {
      final addressData = await LocationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _address = addressData?['address'] ?? 'Unknown location';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'Error fetching address';
          _isLoadingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location', style: AppTextStyles.h4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              setState(() {
                _selectedLocation = position.target;
              });
            },
            onCameraIdle: () {
              if (_selectedLocation != null) {
                _fetchAddress(_selectedLocation!);
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          // Center Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: Icon(
                Iconsax.location5,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.location,
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
                                'Selected Address',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _address,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      text: 'Confirm Location',
                      onPressed: _isLoadingAddress ? null : () {
                        Navigator.pop(context, {
                          'latitude': _selectedLocation!.latitude,
                          'longitude': _selectedLocation!.longitude,
                          'address': _address,
                        });
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 20,
            bottom: 220,
            child: FloatingActionButton(
              onPressed: () async {
                final pos = await LocationService.getCurrentPosition();
                if (pos != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(pos.latitude, pos.longitude),
                    ),
                  );
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: const Icon(Iconsax.gps, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
