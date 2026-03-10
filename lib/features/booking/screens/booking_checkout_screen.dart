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
  List<double> _selectedCoordinates = [0.0, 0.0];
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  final _houseNameController = TextEditingController();
  final _placeController = TextEditingController();
  final _zipcodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _houseNameController.dispose();
    _placeController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

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
            _placeController.text = locationData['locality'] ?? '';
            _zipcodeController.text = locationData['zipcode'] ?? '';
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
                _placeController.text = locationData['locality'] ?? '';
                _zipcodeController.text = locationData['zipcode'] ?? '';
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

            const SizedBox(height: 24),

            // Detailed Address Fields
            Text('Detailed Address', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildAddressField(
                    controller: _houseNameController,
                    label: 'House Name / Number',
                    hint: 'e.g. Flat 101, Green Villa',
                    icon: Iconsax.home,
                  ),
                  const SizedBox(height: 16),
                  _buildAddressField(
                    controller: _placeController,
                    label: 'Place / Locality',
                    hint: 'e.g. MG Road, Sector 5',
                    icon: Iconsax.location,
                  ),
                  const SizedBox(height: 16),
                  _buildAddressField(
                    controller: _zipcodeController,
                    label: 'Zip Code',
                    hint: 'e.g. 560001',
                    icon: Iconsax.code,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Schedule Section
            Text('Schedule Service', style: AppTextStyles.labelLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.calendar,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Date',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('EEE, MMM d').format(_selectedDate),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.clock,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Time',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTime.format(context),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

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

  Widget _buildAddressField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
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

      // Construct address string divided by comma
      final houseName = _houseNameController.text.trim();
      final place = _placeController.text.trim();
      final zipcode = _zipcodeController.text.trim();

      if (place.isEmpty || zipcode.isEmpty) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter place and zipcode')),
        );
        return;
      }

      final List<String> addressParts = [];
      if (houseName.isNotEmpty) addressParts.add(houseName);
      addressParts.add(place);
      addressParts.add(zipcode);

      final finalAddress = addressParts.join(', ');

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
                      'Your service has been scheduled.\nLocation: $finalAddress',
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
