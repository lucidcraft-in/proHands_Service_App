import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/full_screen_image_viewer.dart';

class ServiceBoySignUpScreen extends StatefulWidget {
  const ServiceBoySignUpScreen({super.key});

  @override
  State<ServiceBoySignUpScreen> createState() => _ServiceBoySignUpScreenState();
}

class _ServiceBoySignUpScreenState extends State<ServiceBoySignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();

  // State variables
  String _experience = '1 Year';
  final List<String> _selectedServices = [];
  final List<String> _selectedDistricts = [];
  bool _icAttached = false;
  bool _aadhaarAttached = false;
  final List<String> _galleryImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  Future<void> _pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _galleryImages.add(image.path);
      });
    }
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galleryImages.removeAt(index);
    });
  }

  final List<String> _services = [
    'Cleaning',
    'Plumbing',
    'Electrician',
    'Painting',
    'AC Repair',
    'Carpentry',
    'Gardening',
    'Moving',
  ];

  final List<String> _districts = [
    'Kannur',
    'Kozhikode',
    'Wayanad',
    'Malappuram',
    'Palakkad',
    'Thrissur',
    'Ernakulam',
    'Idukki',
  ];

  final List<String> _expOptions = [
    'Fresher',
    '1 Year',
    '2 Years',
    '3 Years',
    '4 Years',
    '5+ Years',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _toggleService(String service) {
    setState(() {
      if (_selectedServices.contains(service)) {
        _selectedServices.remove(service);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _toggleDistrict(String district) {
    setState(() {
      if (_selectedDistricts.contains(district)) {
        _selectedDistricts.remove(district);
      } else {
        _selectedDistricts.add(district);
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedServices.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one service')),
        );
        return;
      }
      if (!_icAttached || !_aadhaarAttached) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please attach both IC and Aadhaar')),
        );
        return;
      }
      if (_selectedDistricts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select at least one work preference district',
            ),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration submitted successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Service Provider Signup', style: AppTextStyles.h4),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Details'),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameController,
                prefixIcon: const Icon(
                  Iconsax.user,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                validator: (val) => val!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(
                  Iconsax.call,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                validator: (val) => val!.isEmpty ? 'Phone is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email Address',
                hint: 'Enter email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Iconsax.sms,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                validator: (val) => val!.isEmpty ? 'Email is required' : null,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Services Offered'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _services.map((service) {
                      final isSelected = _selectedServices.contains(service);
                      return FilterChip(
                        label: Text(service),
                        selected: isSelected,
                        onSelected: (_) => _toggleService(service),
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: AppTextStyles.bodySmall.copyWith(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Experience'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _experience,
                    isExpanded: true,
                    icon: const Icon(Iconsax.arrow_down_1, size: 20),
                    items:
                        _expOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: AppTextStyles.bodyMedium),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _experience = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Attachments (ID Proof)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildAttachmentButton(
                      'IC / ID Card',
                      _icAttached,
                      () => setState(() => _icAttached = !_icAttached),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAttachmentButton(
                      'Aadhaar Card',
                      _aadhaarAttached,
                      () =>
                          setState(() => _aadhaarAttached = !_aadhaarAttached),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Location & Work Preference'),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Current Location',
                hint: 'Enter your city/area',
                controller: _locationController,
                prefixIcon: const Icon(
                  Iconsax.location,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
                validator:
                    (val) => val!.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Preferred Work Districts',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _districts.map((district) {
                      final isSelected = _selectedDistricts.contains(district);
                      return FilterChip(
                        label: Text(district),
                        selected: isSelected,
                        onSelected: (_) => _toggleDistrict(district),
                        selectedColor: AppColors.orange.withOpacity(0.2),
                        checkmarkColor: AppColors.orange,
                        labelStyle: AppTextStyles.bodySmall.copyWith(
                          color:
                              isSelected
                                  ? AppColors.orange
                                  : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.orange
                                    : AppColors.border,
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('My Feed'),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _galleryImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _galleryImages.length) {
                    return GestureDetector(
                      onTap: _pickGalleryImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Iconsax.add,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FullScreenImageViewer(
                                imagePath: _galleryImages[index],
                                tag: 'signup_gallery_$index',
                              ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'signup_gallery_$index',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_galleryImages[index])),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeGalleryImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
              GradientButton(
                text: 'Complete Signup',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildAttachmentButton(
    String title,
    bool isAttached,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isAttached ? AppColors.success.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAttached ? AppColors.success : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isAttached ? Iconsax.document_text5 : Iconsax.document_upload,
              color: isAttached ? AppColors.success : AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: isAttached ? AppColors.success : AppColors.textPrimary,
                fontWeight: isAttached ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isAttached)
              Text(
                'Attached',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
