import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../home/providers/consumer_provider.dart';
import '../../../core/models/user_type.dart';
import '../../../core/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common Fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  // Service Boy Fields
  late TextEditingController _professionController;
  late TextEditingController _experienceController;
  late TextEditingController
  _servicesOfferedController; // Comma separated for now
  late TextEditingController
  _workLocationPreferredController; // Comma separated for now

  // Dropdowns/Selections
  final List<String> _workPreferenceOptions = ['Full-time', 'Part-time'];
  String? _selectedWorkPreference;

  // Files
  File? _adharCard;
  File? _license;
  File? _serviceImage;
  List<File> _portfolioImages = [];

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
    _servicesOfferedController = TextEditingController();
    _workLocationPreferredController = TextEditingController();

    // Fetch latest profile
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ConsumerProvider>();
      await provider.fetchUserProfile();
      if (mounted) {
        _initializeFromUser(provider.currentUser);
      }
    });
  }

  void _initializeFromUser(UserModel? user) {
    if (user == null) return;

    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _addressController.text = user.location;

    // Service Boy Specifics
    _professionController.text = user.profession;
    _experienceController.text = user.experience;
    _servicesOfferedController.text = user.servicesOffered.join(', ');
    _workLocationPreferredController.text = user.workLocationPreferred.join(
      ', ',
    );

    if (user.workPreference.isNotEmpty == true) {
      _selectedWorkPreference = user.workPreference.first;
      if (!_workPreferenceOptions.contains(_selectedWorkPreference)) {
        _selectedWorkPreference = null;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _professionController.dispose();
    _experienceController.dispose();
    _servicesOfferedController.dispose();
    _workLocationPreferredController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (type) {
          case 'adhar':
            _adharCard = File(image.path);
            break;
          case 'license':
            _license = File(image.path);
            break;
          case 'service':
            _serviceImage = File(image.path);
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

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<ConsumerProvider>();
      final user = provider.currentUser;
      bool success = false;

      if (user?.userType == UserType.serviceBoy) {
        // Validate required files for first time? Or allow updates without files if already present?
        // For update, files are optional usually.

        success = await provider.completeProviderProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          profession: _professionController.text.trim(),
          experience: _experienceController.text.trim(),
          servicesOffered:
              _servicesOfferedController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          workPreference:
              _selectedWorkPreference != null ? [_selectedWorkPreference!] : [],
          workLocationPreferred:
              _workLocationPreferredController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          latitude:
              0.0, // Should use real location, but for edit profile maybe keep existing or fetch?
          // The API requires lat/long.
          // If we don't change them, we should pass existing.
          // But UserModel uses 'location' string. Coordinates are not explicitly in UserModel top level?
          // backend 'location' object has coordinates.
          // For now passing 0.0 or we might need to geocode the address if changed.
          // Let's pass 0.0 or a placeholder as typical Edit Profile might not force location update unless address changes.
          // Actually API requires them.
          longitude: 0.0,
          adharCardPath: _adharCard?.path,
          licensePath: _license?.path,
          serviceImagePath: _serviceImage?.path,
          portfolioImagePaths: _portfolioImages.map((e) => e.path).toList(),
        );
      } else {
        success = await provider.updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user?.userType == UserType.serviceBoy
                    ? (provider.completeProfileError ??
                        'Failed to update profile')
                    : (provider.updateProfileError ??
                        'Failed to update profile'),
              ),
              backgroundColor: AppColors.error,
            ),
          );
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
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
    final user = provider.currentUser;
    final isServiceBoy = user?.userType == UserType.serviceBoy;

    // Watch for loading state
    final isLoading =
        isServiceBoy
            ? provider.isCompletingProfile
            : provider.isUpdatingProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.h4),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar (Static for now as image upload is complex)
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.surface,
                      backgroundImage:
                          (user?.serviceImage != null &&
                                  user!.serviceImage.isNotEmpty &&
                                  !user.serviceImage.contains('default'))
                              ? NetworkImage(user.serviceImage)
                              : null,
                      child:
                          (user?.serviceImage == null ||
                                  user!.serviceImage.isEmpty ||
                                  user.serviceImage.contains('default'))
                              ? const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.primary,
                              )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                        ),
                        child: const Icon(
                          Iconsax.camera,
                          size: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
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
                          (value == null || value.isEmpty)
                              ? 'Name is required'
                              : null,
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
                          (value == null || value.isEmpty)
                              ? 'Email is required'
                              : null,
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

                // Service Boy Specific Fields
                if (isServiceBoy) ...[
                  CustomTextField(
                    label: 'Profession',
                    hint: 'e.g. Plumber, Electrician',
                    controller: _professionController,
                    prefixIcon: const Icon(
                      Iconsax.briefcase,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Profession is required'
                                : null,
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
                      fillColor: AppColors.surface,
                      labelText: 'Work Preference',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
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
                        (value) =>
                            value == null ? 'Please select preference' : null,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Services Offered',
                    hint: 'e.g. Pipe Fixing, Drain Cleaning (comma separated)',
                    controller: _servicesOfferedController,
                    prefixIcon: const Icon(
                      Iconsax.task,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    maxLines: 2,
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Services are required'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Preferred Work Locations',
                    hint: 'e.g. North Delhi, CP (comma separated)',
                    controller: _workLocationPreferredController,
                    prefixIcon: const Icon(
                      Iconsax.map,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'Locations are required'
                                : null,
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
                  const SizedBox(height: 16),

                  // _buildFilePicker(
                  //   'Service Image (Cover)',
                  //   _serviceImage,
                  //   user?.serviceImage,
                  //   () => _pickImage('service'),
                  // ),
                  // const SizedBox(height: 16),

                  // // Portfolio
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text('Portfolio Images', style: AppTextStyles.bodyMedium),
                  //     const SizedBox(height: 8),
                  //     if (_portfolioImages.isNotEmpty ||
                  //         (user?.portfolioImages.isNotEmpty ?? false))
                  //       SizedBox(
                  //         height: 100,
                  //         child: ListView(
                  //           scrollDirection: Axis.horizontal,
                  //           children: [
                  //             // Existing remote images
                  //             if (user?.portfolioImages != null)
                  //               ...user!.portfolioImages.map((url) {
                  //                 return Container(
                  //                   margin: const EdgeInsets.only(right: 8),
                  //                   child: ClipRRect(
                  //                     borderRadius: BorderRadius.circular(8),
                  //                     child: Image.network(
                  //                       url,
                  //                       width: 100,
                  //                       height: 100,
                  //                       fit: BoxFit.cover,
                  //                     ),
                  //                   ),
                  //                 );
                  //               }),
                  //             // Locally picked images
                  //             ..._portfolioImages.asMap().entries.map((entry) {
                  //               final index = entry.key;
                  //               final file = entry.value;
                  //               return Stack(
                  //                 children: [
                  //                   Container(
                  //                     margin: const EdgeInsets.only(right: 8),
                  //                     child: ClipRRect(
                  //                       borderRadius: BorderRadius.circular(8),
                  //                       child: Image.file(
                  //                         file,
                  //                         width: 100,
                  //                         height: 100,
                  //                         fit: BoxFit.cover,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   Positioned(
                  //                     top: 0,
                  //                     right: 8,
                  //                     child: InkWell(
                  //                       onTap:
                  //                           () => _removePortfolioImage(index),
                  //                       child: const CircleAvatar(
                  //                         radius: 12,
                  //                         backgroundColor: Colors.red,
                  //                         child: Icon(
                  //                           Icons.close,
                  //                           size: 14,
                  //                           color: Colors.white,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               );
                  //             }),
                  //           ],
                  //         ),
                  //       ),
                  //     if (_portfolioImages.isNotEmpty ||
                  //         (user?.portfolioImages.isNotEmpty ?? false))
                  //       const SizedBox(height: 8),
                  //     OutlinedButton.icon(
                  //       onPressed: _pickPortfolioImages,
                  //       icon: const Icon(Icons.add_photo_alternate),
                  //       label: const Text('Add Portfolio Images'),
                  //       style: OutlinedButton.styleFrom(
                  //         side: const BorderSide(color: AppColors.primary),
                  //         // primary: AppColors.primary, // Deprecated in newer Flutter, use foregroundColor
                  //         foregroundColor: AppColors.primary,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 32),
                ],

                // Save button
                GradientButton(
                  text: 'Save Changes',
                  onPressed: isLoading ? () {} : _handleSave,
                  isLoading: isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
