import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/services/storage_service.dart';
import '../../home/providers/consumer_provider.dart';
import '../../home/widgets/location_selector_bottom_sheet.dart';
import '../../../core/providers/quotation_provider.dart';
import '../../home/screens/main_screen.dart';
import '../../service_boy/models/service_category_model.dart';
import '../../service_boy/models/service_subcategory_model.dart';
import '../../home/models/service_product_model.dart';

class CreateQuotationScreen extends StatefulWidget {
  const CreateQuotationScreen({super.key});

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  ServiceCategoryModel? _selectedCategory;
  ServiceSubcategoryModel? _selectedSubcategory;

  final Set<String> _selectedTechnicianIds = {};

  String _selectedLocationAddress = 'Select a location to proceed';
  String _selectedLocationLabel = 'No Location Selected';
  String _city = '';
  List<double> _selectedCoordinates = [0.0, 0.0];

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final consumerProv = context.read<ConsumerProvider>();
      if (consumerProv.categories.isEmpty) {
        consumerProv.fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final locationData = await StorageService.getUserLocation();
      if (locationData != null && locationData['address'] != null) {
        if (mounted) {
          setState(() {
            _selectedLocationAddress = locationData['address'];
            _addressController.text = locationData['address'] ?? '';
            _selectedLocationLabel = locationData['label'] ?? 'Saved Location';
            _city = locationData['locality'] ?? '';
            _cityController.text = locationData['locality'] ?? '';
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
                _selectedLocationLabel =
                    locationData['label'] ?? 'Selected Location';
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _submitRequest() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_selectedSubcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subcategory')),
      );
      return;
    }
    if (_selectedTechnicianIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one technician to invite'),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCoordinates[0] == 0.0 && _selectedCoordinates[1] == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select your location on the map to set coordinates (latitude and longitude).',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final quoteProvider = context.read<QuotationProvider>();
      final consumer = context.read<ConsumerProvider>().currentUser;
      final consumerProvider = context.read<ConsumerProvider>();

      if (consumer == null) {
        throw Exception('User profile not loaded. Please log in again.');
      }

      // Determine the service to use for request matching the selected technician(s)
      ServiceProductModel? representativeService;
      if (_selectedTechnicianIds.isNotEmpty) {
        final firstTechId = _selectedTechnicianIds.first;
        for (var s in consumerProvider.services) {
          if (s.providerId == firstTechId) {
            representativeService = s;
            break;
          }
        }
      }

      // If we couldn't find a matching service, fallback to the first service of the subcategory
      if (representativeService == null &&
          consumerProvider.services.isNotEmpty) {
        representativeService = consumerProvider.services.first;
      }

      if (representativeService == null) {
        throw Exception(
          'No services available in this subcategory to request quotations.',
        );
      }

      // 1. Upload images if any
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        imageUrls = await quoteProvider.uploadAttachments(
          _images.map((f) => f.path).toList(),
        );
      }

      // 2. Submit Request
      final success = await quoteProvider.createRequest(
        customerId: consumer.id,
        serviceId: representativeService.id,
        locationName: _addressController.text.trim(),
        city: _cityController.text.trim(),
        latitude: _selectedCoordinates[0],
        longitude: _selectedCoordinates[1],
        description: _descriptionController.text.trim(),
        notes:
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
        category: _selectedCategory!.id,
        subcategory: _selectedSubcategory!.id,
        serviceName: representativeService.name,
        images: imageUrls,
        technicianIds: _selectedTechnicianIds.toList(),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final consumerProvider = context.watch<ConsumerProvider>();

    // Group services to retrieve unique technicians
    final Map<String, ServiceProductModel> uniqueTechnicians = {};
    for (var s in consumerProvider.services) {
      if (s.providerId.isNotEmpty) {
        uniqueTechnicians[s.providerId] = s;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Create Quotation Request', style: AppTextStyles.h4),
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
                      // Form Info Note
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Iconsax.info_circle5,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Select your category, subcategory, service, location, and write a brief description to request quotes.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category selection
                      Text('Category', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ServiceCategoryModel>(
                        value: _selectedCategory,
                        hint: Text(
                          'Select Category',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                        items:
                            consumerProvider.categories.map((cat) {
                              return DropdownMenuItem<ServiceCategoryModel>(
                                value: cat,
                                child: Text(
                                  cat.name,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              );
                            }).toList(),
                        onChanged:
                            consumerProvider.isLoadingCategories
                                ? null
                                : (val) {
                                  setState(() {
                                    _selectedCategory = val;
                                    _selectedSubcategory = null;
                                    _selectedTechnicianIds.clear();
                                  });
                                  if (val != null) {
                                    consumerProvider.fetchSubcategories(val.id);
                                  }
                                },
                      ),
                      const SizedBox(height: 20),

                      // Subcategory selection
                      Text('Subcategory', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ServiceSubcategoryModel>(
                        value: _selectedSubcategory,
                        hint: Text(
                          _selectedCategory == null
                              ? 'Select Category First'
                              : 'Select Subcategory',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                        ),
                        items:
                            consumerProvider.subcategories.map((sub) {
                              return DropdownMenuItem<ServiceSubcategoryModel>(
                                value: sub,
                                child: Text(
                                  sub.name,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              );
                            }).toList(),
                        onChanged:
                            _selectedCategory == null ||
                                    consumerProvider.isLoadingSubcategories
                                ? null
                                : (val) {
                                  setState(() {
                                    _selectedSubcategory = val;
                                    _selectedTechnicianIds.clear();
                                  });
                                  if (val != null) {
                                    consumerProvider.fetchServicesBySubcategory(
                                      val.id,
                                    );
                                  }
                                },
                      ),
                      const SizedBox(height: 20),

                      // Technician Selection List
                      if (_selectedSubcategory != null) ...[
                        Text(
                          'Invite Technicians',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select one or more professionals to receive your quotation request.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (consumerProvider.isLoadingServices)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (uniqueTechnicians.isEmpty)
                          Text(
                            'No professionals available under this subcategory',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.red,
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: uniqueTechnicians.length,
                            itemBuilder: (context, index) {
                              final entry = uniqueTechnicians.entries.elementAt(
                                index,
                              );
                              final technicianId = entry.key;
                              final service = entry.value;
                              final isSelected = _selectedTechnicianIds
                                  .contains(technicianId);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  title: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundImage:
                                            service.providerImage.isNotEmpty
                                                ? NetworkImage(
                                                  service.providerImage,
                                                )
                                                : null,
                                        child:
                                            service.providerImage.isEmpty
                                                ? const Icon(Icons.person)
                                                : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.providerName,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  service.rating > 0
                                                      ? service.rating
                                                          .toStringAsFixed(1)
                                                      : 'New',
                                                  style:
                                                      AppTextStyles.bodySmall,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '(${service.reviewsCount} reviews)',
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .textSecondary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedTechnicianIds.add(
                                          technicianId,
                                        );
                                      } else {
                                        _selectedTechnicianIds.remove(
                                          technicianId,
                                        );
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                      ],

                      // 1. Service Address
                      Text('Service Address', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Enter your service address...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your service address';
                          }
                          if (value.trim().length < 5) {
                            return 'Please enter a complete address (minimum 10 characters)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 2. City
                      Text('City', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'Enter your city (e.g. Mumbai)...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 3. Map Coordinates Selector
                      Text(
                        'Map Location Coordinates',
                        style: AppTextStyles.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showLocationSelector,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _selectedCoordinates[0] != 0.0
                                      ? Colors.green
                                      : AppColors.border,
                              width: _selectedCoordinates[0] != 0.0 ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (_selectedCoordinates[0] != 0.0
                                          ? Colors.green
                                          : AppColors.primary)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Iconsax.location5,
                                  color:
                                      _selectedCoordinates[0] != 0.0
                                          ? Colors.green
                                          : AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedCoordinates[0] != 0.0
                                          ? 'Coordinates Fetched'
                                          : 'Pin Location on Map',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _selectedCoordinates[0] != 0.0
                                                ? Colors.green
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedCoordinates[0] != 0.0
                                          ? 'Lat: ${_selectedCoordinates[0].toStringAsFixed(4)}, Lng: ${_selectedCoordinates[1].toStringAsFixed(4)}'
                                          : 'Select from map selector to get coordinates',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _selectedCoordinates[0] != 0.0
                                    ? Icons.check_circle
                                    : Iconsax.arrow_right_3,
                                size: 18,
                                color:
                                    _selectedCoordinates[0] != 0.0
                                        ? Colors.green
                                        : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description Input
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
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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

                      // Notes Input
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
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 24),

                      // Image picker
                      // Text(
                      //   'Attach Images (Optional)',
                      //   style: AppTextStyles.labelLarge,
                      // ),
                      // const SizedBox(height: 12),
                      // SizedBox(
                      //   height: 80,
                      //   child: ListView.builder(
                      //     scrollDirection: Axis.horizontal,
                      //     itemCount: _images.length + 1,
                      //     itemBuilder: (context, index) {
                      //       if (index == _images.length) {
                      //         return GestureDetector(
                      //           onTap: _pickImage,
                      //           child: Container(
                      //             width: 80,
                      //             margin: const EdgeInsets.only(right: 8),
                      //             decoration: BoxDecoration(
                      //               color:
                      //                   Theme.of(context).colorScheme.surface,
                      //               borderRadius: BorderRadius.circular(12),
                      //               border: Border.all(color: AppColors.border),
                      //             ),
                      //             child: const Icon(
                      //               Icons.add_a_photo,
                      //               color: AppColors.primary,
                      //             ),
                      //           ),
                      //         );
                      //       }
                      //       return Stack(
                      //         children: [
                      //           Container(
                      //             width: 80,
                      //             margin: const EdgeInsets.only(right: 8),
                      //             decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(12),
                      //               image: DecorationImage(
                      //                 image: FileImage(_images[index]),
                      //                 fit: BoxFit.cover,
                      //               ),
                      //             ),
                      //           ),
                      //           Positioned(
                      //             right: 12,
                      //             top: 4,
                      //             child: GestureDetector(
                      //               onTap: () => _removeImage(index),
                      //               child: Container(
                      //                 padding: const EdgeInsets.all(2),
                      //                 decoration: const BoxDecoration(
                      //                   color: Colors.red,
                      //                   shape: BoxShape.circle,
                      //                 ),
                      //                 child: const Icon(
                      //                   Icons.close,
                      //                   size: 14,
                      //                   color: Colors.white,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       );
                      //     },
                      //   ),
                      // ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // Bottom Submission Panel
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
                    text: 'Submit Custom Request',
                    isLoading: _isSubmitting,
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
