# 📁 مجلد الترجمات المولّدة (Auto-Generated)

## ⚠️ تحذير

**الملفات في هذا المجلد تُولّد تلقائياً من Flutter — لا تعدّلها يدوياً.**

عند تشغيل:

```bash
flutter pub get
flutter gen-l10n
```

سيتم إنشاء الملفات التالية تلقائياً:

- `app_localizations.dart` — الـ class الأساسي `AppLocalizations`
- `app_localizations_ar.dart` — تنفيذ اللغة العربية
- `app_localizations_en.dart` — تنفيذ اللغة الإنجليزية

## كيف يعمل النظام؟

1. **المصدر**: ملفات `.arb` في `lib/core/l10n/arb/`
   - `app_en.arb` (template)
   - `app_ar.arb` (translation)

2. **التكوين**: `l10n.yaml` في جذر المشروع

3. **التوليد**: Flutter يقرأ ملفات `.arb` ويولّد كود Dart type-safe

4. **الاستخدام**:

   ```dart
   import 'package:dt_teeth/core/l10n/build_context_l10n.dart';

   Text(context.l10n.dashboard)
   Text(context.l10n.authVerifyCodeSubtitle('user@example.com'))
   ```

## متى تُشغَّل الأوامر؟

| السيناريو | الأمر المطلوب |
|-----------|---------------|
| أول تشغيل بعد clone | `flutter pub get` ثم `flutter gen-l10n` |
| إضافة نص جديد لـ `.arb` | `flutter gen-l10n` |
| تشغيل عادي للتطبيق | `flutter run` (التوليد تلقائي بفضل `generate: true`) |
| Build production | `flutter build web --release` |

## الهيكل المتوقّع بعد التوليد

```
generated/
├── README.md                        (هذا الملف)
├── app_localizations.dart           (مولّد)
├── app_localizations_ar.dart        (مولّد)
└── app_localizations_en.dart        (مولّد)
```

## المرجع الرسمي

https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
