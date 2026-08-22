// Service worker لاستقبال إشعارات FCM بالخلفية (التبويب غير مفتوح/غير مركّز).
// firebase_messaging (حزمة Flutter) تتوقّع هالملف بهالاسم بجذر الموقع بالضبط.

importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

// نفس قيم firebase_options.dart (web) — عامة/آمنة للعرض بكود العميل.
firebase.initializeApp({
  apiKey: 'AIzaSyATBCvqlnLLPPP4OiqqDOHWxnm0ZZOJrwo',
  authDomain: 'dt-teeth-64f9f.firebaseapp.com',
  projectId: 'dt-teeth-64f9f',
  storageBucket: 'dt-teeth-64f9f.firebasestorage.app',
  messagingSenderId: '1087443901608',
  appId: '1:1087443901608:web:b6b8ed2ea86252934ef69d',
});

firebase.messaging();
