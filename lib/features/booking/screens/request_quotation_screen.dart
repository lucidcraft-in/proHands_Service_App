import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/services/storage_service.dart';
import '../../home/providers/consumer_provider.dart';
import '../../home/widgets/location_selector_bottom_sheet.dart';
import '../../../core/providers/quotation_provider.dart';
import '../../home/screens/main_screen.dart';

class RequestQuotationScreen extends StatefulWidget {
  final String serviceId;
  final String serviceName;

  const RequestQuotationScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<RequestQuotationScreen> createState() => _RequestQuotationScreenState();
}

class _RequestQuotationScreenState extends State<RequestQuotationScreen> {
  String _selectedLocationAddress = 'Select a location to proceed';
  String _selectedLocationLabel = 'No Location Selected';
  String _city = '';
  List<double> _selectedCoordinates = [0.0, 0.0];

  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
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
            _city = locationData['locality'] ?? '';
            if (locationData['coordinates'] != null) {
              _selectedCoordinates = List<double>.from(
                locationData['coordinates'],
              );
            }
          });
        }
      }
    } catch (_) {}
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
                _city = locationData['locality'] ?? '';
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

  void _submitRequest() async {
    if (_selectedCoordinates[0] == 0.0 && _selectedCoordinates[1] == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid location')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final customer = context.read<ConsumerProvider>().currentUser;
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User profile not loaded. Please log in again.'),
        ),
      );
      return;
    }

    final quoteProvider = context.read<QuotationProvider>();
    final success = await quoteProvider.createRequest(
      customerId: customer.id,
      serviceId: widget.serviceId,
      locationName: _selectedLocationAddress,
      city: _city.isNotEmpty ? _city : 'Springfield',
      latitude: _selectedCoordinates[0],
      longitude: _selectedCoordinates[1],
      description:
          _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
      notes:
          _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Icon(
                    Iconsax.tick_circle5,
                    color: Colors.green,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quote Requested!',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your request has been successfully submitted. Providers will review it and send an estimate.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'View Quotations',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const MainScreen(
                                  initialIndex: 1,
                                  bookingInitialTabIndex: 1,
                                ),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            quoteProvider.createError ?? 'Failed to submit quote request',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = context.watch<QuotationProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Request Quotation', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Box Note
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Iconsax.info_circle5,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                // 'ദയവായി വലിയ ജോലികൾക്കായി മാത്രം കൊട്ടേഷൻ സൗകര്യം ഉപയോഗിക്കുക. ഇത് സേവനങ്ങൾ കൂടുതൽ സുഗമമാക്കാൻ സഹായിക്കും.\n(
                                'For a smoother experience, please request quotations only for major works.',
                                // )',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Name Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Requested',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.serviceName,
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Location Section
                      Text('Service Location', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showLocationSelector,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
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
                                      _selectedLocationLabel,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedLocationAddress,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Iconsax.arrow_right_3,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description input
                      Text('Job Description', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              'Describe the work or details of the job...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Notes input
                      Text(
                        'Additional Notes (Optional)',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              'Any special instructions, access codes, preferred hours...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Submit Quote Request',
                    isLoading: quoteProvider.isCreating,
                    onPressed: _submitRequest,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
