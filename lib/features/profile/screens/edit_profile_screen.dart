import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_app/helper.dar/imageCroper.dart';
import 'package:service_app/helper.dar/saveimagePer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../home/providers/consumer_provider.dart';
import '../../service_boy/providers/service_boy_provider.dart';
import '../../service_boy/models/service_category_model.dart';
import '../../service_boy/models/service_subcategory_model.dart';
import '../../service_boy/models/service_model.dart';
import '../../../core/models/user_type.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();

  // Common Fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  // Technician Fields
  late TextEditingController _professionController;
  late TextEditingController _experienceController;
  // late TextEditingController _specialtiesController; // Comma separated
  late TextEditingController
  _workLocationPreferredController; // Comma separated for now

  // Bank Details (Technician Only)
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _accountHolderNameController;

  // Service Management Fields (Technician Only)
  late TextEditingController _serviceNameController;
  late TextEditingController _serviceDescriptionController;
  late TextEditingController _customSkillController;
  late TextEditingController _additionalSkillsController;
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  List<String> _selectedAdditionalSkills = [];
  List<String> _servicesOffered = [];
  List<String> _customSkills = [];
  bool _isTrending = false;
  String? _existingServiceId;
  bool _isLoadingService = false;

  // Dropdowns/Selections
  final List<String> _workPreferenceOptions = ['Full-time', 'Part-time'];
  String? _selectedWorkPreference;

  // Files
  File? _adharCard;
  File? _license;
  File? _serviceImage;
  List<File> _portfolioImages = [];
  bool _isSaving = false;

  // Preferred Locations state
  List<Map<String, dynamic>> _selectedPreferredLocations = [];
  List<Map<String, dynamic>> _locationSuggestions = [];
  bool _isFetchingSuggestions = false;
  Timer? _locationDebounce;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _professionController = TextEditingController();
    _experienceController = TextEditingController();
    // _specialtiesController = TextEditingController();
    _workLocationPreferredController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscCodeController = TextEditingController();
    _accountHolderNameController = TextEditingController();

    // Service Management Controllers
    _serviceNameController = TextEditingController();
    _serviceDescriptionController = TextEditingController();
    _customSkillController = TextEditingController();
    _additionalSkillsController = TextEditingController();

    // Fetch latest profile
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ConsumerProvider>();
      await provider.fetchUserProfile();
      if (mounted) {
        _initializeFromUser(provider.currentUser);
        if (provider.currentUser?.userType == UserType.serviceBoy) {
          _fetchServiceInfo();
        }
      }
    });
  }

  Future<void> _fetchServiceInfo() async {
    setState(() => _isLoadingService = true);

    try {
      final serviceProvider = context.read<ServiceBoyProvider>();
      await serviceProvider.fetchCategories();
      await serviceProvider.fetchMyServices();

      if (serviceProvider.myServices.isNotEmpty && mounted) {
        final service = serviceProvider.myServices.first;

        _existingServiceId = service.id;
        _serviceNameController.text = service.name;
        _serviceDescriptionController.text = service.description;
        _selectedCategoryId = service.categoryId;
        _selectedSubcategoryId = service.subcategoryId;

        _servicesOffered = service.subcategories.map((e) => e.name).toList();
        _selectedAdditionalSkills = List<String>.from(service.additionalSkills);
        _isTrending = service.isTrending;

        // If category is selected, fetch its subcategories
        if (_selectedCategoryId != null) {
          await serviceProvider.fetchSubcategories(_selectedCategoryId!);
        }
      } else {
        // If no service exists yet, try to match user.profession to a category
        // to show the appropriate fields (like Services Offered)
        final user = context.read<ConsumerProvider>().currentUser;
        if (user != null) {
          final match = serviceProvider.categories.firstWhere(
            (c) => c.name.toLowerCase() == user.profession.toLowerCase(),
            orElse:
                () =>
                    serviceProvider
                        .categories
                        .first, // Fallback to first if needed? Or null
          );
          if (match != null) {
            setState(() {
              // _selectedCategoryId = match.id;
              // _professionController.text = match.name;
            });
            await serviceProvider.fetchSubcategories(match.id);
          }
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingService = false);
      }
    }
  }

  void _initializeFromUser(UserModel? user) {
    if (user == null) return;

    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _addressController.text = user.address.toString();

    // Technician Specifics
    _professionController.text = user.profession;
    _experienceController.text = user.experience;
    _servicesOffered = List<String>.from(user.servicesOffered);
    // _specialtiesController.text = user.specialties.join(', ');
    _workLocationPreferredController.text =
        ''; // We use _selectedPreferredLocations instead
    _selectedPreferredLocations = [];
    for (var loc in user.workLocationPreferred) {
      try {
        final decoded = jsonDecode(loc);
        try {
          if (decoded is Map<String, dynamic>) {
            setState(() {
              _selectedPreferredLocations.add(decoded);
            });
          }
        } catch (e) {}
      } catch (e) {
        // Fallback for plain strings if any
        _selectedPreferredLocations.add({
          'location_name': loc,
          'coordinates': [0.0, 0.0],
        });
      }
    }

    if (user.workPreference.isNotEmpty == true) {
      _selectedWorkPreference = user.workPreference.first;
      if (!_workPreferenceOptions.contains(_selectedWorkPreference)) {
        _selectedWorkPreference = null;
      }
    }

    // Bank Details
    // if (user.bankDetails != null) {
    //   _bankNameController.text = user.bankDetails?.bankName ?? '';
    //   _accountNumberController.text = user.bankDetails?.accountNumber ?? '';
    //   _ifscCodeController.text = user.bankDetails?.ifscCode ?? '';
    //   _accountHolderNameController.text =
    //       user.bankDetails?.accountHolderName ?? '';
    // }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _professionController.dispose();
    _experienceController.dispose();
    // _specialtiesController.dispose();
    _workLocationPreferredController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    _customSkillController.dispose();
    _additionalSkillsController.dispose();
    _locationDebounce?.cancel();
    super.dispose();
  }

  void _onLocationChanged(String query) {
    if (_locationDebounce?.isActive ?? false) _locationDebounce!.cancel();
    _locationDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _locationSuggestions = [];
        });
        return;
      }

      setState(() {
        _isFetchingSuggestions = true;
      });

      try {
        final suggestions = await LocationService.getPlaceSuggestions(query);
        setState(() {
          _locationSuggestions = suggestions;
        });
      } finally {
        setState(() {
          _isFetchingSuggestions = false;
        });
      }
    });
  }

  Future<void> _addLocation(Map<String, dynamic> suggestion) async {
    final placeId = suggestion['place_id'];
    final description = suggestion['description'];
    try {
      // Check if already added
      if (_selectedPreferredLocations.any(
        (loc) => (loc['location_name'] ?? loc['location_name']) == description,
      )) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location already added')));
        return;
      }

      final latLng = await LocationService.getLatLngFromPlaceId(placeId);
      if (latLng != null) {
        setState(() {
          _selectedPreferredLocations.add({
            'location_name': description,
            'coordinates': [latLng.longitude, latLng.latitude], // ⚠️ lng, lat
          });
          _locationSuggestions = [];
          _workLocationPreferredController.clear();
        });
      }
    } catch (e) {}
  }

  void _removeLocation(int index) {
    setState(() {
      _selectedPreferredLocations.removeAt(index);
    });
  }

  // Future<void> _pickImage(String type) async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       switch (type) {
  //         case 'adhar':
  //           _adharCard = File(image.path);
  //           break;
  //         case 'license':
  //           _license = File(image.path);
  //           break;
  //         case 'service':
  //           _serviceImage = File(image.path);
  //           break;
  //       }
  //     });
  //   }
  // }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final savedFile = await saveImagePermanently(image);

      setState(() {
        switch (type) {
          case 'adhar':
            _adharCard = savedFile;
            break;
          case 'license':
            _license = savedFile;
            break;
          case 'service':
            _serviceImage = savedFile;
            break;
        }
      });
    }
  }

  Future<void> _pickPortfolioImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _portfolioImages.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  void _removePortfolioImage(int index) {
    setState(() {
      _portfolioImages.removeAt(index);
    });
  }

  File? _selectedImage;
  // Future<void> _updateProfilePhoto() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     final provider = context.read<ConsumerProvider>();
  //     final success = await provider.updateProfilePhoto(File(image.path));

  //     if (mounted) {
  //       if (success) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Profile picture updated successfully'),
  //             backgroundColor: AppColors.success,
  //           ),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               provider.updatePhotoError ?? 'Failed to update profile picture',
  //             ),
  //             backgroundColor: AppColors.error,
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  Future<void> _updateProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      final provider = context.read<ConsumerProvider>();

      final success = await provider.updateProfilePhoto(File(image.path));

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                provider.updatePhotoError ?? 'Failed to update profile picture',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  String getSubcategoryId(ServiceBoyProvider serviceProvider) {
    if (_servicesOffered.isEmpty) return '';

    final firstSkill = _servicesOffered.first;

    try {
      final sub = serviceProvider.subcategories.firstWhere(
        (s) => s.name == firstSkill,
      );

      if (sub.id != null && sub.id.toString().isNotEmpty) {
        return sub.id;
      }
      print("===========");
      print(firstSkill);
      return firstSkill;
    } catch (_) {
      print("===========");
      print(firstSkill);
      return firstSkill;
    }
  }

  Future<void> _handleSave() async {
    print("Adhar: ${_adharCard?.path}");
    print("License: ${_license?.path}");
    print("Service: ${_serviceImage?.path}");

    print("Adhar Exists: ${_adharCard?.existsSync()}");
    print("License Exists: ${_license?.existsSync()}");
    print("Service Exists: ${_serviceImage?.existsSync()}");
    final consumerProvider = context.read<ConsumerProvider>();
    final serviceProvider = context.read<ServiceBoyProvider>();
    final user = consumerProvider.currentUser;
    final isServiceBoy = user?.userType == UserType.serviceBoy;

    // Check which tab is active if we want to save only one, or save based on which form is validated
    // But since we want a "unified" feel, let's try to save what's relevant.
    // If the user is on the Service tab, save service. If on Profile tab, save profile.
    // Actually, I'll just check which form validates.

    bool isValid = _profileFormKey.currentState?.validate() ?? false;

    if (isServiceBoy) {
      final hasAdhar =
          (user?.adharCard != null && user!.adharCard!.isNotEmpty) ||
          _adharCard != null;
      final hasLicense =
          (user?.license != null && user!.license!.isNotEmpty) ||
          _license != null;

      if (!hasAdhar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !hasAdhar && !hasLicense
                  ? 'Please upload both Adhar Card and License'
                  : 'Please upload License',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (!isValid && isServiceBoy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check the form for errors'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (isValid) {
      setState(() {
        _isSaving = true;
      });

      try {
        bool profileSuccess = true;
        bool serviceSuccess = true;
        if (isValid) {
          final results = await Future.wait([
            consumerProvider.updateFullProfile(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              address: _addressController.text.trim(),
              profession:
                  isServiceBoy ? _professionController.text.trim() : null,
              experience:
                  isServiceBoy ? _experienceController.text.trim() : null,
              // servicesOffered: isServiceBoy ? _servicesOffered : null,

              // specialties:
              //     isServiceBoy
              //         ? _specialtiesController.text
              //             .split(',')
              //             .map((e) => e.trim())
              //             .where((e) => e.isNotEmpty)
              //             .toList()
              //         : null,
              workPreference:
                  isServiceBoy
                      ? (_selectedWorkPreference != null
                          ? [_selectedWorkPreference!]
                          : [])
                      : null,
              workLocationPreferred:
                  isServiceBoy ? _selectedPreferredLocations : null,
              latitude: user?.latitude ?? 0.0,
              longitude: user?.longitude ?? 0.0,
              adharCardPath: _adharCard?.path,
              licensePath: _license?.path,
              serviceImagePath: _serviceImage?.path,
              portfolioImagePaths: _portfolioImages.map((e) => e.path).toList(),
            ),
            Future.delayed(const Duration(seconds: 1)),
          ]);

          profileSuccess = results[0] as bool;
          if (!profileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  consumerProvider.updateProfileError ??
                      'Failed to update profile',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }

        if (isServiceBoy && isValid) {
          // Handle Service Save
          String? imageUrl;
          if (_serviceImage != null) {
            imageUrl = await serviceProvider.uploadServiceImage(_serviceImage!);
          }

          print(
            'service offered: ${_servicesOffered.map((e) {
              try {
                final sub = serviceProvider.subcategories.firstWhere((s) => s.name == e);

                return {'id': sub.id, 'name': sub.name};
              } catch (_) {
                return {'id': '', 'name': e};
              }
            }).toList()}',
          );
          final serviceData = {
            'name': _serviceNameController.text.trim(),
            'description': _serviceDescriptionController.text.trim(),
            'categoryId': _selectedCategoryId,
            // 'subcategoryId':
            //     _selectedSubcategoryId ??
            //     '', // Use existing or empty if none selected
            'subcategoryId': _selectedSubcategoryId,
            'subcategories':
                _servicesOffered.map((skill) {
                  try {
                    final sub = serviceProvider.subcategories.firstWhere(
                      (s) => s.name == skill,
                    );

                    return {'id': sub.id, 'name': sub.name};
                  } catch (_) {
                    return {'id': '', 'name': skill};
                  }
                }).toList(),
            'additionalSkills': _selectedAdditionalSkills,
            'isTrending': _isTrending,
            if (imageUrl != null) 'serviceImage': imageUrl,
            // For existing services, these might be required or preserved
            'price':
                serviceProvider.myServices.isNotEmpty
                    ? serviceProvider.myServices.first.price
                    : 0,
            'duration':
                serviceProvider.myServices.isNotEmpty
                    ? serviceProvider.myServices.first.duration
                    : 0,
          };

          if (_existingServiceId != null) {
            serviceSuccess = await serviceProvider.updateService(
              _existingServiceId!,
              serviceData,
            );
          } else {
            serviceSuccess = await serviceProvider.createService(serviceData);
          }

          if (!serviceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  serviceProvider.createServiceError ??
                      serviceProvider.updateServiceError ??
                      'Failed to save service',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }

        // If we reached here without catching an error, check if both succeeded
        if (profileSuccess && serviceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Changes saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Widget _buildFilePicker(
    String label,
    File? file,
    String? remoteUrl,
    VoidCallback onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPick,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child:
                file != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(file, fit: BoxFit.cover),
                    )
                    : (remoteUrl != null && remoteUrl.isNotEmpty)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        remoteUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildUploadPlaceholder(),
                      ),
                    )
                    : _buildUploadPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.document_upload, size: 32, color: AppColors.primary),
        SizedBox(height: 8),
        Text('Tap to upload', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsumerProvider>();
    final serviceBoyProvider = context.watch<ServiceBoyProvider>();
    final user = provider.currentUser;
    final isServiceBoy = user?.userType == UserType.serviceBoy;

    // Watch for loading state
    final isLoading =
        _isSaving ||
        (isServiceBoy
            ? provider.isCompletingProfile
            : provider.isUpdatingProfile);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isServiceBoy ? 'Edit Profile & Service' : 'Edit Profile',
          style: AppTextStyles.h4,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileFields(user, provider),
              if (user?.userType == UserType.serviceBoy) ...[
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 20),
                _buildServiceFields(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child:
            isLoading ||
                    serviceBoyProvider.isCreatingService ||
                    serviceBoyProvider.isUpdatingService
                ? const SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                )
                : GradientButton(
                  text: 'Save All Changes',
                  onPressed: _handleSave,
                ),
      ),
    );
  }

  Widget _buildProfileFields(UserModel? user, ConsumerProvider provider) {
    final isServiceBoy = user?.userType == UserType.serviceBoy;
    final bool isPending = user?.pendingProfilePhoto?.isNotEmpty == true;

    final String? currentImage = user?.profilePhoto;
    final String? pendingImage = user?.pendingProfilePhoto;
    print('currentImage : $currentImage');
    print('pendingImage : $pendingImage');
    return Column(
      children: [
        // Avatar
        InkWell(
          onTap: provider.isUpdatingPhoto ? null : _updateProfilePhoto,
          borderRadius: BorderRadius.circular(60),

          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onLongPress: () {
                  if (_selectedImage == null) {
                    final imageUrl = isPending ? pendingImage : currentImage;

                    if (imageUrl != null && imageUrl.isNotEmpty) {
                      showFullScreenImage(imageUrl, context);
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  backgroundImage:
                      _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (isPending &&
                              pendingImage != null &&
                              pendingImage.isNotEmpty)
                          ? NetworkImage(pendingImage)
                          : (currentImage != null && currentImage.isNotEmpty)
                          ? NetworkImage(currentImage)
                          : null,
                  child:
                      _selectedImage == null &&
                              currentImage == null &&
                              pendingImage == null
                          ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primary,
                          )
                          : null,
                ),
              ),

              // Approved image preview
              if (isPending && currentImage != null && currentImage.isNotEmpty)
                Positioned(
                  top: -5,
                  right: -5,
                  child: GestureDetector(
                    onLongPress: () {
                      if (currentImage != "assets/images/default_avatar.png") {
                        showFullScreenImage(currentImage!, context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            currentImage == "assets/images/default_avatar.png"
                                ? AssetImage(currentImage)
                                : NetworkImage(currentImage),
                      ),
                    ),
                  ),
                ),

              // Pending badge
              if (isPending)
                Positioned(
                  bottom: -30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Profile picture under review',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Camera button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Iconsax.camera,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Common Fields
        CustomTextField(
          label: 'Full Name',
          hint: 'Enter your name',
          controller: _nameController,
          prefixIcon: const Icon(
            Iconsax.user,
            color: AppColors.textTertiary,
            size: 20,
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Email',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Iconsax.sms,
            color: AppColors.textTertiary,
            size: 20,
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty) ? 'Email is required' : null,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Address',
          hint: 'Enter your address',
          controller: _addressController,
          maxLines: 2,
          prefixIcon: const Icon(
            Iconsax.location,
            color: AppColors.textTertiary,
            size: 20,
          ),
          validator:
              (value) =>
                  (value == null || value.isEmpty)
                      ? 'Address is required'
                      : null,
        ),
        const SizedBox(height: 20),

        // Technician Specific Fields
        if (isServiceBoy) ...[
          // Category Selector (Profession)
          Consumer<ServiceBoyProvider>(
            builder: (context, sbProvider, _) {
              return DropdownSearch<ServiceCategoryModel>(
                items: sbProvider.categories,
                itemAsString: (ServiceCategoryModel c) => c.name,
                selectedItem:
                    _selectedCategoryId == null
                        ? null
                        : sbProvider.categories
                            .cast<ServiceCategoryModel?>()
                            .firstWhere(
                              (e) => e?.id == _selectedCategoryId,
                              orElse: () => null,
                            ),
                popupProps: const PopupProps.menu(showSearchBox: true),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Profession (Category)",
                    hintText: "Select Profession",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ),
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem?.name ?? "Select Profession",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium,
                  );
                },
                onChanged: (ServiceCategoryModel? selected) {
                  setState(()
                  // async
                  {
                    _selectedCategoryId = selected?.id;
                    if (selected != null) {
                      _professionController.text = selected.name;
                      _serviceNameController.text = selected.name;
                      // await
                      sbProvider.fetchSubcategories(selected.id);

                      if (sbProvider.subcategories.isNotEmpty) {
                        setState(() {
                          _selectedSubcategoryId =
                              sbProvider.subcategories.first.id;
                        });
                      }

                      print("===============");
                      print(_selectedSubcategoryId);
                    } else {
                      _professionController.clear();
                      sbProvider.clearSubcategories();
                    }
                    _selectedAdditionalSkills = [];
                  });
                },
                validator:
                    (value) => value == null ? 'Profession is required' : null,
              );
            },
          ),
          const SizedBox(height: 20),
          // Service Title
          CustomTextField(
            label: 'Service Title',
            hint: 'Enter your Service Title',
            controller: _serviceNameController,
            // readOnly: true,
            prefixIcon: const Icon(
              Iconsax.briefcase,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Experience',
            hint: 'e.g. 5 Years',
            controller: _experienceController,
            prefixIcon: const Icon(
              Iconsax.timer_1,
              color: AppColors.textTertiary,
              size: 20,
            ),
            validator:
                (value) =>
                    (value == null || value.isEmpty)
                        ? 'Experience is required'
                        : null,
          ),
          const SizedBox(height: 20),

          // Work Preference Dropdown
          DropdownButtonFormField<String>(
            value: _selectedWorkPreference,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              labelText: 'Work Preference',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            items:
                _workPreferenceOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedWorkPreference = newValue;
              });
            },
            validator:
                (value) => value == null ? 'Please select preference' : null,
          ),
          const SizedBox(height: 20),

          // Services Offered
          if (_selectedCategoryId != null) ...[
            Text(
              // 'Services Offered (first service name selected is the main service)',
              'Services Offered',
              style: AppTextStyles.labelMedium,
            ),
            const SizedBox(height: 12),
            Consumer<ServiceBoyProvider>(
              builder: (context, sbProvider, _) {
                final standardNames =
                    sbProvider.subcategories.map((s) => s.name).toList();
                final allDisplayNames = [
                  ...standardNames,
                  ..._servicesOffered.where(
                    (skill) => !standardNames.contains(skill),
                  ),
                ];

                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      if (sbProvider.isLoadingSubcategories)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (sbProvider.subcategories.isEmpty &&
                          _servicesOffered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No services found for this category'),
                        )
                      else
                        ...allDisplayNames.map((name) {
                          final isSelected = _servicesOffered.contains(name);
                          return CheckboxListTile(
                            title: Text(name, style: AppTextStyles.bodyMedium),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (!_servicesOffered.contains(name)) {
                                    _servicesOffered.add(name);
                                  }
                                } else {
                                  _servicesOffered.remove(name);
                                }

                                // Auto-set service title and subcategory ID from first selected skill
                                if (_servicesOffered.isNotEmpty) {
                                  final firstSkill = _servicesOffered.first;
                                  // try {
                                  //   final sub = sbProvider.subcategories
                                  //       .firstWhere(
                                  //         (s) => s.name == firstSkill,
                                  //       );
                                  //   _selectedSubcategoryId = sub.id;
                                  // } catch (_) {
                                  //   _selectedSubcategoryId = null;
                                  // }
                                  try {
                                    final sub = sbProvider.subcategories
                                        .firstWhere(
                                          (s) => s.name == firstSkill,
                                        );

                                    _selectedSubcategoryId = sub.id;
                                  } catch (_) {
                                    // Custom service
                                    _selectedSubcategoryId = '';
                                  }
                                } else {
                                  _selectedSubcategoryId = null;
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                          );
                        }).toList(),

                      // Custom skills input
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customSkillController,
                                decoration: InputDecoration(
                                  hintText: 'Add custom service...',
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                final skill =
                                    _customSkillController.text.trim();
                                if (skill.isNotEmpty) {
                                  setState(() {
                                    if (!_servicesOffered.contains(skill)) {
                                      _servicesOffered.add(skill);
                                    }

                                    // Update title and ID if this is the first skill
                                    // if (_servicesOffered.isNotEmpty) {
                                    //   final firstSkill = _servicesOffered.first;
                                    //   _serviceNameController.text = firstSkill;

                                    //   // Find the ID for the first skill
                                    //   try {
                                    //     final sub = sbProvider.subcategories
                                    //         .firstWhere(
                                    //           (s) => s.name == firstSkill,
                                    //         );
                                    //     _selectedSubcategoryId = sub.id;
                                    //   } catch (_) {
                                    //     _selectedSubcategoryId = null;
                                    //   }
                                    // }
                                    _customSkillController.clear();
                                  });
                                }
                              },
                              icon: const Icon(
                                Iconsax.add_circle,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 20),

          // Additional Skills Section
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Additional Skills', style: AppTextStyles.labelMedium),
          //     if (_specialtiesController.text.isNotEmpty)
          //       GestureDetector(
          //         onTap: () {
          //           final skills = _specialtiesController.text.split(',');
          //           setState(() {
          //             for (var skill in skills) {
          //               final trimmed = skill.trim();
          //               if (trimmed.isNotEmpty &&
          //                   !_selectedAdditionalSkills.contains(trimmed)) {
          //                 _selectedAdditionalSkills.add(trimmed);
          //               }
          //             }
          //           });
          //         },
          //         child: Text(
          //           'Import from Specialties',
          //           style: AppTextStyles.bodySmall.copyWith(
          //             color: AppColors.primary,
          //             fontWeight: FontWeight.w600,
          //           ),
          //         ),
          //       ),
          //   ],
          // ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Add Skills',
            hint: 'e.g. Electrical Wiring, AC Repair (comma separated)',
            controller: _additionalSkillsController,
            prefixIcon: const Icon(
              Iconsax.star,
              color: AppColors.textTertiary,
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                final value = _additionalSkillsController.text;
                if (value.isNotEmpty) {
                  final skills = value.split(',');
                  setState(() {
                    for (var skill in skills) {
                      final trimmedSkill = skill.trim();
                      if (trimmedSkill.isNotEmpty &&
                          !_selectedAdditionalSkills.contains(trimmedSkill)) {
                        _selectedAdditionalSkills.add(trimmedSkill);
                      }
                    }
                    _additionalSkillsController.clear();
                  });
                }
              },
              icon: const Icon(Iconsax.add_circle, color: AppColors.primary),
            ),
            onChanged: (value) {
              if (value.endsWith(',')) {
                final skills = value.split(',');
                setState(() {
                  for (var skill in skills) {
                    final trimmedSkill = skill.trim();
                    if (trimmedSkill.isNotEmpty &&
                        !_selectedAdditionalSkills.contains(trimmedSkill)) {
                      _selectedAdditionalSkills.add(trimmedSkill);
                    }
                  }
                  _additionalSkillsController.clear();
                });
              }
            },
          ),
          if (_selectedAdditionalSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selectedAdditionalSkills.map((skill) {
                    return Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        setState(() {
                          _selectedAdditionalSkills.remove(skill);
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      side: BorderSide.none,
                    );
                  }).toList(),
            ),
          ],
          // const SizedBox(height: 20),
          // CustomTextField(
          //   label: 'Specialties',
          //   hint: 'e.g. Electrical Wiring, AC Repair (comma separated)',
          //   controller: _specialtiesController,
          //   prefixIcon: const Icon(
          //     Iconsax.star,
          //     color: AppColors.textTertiary,
          //     size: 20,
          //   ),
          //   maxLines: 2,
          // ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Preferred Work Locations',
                hint: 'Search and add locations',
                controller: _workLocationPreferredController,
                onChanged: _onLocationChanged,
                prefixIcon: const Icon(
                  Iconsax.map,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                suffixIcon:
                    _isFetchingSuggestions
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : null,
              ),
              if (_locationSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _locationSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _locationSuggestions[index];
                      return ListTile(
                        leading: const Icon(Iconsax.location),
                        title: Text(suggestion['description']),
                        onTap: () => _addLocation(suggestion),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _selectedPreferredLocations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final loc = entry.value;
                      return Chip(
                        label: Text(
                          loc['location_name'] ??
                              loc['location_name'] ??
                              'Unknown location',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onDeleted: () => _removeLocation(index),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        side: BorderSide.none,
                      );
                    }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 30),
          // File Uploads
          Text('Documents & Images', style: AppTextStyles.h4),
          const SizedBox(height: 16),

          _buildFilePicker(
            'Adhar Card',
            _adharCard,
            user?.adharCard,
            () => _pickImage('adhar'),
          ),
          const SizedBox(height: 16),
          _buildFilePicker(
            'License',
            _license,
            user?.license,
            () => _pickImage('license'),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceFields() {
    return Consumer<ServiceBoyProvider>(
      builder: (context, provider, child) {
        if (_isLoadingService || provider.isLoadingCategories) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _existingServiceId != null
                  ? 'Service Details'
                  : 'Service Details',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: 20),

            // Image Picker
            Text('Service Title Image', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _pickImage('service'),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child:
                    _serviceImage != null
                        ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _serviceImage!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _serviceImage = null);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : provider.selectedService?.imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            provider.selectedService!.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.image,
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add Service Title Image',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 10),

            // Description
            CustomTextField(
              label: 'Description',
              hint: 'Describe your service...',
              controller: _serviceDescriptionController,
              maxLines: 4,
              prefixIcon: const Icon(
                Iconsax.document_text,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
            // const SizedBox(height: 20),

            // const SizedBox(height: 20),

            // // Trending Toggle
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.surface,
            //     borderRadius: BorderRadius.circular(16),
            //     border: Border.all(color: Theme.of(context).dividerColor),
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(
            //         Iconsax.trend_up,
            //         color: AppColors.primary,
            //         size: 20,
            //       ),
            //       const SizedBox(width: 16),
            // Expanded(
            //   child: Text(
            //     'Mark as Trending',
            //     style: AppTextStyles.labelMedium,
            //   ),
            // ),
            // Switch(
            //   value: _isTrending,
            //   onChanged: (v) => setState(() => _isTrending = v),
            //   activeColor: AppColors.primary,
            // ),
            //     ],
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
