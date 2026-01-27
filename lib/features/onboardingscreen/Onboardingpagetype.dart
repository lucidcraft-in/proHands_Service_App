import 'package:flutter/material.dart';
import 'package:service_app/features/onboardingscreen/WelcomeIllustration.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Circle
          Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(child: _buildIllustration()),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    switch (data.pageType) {
      case OnboardingPageType.welcome:
        return const WelcomeIllustration();
      case OnboardingPageType.services:
        return const ServicesIllustration();
      case OnboardingPageType.booking:
        return const BookingIllustration();
      case OnboardingPageType.payment:
        return const PaymentIllustration();
    }
  }
}
