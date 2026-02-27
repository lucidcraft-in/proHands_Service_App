import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/services/location_service.dart';

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
  final _addressController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _localityController = TextEditingController(); // City
  final _administrativeAreaController = TextEditingController(); // State
  final _labelController = TextEditingController(text: 'My Location');
  bool _isLoading = false;
  List<double> _coordinates = [0.0, 0.0];

  @override
  void dispose() {
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
    debugPrint('Use Current Location tapped');
    setState(() => _isLoading = true);

    try {
      final position = await LocationService.getCurrentPosition();
      debugPrint('Position result: $position');

      if (position != null) {
        _coordinates = [position.latitude, position.longitude];
        final addressData = await LocationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );
        debugPrint('Address result: $addressData');

        if (addressData != null && mounted) {
          setState(() {
            _addressController.text = addressData['address'] ?? '';
            _zipcodeController.text = addressData['zipcode'] ?? '';
            _localityController.text = addressData['locality'] ?? '';
            _administrativeAreaController.text =
                addressData['administrativeArea'] ?? '';
            _labelController.text = 'Current Location';
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
      debugPrint('Exception in _useCurrentLocation: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Loading state set to false');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
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
          CustomButton(
            text: _isLoading ? 'Fetching Location...' : 'Use Current Location',
            onPressed: _isLoading ? null : _useCurrentLocation,
            icon: _isLoading ? null : Iconsax.location,
            isLoading: _isLoading,
            isOutlined: true,
            width: double.infinity,
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text('Or Enter Manual Address', style: AppTextStyles.labelLarge),
          const SizedBox(height: 16),
          CustomTextField(
            hint: 'Location Label (e.g. Home, Office)',
            controller: _labelController,
            prefixIcon: const Icon(Iconsax.tag),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            hint: 'Full Address',
            controller: _addressController,
            prefixIcon: const Icon(Iconsax.location),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'City',
                  controller: _localityController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  hint: 'State',
                  controller: _administrativeAreaController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            hint: 'Zipcode',
            controller: _zipcodeController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Confirm Location',
            onPressed: _submitLocation,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
