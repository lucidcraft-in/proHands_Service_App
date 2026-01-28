import 'package:flutter/material.dart';
import 'package:service_app/core/theme/app_colors.dart';
import 'package:service_app/core/theme/app_text_styles.dart';

enum OnboardingPageType { welcome, services, booking, payment }

class OnboardingPageData {
  final String title;
  final String description;
  final OnboardingPageType pageType;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.pageType,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        const Spacer(flex: 3),
        // Illustration Container
        Container(
          width: size.width * 0.82,
          height: size.width * 0.82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.04),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size.width * 0.68,
                height: size.width * 0.68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.06),
                ),
              ),
              Image.asset(
                _getIllustrationPath(),
                width: size.width * 0.62,
                height: size.width * 0.62,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),
        // Content Area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 5),
      ],
    );
  }

  String _getIllustrationPath() {
    switch (data.pageType) {
      case OnboardingPageType.welcome:
        return 'assets/images/onboarding/welcome.png';
      case OnboardingPageType.services:
        return 'assets/images/onboarding/services.png';
      case OnboardingPageType.booking:
        return 'assets/images/onboarding/booking.png';
      case OnboardingPageType.payment:
        return 'assets/images/onboarding/payment.png';
    }
  }
}
