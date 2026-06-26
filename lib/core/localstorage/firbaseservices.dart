// lib/core/services/firebase_messaging_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firstedu/core/navigatorkey/navigatorkey.dart';
import 'package:firstedu/core/localstorage/localstorage.dart';
import 'package:firstedu/core/network/api_endpoint.dart';
import 'package:firstedu/res/routes/approutesname.dart';
import 'package:firstedu/utils/apptoster/errortoaster.dart';

const String _forceLogoutType = 'FORCE_LOGOUT';


@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    debugPrint('📨 [BG] Message received: ${message.messageId}');
    debugPrint('📨 [BG] Data: ${message.data}');
  }

  // 🚨 FORCE_LOGOUT in terminated/background state
  // Only clear storage here — UI navigation happens when app opens
  if (message.data['type'] == _forceLogoutType) {
    await UserLocalStorage.clearUser();
    if (kDebugMode) debugPrint('🚨 [BG] FORCE_LOGOUT — storage cleared');
  }
}

final FlutterLocalNotificationsPlugin fltNotification =
    FlutterLocalNotificationsPlugin();

int _notificationId = 0;

const AndroidInitializationSettings _androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const DarwinInitializationSettings _iosInit = DarwinInitializationSettings(
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);

const InitializationSettings _initSettings = InitializationSettings(
  android: _androidInit,
  iOS: _iosInit,
);

Future<void> handleForceLogout() async {
  if (kDebugMode) debugPrint('🚨 [FCM] FORCE_LOGOUT received — logging out...');

  // 1️⃣ Call backend logout API
  try {
    final String? token = await UserLocalStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final dio = Dio();
      await dio.post(
        ApiEndpoint.logout,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );
      if (kDebugMode) debugPrint('✅ [FCM] Backend logout called');
    }
  } catch (e) {
    debugPrint('⚠️ [FCM] Backend logout failed (ignored): $e');
  }

  // 2️⃣ Clear local storage
  await UserLocalStorage.clearUser();

  // 3️⃣ Show toast
  AppToast.errorGlobal(
    title: "Session Ended",
    message: "You logged in from another device.",
  );

  // 4️⃣ Navigate to login — remove all routes
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRoutesName.login,
    (route) => false,
  );
}

// ─────────────────────────────────────────────────────────────
// 🔔 Show a local push notification
// ─────────────────────────────────────────────────────────────
Future<void> showGeneralNotification({
  required Map<String, dynamic> data,
  required RemoteNotification notification,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'firstedu_general_channel',
    'General Notifications',
    channelDescription: 'General FirstEdu app notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    visibility: NotificationVisibility.public,
    icon: '@mipmap/ic_launcher',
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await fltNotification.show(
    _notificationId++,
    notification.title,
    notification.body,
    notificationDetails,
    payload: jsonEncode(data),
  );
}

// ─────────────────────────────────────────────────────────────
// 👆 Tap handler — called when user taps a local notification
// ─────────────────────────────────────────────────────────────
void onNotificationTap(NotificationResponse response) {
  if (response.payload == null || response.payload!.isEmpty) return;

  try {
    final Map<String, dynamic> data =
        jsonDecode(response.payload!) as Map<String, dynamic>;
    Future.microtask(() => handleNotificationNavigation(data));
  } catch (e) {
    debugPrint('❌ [Notification] Failed to parse payload: $e');
  }
}

// ─────────────────────────────────────────────────────────────
// 🧭 Navigate based on notification payload type
// ─────────────────────────────────────────────────────────────
void handleNotificationNavigation(Map<String, dynamic> data) {
  if (kDebugMode) {
    debugPrint('🧭 [Notification] Navigating with data: $data');
  }

  final String? type = data['type'] as String?;

  switch (type) {
    case _forceLogoutType:
      handleForceLogout();
      break;

    // Add your own deep-link cases here, e.g.:
    // case 'course':
    //   navigatorKey.currentState?.pushNamed(
    //     AppRoutesName.courseDetail,
    //     arguments: data['course_id'],
    //   );
    //   break;

    default:
      navigatorKey.currentState?.pushNamed(AppRoutesName.entry);
      break;
  }
}

// ─────────────────────────────────────────────────────────────
// 🚀 Main entry point — call once in main.dart
// ─────────────────────────────────────────────────────────────
Future<void> initMessaging() async {
  // 1️⃣ Register background handler FIRST
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // 2️⃣ Initialise local notifications
  await fltNotification.initialize(
    _initSettings,
    onDidReceiveNotificationResponse: onNotificationTap,
    onDidReceiveBackgroundNotificationResponse: onNotificationTap,
  );

  // 3️⃣ Create Android notification channel
  await _createNotificationChannel();

  // 4️⃣ Request permissions (iOS / Android 13+)
  final NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

  if (kDebugMode) {
    debugPrint('🔐 [FCM] Permission status: ${settings.authorizationStatus}');
  }

  await _saveFcmToken();

  FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
    if (kDebugMode) debugPrint('🔄 [FCM] Token refreshed: $newToken');
    await UserLocalStorage.saveFcmToken(newToken);
  });

  final RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    if (kDebugMode) {
      debugPrint(
        '📨 [FCM] App opened from terminated: ${initialMessage.messageId}',
      );
    }
    await Future.delayed(const Duration(milliseconds: 500));

    if (initialMessage.data['type'] == _forceLogoutType) {
      await handleForceLogout();
    } else {
      handleNotificationNavigation(initialMessage.data);
    }
  }

  // 8️⃣ FOREGROUND messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('📨 [FCM] Foreground message: ${message.messageId}');
    }

    // 🚨 Force logout check
    if (message.data['type'] == _forceLogoutType) {
      handleForceLogout();
      return; // don't show notification
    }

    final RemoteNotification? notification = message.notification;
    if (notification != null) {
      showGeneralNotification(data: message.data, notification: notification);
    }
  });

  // 9️⃣ BACKGROUND opened (user tapped notification)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('📨 [FCM] Background opened: ${message.messageId}');
    }

    // 🚨 Force logout check
    if (message.data['type'] == _forceLogoutType) {
      handleForceLogout();
      return;
    }

    handleNotificationNavigation(message.data);
  });

  if (kDebugMode) debugPrint('✅ [FCM] Firebase Messaging initialised.');
}

// ─────────────────────────────────────────────────────────────
// 🔧 Helpers
// ─────────────────────────────────────────────────────────────

Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'firstedu_general_channel',
    'General Notifications',
    description: 'General FirstEdu app notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  await fltNotification
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

Future<void> _saveFcmToken() async {
  try {
    final String? token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await UserLocalStorage.saveFcmToken(token);
      if (kDebugMode) debugPrint('📱 [FCM] Token is : $token');
    }
  } catch (e) {
    debugPrint('❌ [FCM] Failed to get token is : $e');
  }
}
