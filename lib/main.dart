import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/onboardingscreen/onboarding_flow.dart';
import 'core/services/storage_service.dart';
import 'core/models/user_type.dart';
import 'features/home/screens/main_screen.dart';
import 'features/service_boy/screens/service_boy_main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRO HNADS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<UserType?>(
        future: StorageService.getUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final userType = snapshot.data;
          if (userType == null) {
            return const OnboardingFlow();
          }

          if (userType == UserType.customer) {
            return const MainScreen();
          } else {
            return const ServiceBoyMainScreen();
          }
        },
      ),
    );
  }
}
