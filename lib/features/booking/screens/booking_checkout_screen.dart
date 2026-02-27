import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';

import '../../home/widgets/location_selector_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../home/providers/consumer_provider.dart';
import 'package:intl/intl.dart';
import '../../../core/services/storage_service.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  final double price;

  const BookingCheckoutScreen({
    super.key,
    required this.serviceName,
    required this.serviceId,
    required this.price,
  });

  @override
  State<BookingCheckoutScreen> createState() => _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState extends State<BookingCheckoutScreen> {
  String _selectedLocationAddress = 'Loading location...';
  String _selectedLocationLabel = 'Current Location';
  String? _selectedZipcode;
  String? _selectedLocality;
  String? _selectedAdministrativeArea;
  List<double> _selectedCoordinates = [0.0, 0.0];
  String _selectedPaymentMethod = 'Credit Card';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final locationData = await StorageService.getUserLocation();
      if (locationData != null && locationData['address'] != null) {
        if (mounted) {
          setState(() {
            _selectedLocationAddress = locationData['address'];
            _selectedLocationLabel = locationData['label'] ?? 'Saved Location';
            _selectedZipcode = locationData['zipcode'];
            _selectedLocality = locationData['locality'];
            _selectedAdministrativeArea = locationData['administrativeArea'];
            if (locationData['coordinates'] != null) {
              _selectedCoordinates = List<double>.from(
                locationData['coordinates'],
              );
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedLocationAddress = 'Select a location to proceed';
            _selectedLocationLabel = 'No Location Selected';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading location: $e');
      if (mounted) {
        setState(() {
          _selectedLocationAddress = 'Select a location';
          _selectedLocationLabel = 'Error Loading';
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => LocationSelectorBottomSheet(
            onLocationSelected: (locationData) {
              setState(() {
                _selectedLocationAddress = locationData['address'] ?? '';
                _selectedLocationLabel =
                    locationData['label'] ?? 'Selected Location';
                _selectedZipcode = locationData['zipcode'];
                _selectedLocality = locationData['locality'];
                _selectedAdministrativeArea =
                    locationData['administrativeArea'];
                if (locationData['coordinates'] != null) {
                  _selectedCoordinates = List<double>.from(
                    locationData['coordinates'],
                  );
                }
              });
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Booking Details', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Summary Card
            Text('Service Selected', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.setting_5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceName,
                          style: AppTextStyles.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Professional Service',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Location Section
            Text('Service Location', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showLocationSelector,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                  ), // Fixed withOpacity
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        0.05,
                      ), // Fixed withOpacity
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(
                          0.1,
                        ), // Fixed withOpacity
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.location,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedLocationLabel, // Display Label (Place Name)
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold, // Bold Label
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedLocationAddress, // Display Address
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Iconsax.edit_2,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Payment Method
            Text('Payment Method', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            _buildPaymentOption('Credit Card', Iconsax.card),
            const SizedBox(height: 12),
            _buildPaymentOption('Wallet', Iconsax.wallet),
            const SizedBox(height: 12),
            _buildPaymentOption('Cash on Service', Iconsax.money),

            const SizedBox(height: 40),

            GradientButton(
              text: _isProcessing ? 'Confirming...' : 'Book Now',
              onPressed: _isProcessing ? null : _handleBooking,
              isLoading: _isProcessing,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBooking() async {
    setState(() => _isProcessing = true);

    try {
      final consumerProvider = Provider.of<ConsumerProvider>(
        context,
        listen: false,
      );
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final formattedTime = _selectedTime.format(context);

      // Construct address string preference by user: "Locality, AdministrativeArea - Zipcode"
      // Example: "Mesa, New Jersey - 45463"
      String finalAddress = _selectedLocationAddress;
      if (_selectedLocality != null &&
          _selectedAdministrativeArea != null &&
          _selectedZipcode != null &&
          _selectedLocality!.isNotEmpty &&
          _selectedAdministrativeArea!.isNotEmpty &&
          _selectedZipcode!.isNotEmpty) {
        finalAddress =
            '$_selectedLocality, $_selectedAdministrativeArea - $_selectedZipcode';
      } else if (_selectedZipcode != null && _selectedZipcode!.isNotEmpty) {
        // Fallback to "Label, Zipcode" if not all details present
        finalAddress = '$_selectedLocationLabel, $_selectedZipcode';
      }

      final success = await consumerProvider.createBooking(
        serviceId: widget.serviceId,
        date: formattedDate,
        time: formattedTime,
        address: finalAddress,
        coordinates: _selectedCoordinates, // Use selected coordinates
      );

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text('Booking Successful!', style: AppTextStyles.h4),
                    const SizedBox(height: 8),
                    Text(
                      'Your service has been scheduled.\nLocation: $_selectedLocationAddress',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      text: 'View Booking',
                      onPressed: () {
                        Navigator.of(context).pop(); // Pop dialog
                        Navigator.of(context).pop(); // Pop checkout
                        // Ideally navigate to bookings tab
                      },
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              consumerProvider.createBookingError ?? 'Booking failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    }
  }
}
