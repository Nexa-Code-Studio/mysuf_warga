import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background tasks if needed
  await Firebase.initializeApp();
  developer.log(
    'Menerima notifikasi di background: ${message.notification?.title}',
    name: 'NotificationService',
  );
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  /// Retrieves the loaded FCM token for the device
  static String? get fcmToken => _fcmToken;

  /// Initializes Firebase and configures Cloud Messaging settings
  static Future<void> initialize() async {
    try {
      // 1. Initialize Firebase Core
      await Firebase.initializeApp();
      developer.log('Firebase berhasil diinisialisasi', name: 'NotificationService');

      // 2. Request Notification permissions (Android 13+ & iOS)
      await _requestPermissions();

      // 3. Fetch and register FCM Token
      await _fetchFcmToken();

      // 4. Set up Background Messaging Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 5. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log(
          'Menerima notifikasi di foreground:\n'
          'Title: ${message.notification?.title}\n'
          'Body: ${message.notification?.body}\n'
          'Data: ${message.data}',
          name: 'NotificationService',
        );

        // Standard debug message output
        if (kDebugMode) {
          print('🔔 NOTIFIKASI BARU: ${message.notification?.title} - ${message.notification?.body}');
        }
      });

      // 6. Handle notification click when app is opened from a background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log(
          'Aplikasi dibuka dari status notifikasi: ${message.notification?.title}',
          name: 'NotificationService',
        );
      });

      // 7. Handle notification click when app is opened from a terminated state
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        developer.log(
          'Aplikasi diluncurkan dari status notifikasi mati: ${initialMessage.notification?.title}',
          name: 'NotificationService',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Gagal menginisialisasi NotificationService',
        error: e,
        stackTrace: stackTrace,
        name: 'NotificationService',
      );
    }
  }

  /// Request permissions for incoming push notifications (Android 13+ and iOS support)
  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    developer.log(
      'Status izin notifikasi pengguna: ${settings.authorizationStatus}',
      name: 'NotificationService',
    );
  }

  /// Retrieve and display the unique device token for target notification tests
  static Future<void> _fetchFcmToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        developer.log(
          '\n======================================================\n'
          '🔥 FCM DEVICE TOKEN:\n'
          '$_fcmToken\n'
          '======================================================',
          name: 'NotificationService',
        );
      } else {
        developer.log('FCM Token kosong.', name: 'NotificationService');
      }
    } catch (e) {
      developer.log('Gagal mengambil FCM Token', error: e, name: 'NotificationService');
    }

    // Auto-refresh token listener
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      developer.log('FCM Token diperbarui: $newToken', name: 'NotificationService');
    });
  }
}
