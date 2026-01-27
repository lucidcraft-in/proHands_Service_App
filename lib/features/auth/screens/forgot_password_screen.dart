import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                
                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Header
                Center(
                  child: Text(
                    _emailSent ? 'Check Your Email' : 'Forgot Password?',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _emailSent
                        ? 'We have sent password recovery instructions to your email.'
                        : 'No worries! Enter your email and we\'ll send you reset instructions.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                if (!_emailSent) ...[
                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    validator: _validateEmail,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Reset button
                  GradientButton(
                    text: 'Send Reset Link',
                    onPressed: _handleResetPassword,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                ] else ...[
                  // Resend button
                  GradientButton(
                    text: 'Resend Email',
                    onPressed: () {
                      setState(() => _emailSent = false);
                    },
                    width: double.infinity,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Back to login
                  CustomButton(
                    text: 'Back to Login',
                    onPressed: () => Navigator.of(context).pop(),
                    isOutlined: true,
                    width: double.infinity,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Back to login link
                if (!_emailSent)
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back to Login',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
