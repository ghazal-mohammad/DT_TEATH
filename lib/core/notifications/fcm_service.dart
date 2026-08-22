// ════════════════════════════════════════════════════════════════════════════
// fcm_service.dart
//
// تسجيل جهاز المستخدم لاستقبال push حقيقي (Firebase Cloud Messaging) — ويب
// فقط حالياً (المخبر والمستودع Flutter Web، لا تطبيق موبايل). يُستدعى بعد
// نجاح تسجيل الدخول للمخبر/المستودع، ويُلغى عند تسجيل الخروج.
//
// خلفية push بالتبويب مغلق/غير مركّز: يتكفّل بيها web/firebase-messaging-sw.js
// تلقائياً (Firebase JS SDK) — بلا حاجة لكود Dart. onMessage هون بس للحالة
// التطبيق مفتوح بالمقدمة (الويب ما بيعرض إشعار نظام تلقائياً بهالحالة).
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../network/endpoints.dart';

class FcmService {
  FcmService(this._dio);

  final Dio _dio;
  String? _lastToken;

  /// يهيّئ Firebase، يطلب صلاحية الإشعارات من المتصفح، ويسجّل رمز الجهاز
  /// بالباك. بلا رمي أخطاء للخارج — فشل الـ push الحقيقي لا يجب أن يكسر
  /// تسجيل الدخول (الإشعارات داخل التطبيق تشتغل بغضّ النظر عنه).
  Future<void> initAndRegister() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token =
          await messaging.getToken(vapidKey: DefaultFirebaseOptions.vapidKey);
      if (token != null) await _sendToken(token);

      messaging.onTokenRefresh.listen(_sendToken);

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
            '[FCM] foreground message: ${message.notification?.title}');
      });
    } catch (e) {
      debugPrint('[FCM] init failed: $e');
    }
  }

  Future<void> _sendToken(String token) async {
    _lastToken = token;
    try {
      await _dio.post<dynamic>(ApiEndpoints.fcmToken, data: {
        'fcm_token': token,
        'device_type': 'web',
      });
    } catch (e) {
      debugPrint('[FCM] token registration failed: $e');
    }
  }

  /// يُستدعى عند تسجيل الخروج — يحذف رمز هالجهاز من الباك.
  Future<void> unregister() async {
    final token = _lastToken;
    if (token == null) return;
    try {
      await _dio.delete<dynamic>(
        ApiEndpoints.fcmToken,
        data: {'fcm_token': token},
      );
    } catch (e) {
      debugPrint('[FCM] token deletion failed: $e');
    }
    _lastToken = null;
  }
}
