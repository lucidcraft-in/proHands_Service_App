import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/models/user_type.dart';
import '../../../core/services/dummy_data_service.dart';
import '../../home/screens/main_screen.dart';
import '../../service_boy/screens/service_boy_main_screen.dart';
import '../../../core/services/storage_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String identifier;
  final String? phone;
  final UserType userType;

  const OTPVerificationScreen({
    super.key,
    required this.phone,
    required this.identifier,
    required this.userType,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });

    Future.delayed(const Duration(seconds: 1), _tick);
  }

  void _tick() {
    if (_secondsRemaining > 0 && mounted) {
      setState(() => _secondsRemaining--);
      Future.delayed(const Duration(seconds: 1), _tick);
    } else if (mounted) {
      setState(() => _canResend = true);
    }
  }

  Future<void> _handleResend() async {
    // Simulate resend OTP
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      _startTimer();
    }
  }

  Future<void> _handleVerify([String? manualOtp]) async {
    final otp = manualOtp ?? _otpController.text;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Verify OTP using dummy data service
      final isValid = DummyDataService.instance.vrifyotpuser(
        widget.identifier,
        widget.userType,
        otp,
      );

      setState(() => _isLoading = false);

      if (isValid) {
        // Get user data
        final user = DummyDataService.instance.getUserData(
          widget.identifier,
          widget.userType,
        );
        print('User ${user?.userType} logged in successfully.');

        // Save user type to shared preferences
        await StorageService.saveUserType(widget.userType);

        if (widget.userType == UserType.customer) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ServiceBoyMainScreen(),
            ),
            (route) => false,
          );
        }

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome ${user?.name ?? "User"}!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
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
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    widget.userType == UserType.customer
                        ? Icons.person_outline
                        : Icons.work_outline,
                    size: 50,
                    color: AppColors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Header
              Center(child: Text('OTP Verification', style: AppTextStyles.h2)),
              const SizedBox(height: 12),

              // User type badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.userType.displayName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'Enter the verification code we sent to your phone\n',
                      ),
                      TextSpan(
                        text: widget.identifier,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: AppColors.white,
                  inactiveFillColor: AppColors.white,
                  selectedFillColor: AppColors.white,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  selectedColor: AppColors.primary,
                ),
                cursorColor: AppColors.primary,
                enableActiveFill: true,
                textStyle: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
                onCompleted: (value) {
                  // Auto verify when complete
                  _handleVerify(value);
                },
                onChanged: (value) {},
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 24),

              // Timer and resend
              Center(
                child:
                    _canResend
                        ? TextButton(
                          onPressed: _handleResend,
                          child: Text(
                            'Resend Code',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        : Text(
                          'Resend code in $_secondsRemaining seconds',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
              ),

              const SizedBox(height: 32),

              // Verify button
              GradientButton(
                text: 'Verify',
                onPressed: _handleVerify,
                isLoading: _isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
