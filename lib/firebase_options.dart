// ════════════════════════════════════════════════════════════════════════════
// firebase_options.dart
//
// إعدادات Firebase — يدوياً (بدون flutterfire CLI) لأن المطلوب حالياً منصّة
// الويب فقط (Flutter Web للمخبر والمستودع). القيم من Firebase Console →
// Project settings → مشروع "dt-teeth-64f9f" (2026-08-22).
//
// هاي القيم عامة/آمنة للعرض بكود العميل (client identifiers) — بعكس ملف
// service account (private_key) يلي يبقى على الباك حصراً ولا ينحط هون أبداً.
// ════════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    // التطبيق حالياً ويب فقط — أي منصّة تانية لسا غير مُعدّة.
    throw UnsupportedError(
      'DefaultFirebaseOptions لسا مُعدّة لمنصّة $defaultTargetPlatform — '
      'الويب فقط مدعوم حالياً.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyATBCvqlnLLPPP4OiqqDOHWxnm0ZZOJrwo',
    appId: '1:1087443901608:web:b6b8ed2ea86252934ef69d',
    messagingSenderId: '1087443901608',
    projectId: 'dt-teeth-64f9f',
    authDomain: 'dt-teeth-64f9f.firebaseapp.com',
    storageBucket: 'dt-teeth-64f9f.firebasestorage.app',
    measurementId: 'G-EPL8XQPT68',
  );

  /// مفتاح VAPID (Web Push certificate) — مطلوب لـ
  /// FirebaseMessaging.getToken(vapidKey: ...) على الويب حصراً.
  static const String vapidKey =
      'BMqCBuX7v88Ku1RFbpbun0TP1qVnpKl04vcmZDm0lBQHSn1MGsvsC9nMxkZwSwujfEiD-b-MSLBRJgT0x-6OUeA';
}
