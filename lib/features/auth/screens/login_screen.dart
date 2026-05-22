import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/user_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';
import '../../../core/services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  UserType _selectedUserType = UserType.customer;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDetails();
  }

  Future<void> _loadSavedDetails() async {
    final details = await StorageService.getLastLoginDetails();
    if (details['email'] != null) {
      _emailController.text = details['email']!;
    }
    if (details['phone'] != null) {
      _phoneController.text = details['phone']!;
    }
    if (details['userType'] != null) {
      setState(() {
        _selectedUserType = details['userType'];
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terms & Conditions'),
            content: const SingleChildScrollView(
              child: Text(
                'Welcome to proHands! By using our platform, you agree to comply with and be bound by the following terms of service. '
                'proHands provides a connecting platform between customers and professional service technicians. '
                'All service bookings, payments, and deliverables are subject to the platform guidelines. '
                'Please ensure all information provided is accurate and truthful. We reserve the right to suspend accounts '
                'violating platform policies. Thank you for choosing proHands!',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'At proHands, we value your privacy. We collect email, phone number, and location details '
                'solely to facilitate service matches and authenticate users. Your personal data is stored securely '
                'and never shared with unauthorized third parties. By registering, you consent to notifications '
                'related to service booking statuses and OTP messages.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _connectSupport() async {
    const phoneNumber = '9876543210';
    const message =
        "Hi proHands Support! I need help with logging in / using the app.";

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final phoneWithCountry =
        cleanPhone.startsWith('91') ? cleanPhone : '91$cleanPhone';

    final whatsappUrl = Uri.parse(
      "whatsapp://send?phone=$phoneWithCountry&text=${Uri.encodeComponent(message)}",
    );
    final fallbackUrl = Uri.parse(
      "https://wa.me/$phoneWithCountry?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch WhatsApp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  static const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" fill="white">
  <path d="M380.9 97.1C339 55.1 283.2 32 223.9 32c-122.4 0-222 99.6-222 222 0 39.1 10.2 77.3 29.6 111L3.9 480l117.7-30.9c32.4 17.7 68.9 27 106.1 27h.1c122.3 0 224.1-99.6 224.1-222 0-59.3-25.2-115-67.1-157zm-157 341.6c-33.2 0-65.7-8.9-94-25.7l-6.7-4-69.8 18.3L72 359.2l-4.4-7c-18.5-29.4-28.2-63.3-28.2-98.2 0-101.7 82.8-184.5 184.6-184.5 49.3 0 95.6 19.2 130.4 54.1 34.8 34.9 56.2 81.2 56.1 130.5 0 101.8-84.9 184.6-186.6 184.6zm101.2-138.2c-5.5-2.8-32.8-16.2-37.9-18-5.1-1.9-8.8-2.8-12.5 2.8-3.7 5.6-14.3 18-17.6 21.8-3.2 3.7-6.5 4.2-12 1.4-32.6-16.3-54-29.1-75.5-66-5.7-9.8 5.7-9.1 16.3-30.3 1.8-3.7.9-6.9-.5-9.7-1.4-2.8-12.5-30.1-17.1-41.2-4.5-10.8-9.1-9.3-12.5-9.5-3.2-.2-6.9-.2-10.6-.2-3.7 0-9.7 1.4-14.8 6.9-5.1 5.6-19.4 19-19.4 46.3 0 27.3 19.9 53.7 22.6 57.4 2.8 3.7 39.1 59.7 94.8 83.8 35.2 15.2 49 16.5 66.6 13.9 10.7-1.6 32.8-13.4 37.4-26.4 4.6-13 4.6-24.1 3.2-26.4-1.3-2.5-5-3.9-10.5-6.6z"/>
</svg>
''';

  Future<void> _handleLogin() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms & Conditions and Privacy Policy to proceed',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().login(
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _selectedUserType,
        );
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => OTPVerificationScreen(
                    email: _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    identifier:
                        _emailController.text
                            .trim(), // Using email as identifier
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
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
                      color: Theme.of(context).colorScheme.surface,
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
                        title: Text('Customer'),
                        value: UserType.customer,
                        groupValue: _selectedUserType,
                        onChanged: (UserType? value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<UserType>(
                        title: Text('Technician'),
                        value: UserType.serviceBoy,
                        groupValue: _selectedUserType,
                        onChanged: (UserType? value) {
                          setState(() {
                            _selectedUserType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Email field
                CustomTextField(
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: _validateEmail,
                ),

                const SizedBox(height: 20),

                // Phone field
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.length < 10) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Terms & Conditions Checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = _showTermsDialog,
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = _showPrivacyDialog,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

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

      floatingActionButton: FloatingActionButton(
        onPressed: _connectSupport,
        backgroundColor: const Color(0xFF25D366),
        child: SvgPicture.string(
          _whatsappSvg,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),

      // ElevatedButton(
      //   onPressed: _connectSupport,
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: const Color(0xFF25D366),
      //     padding: const EdgeInsets.symmetric(vertical: 16),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //   ),
      //   child: const Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Icon(Icons.send, color: Colors.white),
      //       SizedBox(width: 8),
      //       Text(
      //         'Connect for Help',
      //         style: TextStyle(
      //           fontWeight: FontWeight.bold,
      //           color: Colors.white,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      // FloatingActionButton.extended(
      //   onPressed: _connectSupport,
      //   backgroundColor: const Color(0xFF25D366),
      //   icon: SvgPicture.string(
      //     _whatsappSvg,
      //     width: 24,
      //     height: 24,
      //     colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      //   ),
      //   label: const Text(
      //     'Connect for Help',
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      //   ),
      // ),
    );
  }
}
