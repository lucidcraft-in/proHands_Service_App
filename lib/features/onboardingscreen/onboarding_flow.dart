import 'package:flutter/material.dart';
import 'package:service_app/features/onboardingscreen/Onboardingpagetype.dart';
import 'package:service_app/features/auth/screens/login_screen.dart';
import 'package:service_app/core/theme/app_colors.dart';
import 'package:service_app/core/theme/app_text_styles.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'WELCOME TO JUST FIXIT',
      description:
          'Simply touch and pick to have all of your products and services delivered to your door.',
      pageType: OnboardingPageType.welcome,
    ),
    OnboardingPageData(
      title: 'FIND YOUR SERVICES',
      description:
          'Select a service from the list that correlates with your needs and then move forward.',
      pageType: OnboardingPageType.services,
    ),
    OnboardingPageData(
      title: 'BOOK YOUR DATE AND TIME',
      description:
          'Choose an appropriate time and day, then reserve your service by including an address.',
      pageType: OnboardingPageType.booking,
    ),
    OnboardingPageData(
      title: 'GO ON TO THE PAYMENT',
      description:
          'Pick your payment possibility and pay for your services regardless you selected.',
      pageType: OnboardingPageType.payment,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo or App Name
                  Text(
                    'proHands',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // Skip Button
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skipToLast,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textTertiary,
                      ),
                      child: Text('Skip', style: AppTextStyles.labelMedium),
                    ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Navigation Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Next/Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _currentPage < _pages.length - 1
                              ? _nextPage
                              : () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Continue'
                            : 'Get Started',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
