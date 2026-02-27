import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/onboardingscreen/onboarding_flow.dart';
import 'core/services/storage_service.dart';
import 'core/models/user_type.dart';
import 'features/home/screens/main_screen.dart';
import 'features/service_boy/screens/service_boy_main_screen.dart';
import 'features/auth/providers/auth_provider.dart';

import 'features/service_boy/providers/service_boy_provider.dart';
import 'features/home/providers/consumer_provider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceBoyProvider()),
        ChangeNotifierProvider(create: (_) => ConsumerProvider()),
      ],
      child: MaterialApp(
        title: 'PRO HNADS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: FutureBuilder<Map<String, dynamic>>(
          future: _getInitialData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isLoggedIn = snapshot.data?['isLoggedIn'] ?? false;
            final userType = snapshot.data?['userType'];

            if (!isLoggedIn || userType == null) {
              return const OnboardingFlow();
            }

            // Restore user session in provider if logged in
            // Ideally we'd await this, but for now we just kick it off or rely on storage
            // Better to load it in the future above

            if (userType == UserType.customer) {
              return const MainScreen();
            } else {
              return const ServiceBoyMainScreen();
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getInitialData() async {
    final isLoggedIn = await StorageService.isLoggedIn();
    final userType = await StorageService.getUserType();

    // You might want to also load the full user profile here into AuthProvider
    // But since we can't easily access the Provider ref inside this static/agnostic method,
    // we'll leave it to the next screen or handle it slightly differently.
    // For now, this is enough to route.

    return {'isLoggedIn': isLoggedIn, 'userType': userType};
  }
}
