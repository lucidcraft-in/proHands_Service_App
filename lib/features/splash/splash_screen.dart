import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import '../../core/models/user_type.dart';
import '../onboardingscreen/onboarding_flow.dart';
import '../home/screens/main_screen.dart';
import '../service_boy/screens/service_boy_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Map<String, dynamic>? _initialData;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Zoom in effect
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );

    // Start fetching data and animation simultaneously
    _startInitProcess();
  }

  Future<void> _startInitProcess() async {
    // Start the animation
    _animationController.forward();

    // Fetch initial routing data
    _initialData = await _getInitialData();

    // Check if animation is finished, if so route immediately,
    // otherwise wait for animation to finish
    if (_animationController.isCompleted) {
      _routeToNextScreen();
    } else {
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _routeToNextScreen();
        }
      });
    }
  }

  Future<Map<String, dynamic>> _getInitialData() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      final userType = await StorageService.getUserType();
      return {'isLoggedIn': isLoggedIn, 'userType': userType};
    } catch (e) {
      // Fallback in case of error
      return {'isLoggedIn': false, 'userType': null};
    }
  }

  void _routeToNextScreen() {
    if (!mounted) return;

    final isLoggedIn = _initialData?['isLoggedIn'] ?? false;
    final userType = _initialData?['userType'];

    Widget nextScreen;
    if (!isLoggedIn || userType == null) {
      nextScreen = const OnboardingFlow();
    } else if (userType == UserType.customer) {
      nextScreen = const MainScreen();
    } else {
      nextScreen = const ServiceBoyMainScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF808080), // Gray
              Color(0xFF303030), // Darker gray for depth
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(125),
                child: Image.asset(
                  'assets/images/logo1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
