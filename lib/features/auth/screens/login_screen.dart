import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  UserType _selectedUserType = UserType.customer;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().login(
          _phoneController.text.trim(),
          _selectedUserType,
        );
        print(_selectedUserType);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => OTPVerificationScreen(
                    phone: _phoneController.text.trim(),
                    identifier:
                        _phoneController.text
                            .trim(), // Using phone as identifier
                    userType: _selectedUserType,
                  ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Strip "Exception:" prefix and show only the first sentence
          String msg = e.toString().replaceAll('Exception: ', '');
          final dotIndex = msg.indexOf('.');
          if (dotIndex > 0 && dotIndex < msg.length - 1) {
            msg = msg.substring(0, dotIndex + 1);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Welcome text
                Center(child: Text('Welcome Back!', style: AppTextStyles.h1)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Login to continue using our services',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // User Type Selection
                Text(
                  'I am a:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<UserType>(
                        title: const Text('Customer'),
                        value: UserType.customer,
                        groupValue: _selectedUserType,
                        onChanged: (UserType? value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                          print(_selectedUserType);
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserType>(
                        title: const Text('Technician'),
                        value: UserType.serviceBoy,
                        groupValue: _selectedUserType,
                        onChanged: (UserType? value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                          print(_selectedUserType);
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Phone Number field
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: _validatePhone,
                ),

                const SizedBox(height: 20),

                // Login button
                GradientButton(
                  text: 'Send OTP',
                  onPressed: isLoading ? () {} : _handleLogin,
                  isLoading: isLoading,
                  width: double.infinity,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
