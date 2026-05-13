import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/models/user_type.dart';
import '../../location/screens/location_fetch_screen.dart';
import '../../service_boy/screens/service_boy_main_screen.dart';
import '../providers/auth_provider.dart';
import '../../home/services/consumer_service.dart';
import '../../home/screens/main_screen.dart';
import '../../../core/services/storage_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String identifier;
  final String? email;
  final UserType userType;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.identifier,
    required this.userType,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    try {
      _otpController.dispose();
    } catch (e) {
      debugPrint('Error disposing OTP controller: $e');
    }
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
    try {
      await context.read<AuthProvider>().login(widget.email!, widget.userType);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleVerify([String? manualOtp]) async {
    debugPrint('========= step: _handleVerify started ==========');
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

    try {
      debugPrint('========= step: calling verifyOtp ==========');
      await context.read<AuthProvider>().verifyOtp(widget.email!, otp);
      debugPrint('========= step: verifyOtp completed ==========');

      if (mounted) {
        final user = context.read<AuthProvider>().currentUser;
        debugPrint(
          '========= step: user retrieved: ${user?.userType} ==========',
        );
        print(user);
        // Check for profile completion or specific logic if needed
        // For now, assume if we have a user (which should be true after verifyOtp), we proceed

        if (user != null) {
          print('User ${user.userType} logged in successfully.');

          // Navigate based on user type
          print(user.userType);

          if (user.userType == UserType.customer) {
            // Fetch full profile to get location
            try {
              final consumerService = ConsumerService();
              final fullProfile = await consumerService.getMe();

              // Check if location exists
              if (fullProfile.latitude != null &&
                  fullProfile.longitude != null &&
                  fullProfile.latitude != 0.0) {
                debugPrint(
                  '========= step: location exists, navigating to MainScreen ==========',
                );
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                  return;
                }
              }
            } catch (e) {
              debugPrint('Error fetching/saving profile during login: $e');
              // Continue to LocationFetchScreen if profile fetch fails
            }

            debugPrint(
              '========= step: navigating to LocationFetchScreen ==========',
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder:
                    (context) => const LocationFetchScreen(isServiceBoy: false),
              ),
              (route) => false,
            );
          } else {
            // Service Boy Profile Check
            try {
              final consumerService = ConsumerService();
              final fullProfile = await consumerService.getMe();

              if (fullProfile.latitude != null &&
                  fullProfile.longitude != null &&
                  fullProfile.latitude != 0.0) {
                debugPrint(
                  '========= step: location exists, navigating to ServiceBoyMainScreen ==========',
                );
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const ServiceBoyMainScreen(),
                    ),
                    (route) => false,
                  );
                  return;
                }
              }
            } catch (e) {
              debugPrint('Error fetching technician profile during login: $e');
            }

            debugPrint(
              '========= step: navigating to LocationFetchScreen (ServiceBoy) ==========',
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder:
                    (context) => const LocationFetchScreen(isServiceBoy: true),
              ),
              (route) => false,
            );
          }

          // Show success message after navigation
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome ${user.name ?? "User"}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          });
        }
      } else {
        debugPrint(
          '========= step: widget not mounted after verifyOtp ==========',
        );
      }
    } catch (e) {
      debugPrint('========= step: error in _handleVerify: $e ==========');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                    color: Theme.of(context).colorScheme.surface,
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
                      color: Theme.of(context).colorScheme.surface,
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
                      TextSpan(
                        text:
                            'Enter the verification code we sent to your email\n',
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
                  activeFillColor: Theme.of(context).colorScheme.surface,
                  inactiveFillColor: Theme.of(context).colorScheme.surface,
                  selectedFillColor: Theme.of(context).colorScheme.surface,
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
                onPressed: isLoading ? () {} : () => _handleVerify(),
                isLoading: isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
