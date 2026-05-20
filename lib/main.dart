import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';

import 'features/service_boy/providers/service_boy_provider.dart';
import 'features/home/providers/consumer_provider.dart';
import 'features/home/providers/notification_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/services/push_notification_service.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Push Notifications inside a resilient try-catch
  try {
    await Firebase.initializeApp();
    await PushNotificationService.initialize();
  } catch (e, stack) {
    developer.log(
      '⚠️ Firebase initialization skipped or failed. '
      'Verify that google-services.json (Android) or GoogleService-Info.plist (iOS) are provided.',
      error: e,
      stackTrace: stack,
      name: 'main',
    );
  }

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceBoyProvider()),
        ChangeNotifierProvider(create: (_) => ConsumerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'PRO HNADS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
