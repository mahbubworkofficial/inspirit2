// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get/get.dart';
// import 'package:reel_me/res/components/api_service.dart';
//
// class FCMService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//
//   Future<void> initialize() async {
//     try {
//       // Register ApiService if not already registered
//       if (!Get.isRegistered<ApiService>()) {
//         Get.put(ApiService());
//         debugPrint('ApiService registered in FCMService');
//       }
//
//       // Request permission for notifications (iOS)
//       NotificationSettings settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//       debugPrint('Notification permission status: ${settings.authorizationStatus}');
//
//       // Get the FCM token
//       String? fcmToken = await _messaging.getToken();
//       if (fcmToken != null) {
//         debugPrint('FCM Token: $fcmToken');
//         await _registerFCMToken(fcmToken);
//       } else {
//         debugPrint('Failed to get FCM token');
//       }
//
//       // Handle token refresh
//       _messaging.onTokenRefresh.listen((newToken) async {
//         debugPrint('FCM Token refreshed: $newToken');
//         await _registerFCMToken(newToken);
//       });
//     } catch (e) {
//       debugPrint('Error initializing FCM: $e');
//     }
//   }
//
//   Future<void> _registerFCMToken(String fcmToken) async {
//     try {
//       final apiService = Get.find<ApiService>();
//       final token = await _storage.read(key: 'access_token');
//       if (token == null) {
//         debugPrint('No access token found for FCM registration');
//         return;
//       }
//       final response = await apiService.registerFCMToken(
//         token: token,
//         fcmToken: fcmToken,
//       );
//       if (response['statusCode'] == 200 || response['statusCode'] == 201) {
//         debugPrint('FCM token registered successfully');
//       } else {
//         debugPrint('Failed to register FCM token: ${response['data']['message']}');
//       }
//     } catch (e) {
//       debugPrint('FCM Token Registration Error: $e');
//     }
//   }
// }