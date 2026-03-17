import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../home/providers/consumer_provider.dart';
import '../../home/screens/main_screen.dart';

class LocationFetchScreen extends StatefulWidget {
  const LocationFetchScreen({super.key});

  @override
  State<LocationFetchScreen> createState() => _LocationFetchScreenState();
}

class _LocationFetchScreenState extends State<LocationFetchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _status = 'Fetching your location...';
  bool _isFetching = false;
  bool _isFetched = false;
  double? _lat;
  double? _lng;
  String? _address;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
      _isFetched = false;
      _status = 'Locating...';
    });
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final addressData = await LocationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        if (mounted) {
          setState(() {
            _lat = position.latitude;
            _lng = position.longitude;
            _address = addressData?['address'] ?? 'Current Location';
            _status = 'Location found';
            _isFetched = true;
          });
        }
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _confirmLocation() async {
    if (!_isFetched || _address == null) return;

    setState(() {
      _isFetching = true;
      _status = 'Updating profile...';
    });

    try {
      // Update via API
      await context.read<ConsumerProvider>().updateUserLocation(
        latitude: _lat!,
        longitude: _lng!,
        address: _address!,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  void _handleError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch location. Please check permissions.'),
        ),
      );
      setState(() => _status = 'Tap icon to try again');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isFetched ? _confirmLocation : _fetchLocation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFetched
                        ? Iconsax.location_tick
                        : (_isFetching ? Iconsax.location : Iconsax.location),
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _isFetched ? 'Confirm Location' : 'Location Access',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_address != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _address!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tap the icon to continue',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
