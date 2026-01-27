import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Zain Dorwart');
  final _emailController = TextEditingController(text: 'zaindorwart12@gmail.com');
  final _phoneController = TextEditingController(text: '+1 234 567 8900');
  final _addressController = TextEditingController(text: 'Mesa, New Jersey - 45463');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: AppTextStyles.h4,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.background,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 3,
                          ),
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
                
                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your name',
                  controller: _nameController,
                  prefixIcon: const Icon(
                    Iconsax.user,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Email
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Phone
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Iconsax.call,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Address
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Save button
                GradientButton(
                  text: 'Save Changes',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
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
