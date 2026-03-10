import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
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
          if (_addressController.text.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Selected Location', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
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
