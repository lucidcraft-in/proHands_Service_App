import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background message parsing
  await Firebase.initializeApp();
  developer.log('Handling a background message: ${message.messageId}',
      name: 'PushNotificationService');
}

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initializes all notification services, listens to foreground messages, and sets up token tracking.
  static Future<void> initialize() async {
    try {
      // 0. Register Background Message Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 1. Request Notification Permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log(
        'User notification permission status: ${settings.authorizationStatus}',
        name: 'PushNotificationService',
      );

      // 2. Local Notifications Setup (For Foreground Display on Android)
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationClick(response.payload);
        },
      );

      // Create high importance channel
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Set iOS foreground options
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Fetch and store the FCM Token
      await _retrieveAndStoreFCMToken();

      // 4. Listen to Token Refresh
      _firebaseMessaging.onTokenRefresh.listen((String token) async {
        developer.log('FCM Token refreshed: $token', name: 'PushNotificationService');
        await StorageService.saveFCMToken(token);
      });

      // 5. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Foreground message received: ${message.notification?.title}',
            name: 'PushNotificationService');
        _showForegroundNotification(message);
      });

      // 6. Handle Background/Terminated Click Listeners
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('Notification clicked from background state',
            name: 'PushNotificationService');
        _handleNotificationMessage(message);
      });

      // Get initial message if the app was launched from a completely terminated state
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        developer.log('Notification clicked from terminated state',
            name: 'PushNotificationService');
        _handleNotificationMessage(initialMessage);
      }
    } catch (e, stack) {
      developer.log(
        'Error during PushNotificationService initialization: $e',
        error: e,
        stackTrace: stack,
        name: 'PushNotificationService',
      );
    }
  }

  /// Retrieves the device FCM token and registers it locally in StorageService.
  static Future<void> _retrieveAndStoreFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        developer.log(
          '\n=======================================================\n'
          'FCM DEVICE TOKEN:\n$token\n'
          '=======================================================\n',
          name: 'PushNotificationService',
        );
        await StorageService.saveFCMToken(token);
      } else {
        developer.log('Failed to retrieve FCM Device Token', name: 'PushNotificationService');
      }
    } catch (e) {
      developer.log('Error getting FCM token: $e', error: e, name: 'PushNotificationService');
    }
  }

  /// Displays foreground notifications using local notifications plugin on Android
  static void _showForegroundNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Logic to parse message payload and direct users to correct routes.
  static void _handleNotificationMessage(RemoteMessage message) {
    // Navigate or trigger appropriate flow based on message payload/data
    developer.log('Handling message click. Payload: ${message.data}',
        name: 'PushNotificationService');
  }

  /// Handles local notification click response
  static void _handleNotificationClick(String? payload) {
    developer.log('Local Notification payload clicked: $payload',
        name: 'PushNotificationService');
  }
}
