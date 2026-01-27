import 'package:flutter/material.dart';
import 'package:service_app/features/onboardingscreen/Onboardingpagetype.dart';
import 'package:service_app/features/auth/screens/login_screen.dart';

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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language Selector
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/us_flag.png', // Add your flag image
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.blue,
                                child: const Center(
                                  child: Text(
                                    '🇺🇸',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'EN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                  // Skip Button
                  TextButton(
                    onPressed: _skipToLast,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  IconButton(
                    onPressed: _currentPage > 0 ? _previousPage : null,
                    icon: const Icon(Icons.chevron_left),
                    iconSize: 32,
                    color:
                        _currentPage > 0
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                  ),

                  // Dots Indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next/Get Started Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed:
                          _currentPage < _pages.length - 1
                              ? _nextPage
                              : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                      icon: Icon(
                        _currentPage < _pages.length - 1
                            ? Icons.chevron_right
                            : Icons.check,
                      ),
                      iconSize: 32,
                      color: Colors.white,
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
