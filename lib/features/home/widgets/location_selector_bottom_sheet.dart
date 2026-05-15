// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_styles.dart';
// import '../../../core/widgets/custom_button.dart';
// import '../../../core/services/location_service.dart';
// import '../../location/screens/map_selection_screen.dart';

// class LocationSelectorBottomSheet extends StatefulWidget {
//   final Function(Map<String, dynamic>) onLocationSelected;

//   const LocationSelectorBottomSheet({
//     super.key,
//     required this.onLocationSelected,
//   });

//   @override
//   State<LocationSelectorBottomSheet> createState() =>
//       _LocationSelectorBottomSheetState();
// }

// class _LocationSelectorBottomSheetState
//     extends State<LocationSelectorBottomSheet> {
//   final _searchController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _zipcodeController = TextEditingController();
//   final _localityController = TextEditingController(); // City
//   final _administrativeAreaController = TextEditingController(); // State
//   final _labelController = TextEditingController(text: 'My Location');
//   bool _isLoading = false;
//   List<double> _coordinates = [0.0, 0.0];
//   List<Map<String, dynamic>> _suggestions = [];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _addressController.dispose();
//     _zipcodeController.dispose();
//     _localityController.dispose();
//     _administrativeAreaController.dispose();
//     _labelController.dispose();
//     super.dispose();
//   }

//   void _submitLocation() {
//     if (_addressController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please enter an address')));
//       return;
//     }

//     final locationData = {
//       'address': _addressController.text,
//       'label': _labelController.text,
//       'zipcode': _zipcodeController.text,
//       'locality': _localityController.text,
//       'administrativeArea': _administrativeAreaController.text,
//       'coordinates': _coordinates,
//     };

//     widget.onLocationSelected(locationData);
//     Navigator.pop(context);
//   }

//   Future<void> _useCurrentLocation() async {
//     setState(() => _isLoading = true);

//     try {
//       // Check if location services are enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('Location services are disabled.'),
//               action: SnackBarAction(
//                 label: 'Enable',
//                 onPressed: () => Geolocator.openLocationSettings(),
//               ),
//             ),
//           );
//         }
//         setState(() => _isLoading = false);
//         return;
//       }

//       // Check location permissions
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Location permissions are denied')),
//             );
//           }
//           setState(() => _isLoading = false);
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text(
//                 'Location permissions are permanently denied. Please enable them in settings.',
//               ),
//               action: SnackBarAction(
//                 label: 'Settings',
//                 onPressed: () => Geolocator.openAppSettings(),
//               ),
//             ),
//           );
//         }
//         setState(() => _isLoading = false);
//         return;
//       }

//       final position = await LocationService.getCurrentPosition();

//       if (position != null) {
//         _coordinates = [position.latitude, position.longitude];
//         final addressData = await LocationService.getAddressFromLatLng(
//           position.latitude,
//           position.longitude,
//         );

//         if (addressData != null && mounted) {
//           setState(() {
//             _addressController.text = addressData['address'] ?? '';
//             _zipcodeController.text = addressData['zipcode'] ?? '';
//             _localityController.text = addressData['locality'] ?? '';
//             _administrativeAreaController.text =
//                 addressData['administrativeArea'] ?? '';
//             _labelController.text = 'Current Location';
//             _suggestions = [];
//           });
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 'Failed to get location. Please ensure GPS is on and permissions are granted.',
//               ),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _onSearchChanged(String query) async {
//     if (query.isEmpty) {
//       setState(() => _suggestions = []);
//       return;
//     }

//     final suggestions = await LocationService.getPlaceSuggestions(query);
//     if (mounted) {
//       setState(() => _suggestions = suggestions);
//     }
//   }

//   Future<void> _onSuggestionSelected(Map<String, dynamic> suggestion) async {
//     setState(() => _isLoading = true);
//     final placeId = suggestion['place_id'];
//     final description = suggestion['description'];

//     try {
//       final latLng = await LocationService.getLatLngFromPlaceId(placeId);
//       if (latLng != null) {
//         final addressData = await LocationService.getAddressFromLatLng(
//           latLng.latitude,
//           latLng.longitude,
//         );

//         if (mounted) {
//           setState(() {
//             _coordinates = [latLng.latitude, latLng.longitude];
//             _addressController.text = addressData?['address'] ?? description;
//             _zipcodeController.text = addressData?['zipcode'] ?? '';
//             _localityController.text = addressData?['locality'] ?? '';
//             _administrativeAreaController.text =
//                 addressData?['administrativeArea'] ?? '';
//             _labelController.text = 'Searched Location';
//             _suggestions = [];
//             _searchController.clear();
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error selecting place: $e')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _openMapPicker() async {
//     final LatLng initial = _coordinates[0] != 0
//         ? LatLng(_coordinates[0], _coordinates[1])
//         : const LatLng(10.0101, 76.3630);

//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MapSelectionScreen(initialLocation: initial),
//       ),
//     );

//     if (result != null && mounted) {
//       setState(() {
//         _coordinates = [result['latitude'], result['longitude']];
//         _addressController.text = result['address'];
//         _labelController.text = 'Pinned Location';
//         _suggestions = [];
//       });
//       // Optionally fetch full address details like zip/locality if needed,
//       // but MapSelectionScreen already provides a good address.
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.9,
//       ),
//       padding: EdgeInsets.only(
//         left: 20,
//         right: 20,
//         top: 20,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//       ),
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text('Select Location', style: AppTextStyles.h4),
//               const Spacer(),
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // Search Box
//           TextField(
//             controller: _searchController,
//             onChanged: _onSearchChanged,
//             decoration: InputDecoration(
//               hintText: 'Search for area, street name...',
//               prefixIcon: const Icon(Iconsax.search_normal, size: 20),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, size: 18),
//                       onPressed: () {
//                         _searchController.clear();
//                         _onSearchChanged('');
//                       },
//                     )
//                   : null,
//               filled: true,
//               fillColor: Theme.of(context).colorScheme.surface,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),

//           if (_suggestions.isNotEmpty)
//             Container(
//               constraints: const BoxConstraints(maxHeight: 200),
//               margin: const EdgeInsets.only(top: 8),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowLight,
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _suggestions.length,
//                 itemBuilder: (context, index) {
//                   final suggestion = _suggestions[index];
//                   return ListTile(
//                     leading: const Icon(Iconsax.location, size: 18),
//                     title: Text(
//                       suggestion['description'],
//                       style: AppTextStyles.bodySmall,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     onTap: () => _onSuggestionSelected(suggestion),
//                   );
//                 },
//               ),
//             ),

//           const SizedBox(height: 20),

//           Row(
//             children: [
//               Expanded(
//                 child: CustomButton(
//                   text: _isLoading ? 'Locating...' : 'Current Location',
//                   onPressed: _isLoading ? null : _useCurrentLocation,
//                   icon: _isLoading ? null : Iconsax.location,
//                   isLoading: _isLoading,
//                   isOutlined: true,
//                   width: double.infinity,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: CustomButton(
//                   text: 'Select on Map',
//                   onPressed: _isLoading ? null : _openMapPicker,
//                   icon: Iconsax.map,
//                   isOutlined: true,
//                   width: double.infinity,
//                 ),
//               ),
//             ],
//           ),

//           if (_addressController.text.isNotEmpty) ...[
//             const SizedBox(height: 24),
//             Text('Selected Location', style: AppTextStyles.labelLarge),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.surface,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: AppColors.primary.withOpacity(0.1)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.shadowLight,
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Iconsax.location,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _labelController.text,
//                           style: AppTextStyles.labelMedium.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _addressController.text,
//                           style: AppTextStyles.caption.copyWith(
//                             color: AppColors.textSecondary,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//             GradientButton(
//               text: 'Confirm Location',
//               onPressed: _submitLocation,
//               width: double.infinity,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/services/location_service.dart';
import '../../location/screens/map_selection_screen.dart';

class LocationSelectorBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;

  const LocationSelectorBottomSheet({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectorBottomSheet> createState() =>
      _LocationSelectorBottomSheetState();
}

class _LocationSelectorBottomSheetState
    extends State<LocationSelectorBottomSheet> {
  final _searchController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _localityController = TextEditingController(); // City
  final _administrativeAreaController = TextEditingController(); // State
  final _labelController = TextEditingController(text: 'My Location');
  bool _isLoading = false;
  List<double> _coordinates = [0.0, 0.0];
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void dispose() {
    _searchController.dispose();
    _addressController.dispose();
    _zipcodeController.dispose();
    _localityController.dispose();
    _administrativeAreaController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _submitLocation() {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an address')));
      return;
    }

    final locationData = {
      'address': _addressController.text,
      'label': _labelController.text,
      'zipcode': _zipcodeController.text,
      'locality': _localityController.text,
      'administrativeArea': _administrativeAreaController.text,
      'coordinates': _coordinates,
    };

    widget.onLocationSelected(locationData);
    Navigator.pop(context);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final position = await LocationService.getCurrentPosition(context);

      if (position != null) {
        _coordinates = [position.latitude, position.longitude];
        final addressData = await LocationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        if (addressData != null && mounted) {
          setState(() {
            _addressController.text = addressData['address'] ?? '';
            _zipcodeController.text = addressData['zipcode'] ?? '';
            _localityController.text = addressData['locality'] ?? '';
            _administrativeAreaController.text =
                addressData['administrativeArea'] ?? '';
            _labelController.text = 'Current Location';
            _suggestions = [];
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to get location. Please ensure GPS is on and permissions are granted.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final suggestions = await LocationService.getPlaceSuggestions(query);
    if (mounted) {
      setState(() => _suggestions = suggestions);
    }
  }

  Future<void> _onSuggestionSelected(Map<String, dynamic> suggestion) async {
    setState(() => _isLoading = true);
    final placeId = suggestion['place_id'];
    final description = suggestion['description'];

    try {
      final latLng = await LocationService.getLatLngFromPlaceId(placeId);
      if (latLng != null) {
        final addressData = await LocationService.getAddressFromLatLng(
          latLng.latitude,
          latLng.longitude,
        );

        if (mounted) {
          setState(() {
            _coordinates = [latLng.latitude, latLng.longitude];
            _addressController.text = addressData?['address'] ?? description;
            _zipcodeController.text = addressData?['zipcode'] ?? '';
            _localityController.text = addressData?['locality'] ?? '';
            _administrativeAreaController.text =
                addressData?['administrativeArea'] ?? '';
            _labelController.text = 'Searched Location';
            _suggestions = [];
            _searchController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting place: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openMapPicker() async {
    final LatLng initial =
        _coordinates[0] != 0
            ? LatLng(_coordinates[0], _coordinates[1])
            : const LatLng(10.0101, 76.3630);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(initialLocation: initial),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _coordinates = [result['latitude'], result['longitude']];
        _addressController.text = result['address'];
        _labelController.text = 'Pinned Location';
        _suggestions = [];
      });
      // Optionally fetch full address details like zip/locality if needed,
      // but MapSelectionScreen already provides a good address.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Select Location', style: AppTextStyles.h4),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search for area, street name...',
              prefixIcon: const Icon(Iconsax.search_normal, size: 20),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                      : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          if (_suggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Iconsax.location, size: 18),
                    title: Text(
                      suggestion['description'],
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _onSuggestionSelected(suggestion),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: _isLoading ? 'Locating...' : 'Current Location',
                  onPressed: _isLoading ? null : _useCurrentLocation,
                  icon: _isLoading ? null : Iconsax.location,
                  isLoading: _isLoading,
                  isOutlined: true,
                  width: double.infinity,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Select on Map',
                  onPressed: _isLoading ? null : _openMapPicker,
                  icon: Iconsax.map,
                  isOutlined: true,
                  width: double.infinity,
                ),
              ),
            ],
          ),

          if (_addressController.text.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Selected Location', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _labelController.text,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _addressController.text,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Confirm Location',
              onPressed: _submitLocation,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }
}
