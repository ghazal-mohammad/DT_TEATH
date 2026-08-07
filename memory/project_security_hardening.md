---
name: project-security-hardening
description: Frontend security hardening pass — screen protection, HTTPS enforcement, login lockout; what's done and what was deliberately skipped.
metadata:
  type: project
---

تصلّب أمني للواجهة (منجز 2026-08، عبر النظامين المخبري + المستودع من جذر التطبيق):

- **حماية الشاشة**: Android FLAG_SECURE دائم في `MainActivity.onCreate` (منع لقطات/تسجيل + إفراغ recents) + `PrivacyGuard` (Flutter، كل المنصّات) في `main.dart` يغطّي بستار براند عند خروج التطبيق من المقدّمة — يمنع تسرّب بيانات المرضى في لقطة مبدّل التطبيقات على iOS/سطح المكتب.
- **فرض HTTPS**: حارس في `DioClient.onRequest` يرفض أي طلب non-HTTPS خارج `Environment.development`.
- **قفل الدخول**: `LoginCubit` — بعد 5 محاولات فاشلة قفل تصاعدي 30s→300s، لا طلب للباك أثناء القفل.

**قرارات مقصودة (لا تُعكَس دون سبب):**
- **بلا حزمة طرف-ثالث** لحماية الشاشة (تجنّب `secure_application`/`flutter_windowmanager`) — الحلّ الأصيل (FLAG_SECURE) + PrivacyGuard خالص Flutter أنظف وأمتن ولا يكسر بناء أي منصّة من الستّ.
- **مسح الحافظة (clipboard auto-clear) متروك عمداً**: لا يوجد أي `Clipboard.setData` في التطبيق أصلاً، فلا شيء لمسحه.
- FLAG_SECURE لا يُختبر على web/سطح المكتب — يحتاج تحقّق على جهاز/بناء Android فعلي.

الأمان الحقيقي (تفويض/تحقّق/حدّ معدّل/تشفير) مسؤولية الباك — راجع [[feedback-backend-readonly]]. سبق أن أُنجز: توكن بـ secure_storage، Logger يحجب الحساس (dev)، معالجة 401، idle timeout، مسح كاش عند الخروج.
