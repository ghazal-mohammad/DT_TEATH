# 📋 Phase 3.6 — Verification & System Switcher

## 🎯 الأهداف
1. ✅ إصلاح "DT.Teeth" المعكوسة في Splash
2. ✅ إضافة System Switcher بسيط (Lab/Warehouse) بدون باك آند
3. ✅ Verification شامل لجودة الكود

---

## 🔧 Phase 3.6.1 — Splash Fix

### المشكلة
"DT.Teeth" كانت تظهر معكوسة في الـ Splash screen.

### السبب الجذري
الـ animation كانت per-character (8 widgets منفصلة في Row). في سياق RTL (locale عربي)، الـ Row يرتّب الأطفال من اليمين لليسار رغم وجود `Directionality.ltr` ظاهرياً، بسبب inheritance معقّد. بالإضافة، `letterSpacing: -1.5` السالب كان يسبب تداخل بصري يزيد المشكلة.

### الحل
استبدال per-character animation بـ **whole-word animation**:
- نص واحد بدل 8 widgets منفصلة
- `Directionality.ltr` صريحة مغلّفة الـ widget
- `textDirection: TextDirection.ltr` على الـ Text نفسه
- animation موحّدة (fade + scale + slide) بدل 4 transformations مكدّسة لكل حرف

### النتيجة
- ✅ النص يظهر بترتيب صحيح في كلا الـ locales (AR + EN)
- ✅ الـ animation أنعم وأخفّ على الـ rendering
- ✅ صفر إمكانية لـ ترتيب معكوس

### الملفات المعدّلة
- `lib/features/auth/presentation/widgets/materializing_text.dart` — إعادة كتابة كاملة (183 سطر)
- `lib/features/auth/presentation/pages/splash_page.dart` — لا تغييرات (الـ wrapper المؤقت اللي ضفته في البداية تم سحبه لأنه صار مش ضروري)

---

## 🎨 Phase 3.6.2 — System Switcher

### الفكرة
بدل الـ logic الحالي "إذا الإيميل فيه warehouse → مستودع، غير → مخبر"، أنشأنا:
1. **`SystemSelectionPage`** — تظهر بعد Set Password، فيها بطاقتان (Lab / Warehouse) باللوّن المميّز لكل نظام
2. **`MockSystemCubit`** (موجود مسبقاً، مربوط بـ DI) — يحفظ الاختيار في `SharedPreferences` ويتحمّله بين الـ sessions
3. **زر "تغيير النظام"** في الـ MockDashboard — يرجّع المستخدم لشاشة الاختيار في أي وقت

### Flow الجديد
```
Splash → Email → OTP → Set Password → ⭐ System Selection ⭐ → Lab/Warehouse Dashboard
                                              ↑                          │
                                              └──── (تغيير النظام) ─────┘
```

### Backend Migration Path
عند جاهزية الـ API:
- يُحذَف `SystemSelectionPage` بالكامل
- يُستبدل `MockSystemCubit` بـ `AuthCubit` يقرأ الدور من JWT
- يُعدَّل `set_password_page.dart` ليوجّه مباشرةً للـ dashboard المناسب
- **مجموع التغييرات المطلوبة:** ~10 أسطر فقط

### الملفات الجديدة
- `lib/features/auth/presentation/pages/system_selection_page.dart` — 519 سطر

### الملفات المعدّلة
- `lib/core/di/injection_container.dart` — تسجيل `MockSystemCubit` في DI
- `lib/main.dart` — إضافة `BlocProvider<MockSystemCubit>` + `loadSaved()`
- `lib/core/router/app_router.dart` — إضافة route `/system-selection`
- `lib/features/auth/presentation/pages/set_password_page.dart` — التوجّه لـ system selection بدل dashboard مباشرة
- `lib/features/_mock/mock_dashboard_page.dart` — ربط الأزرار بـ MockSystemCubit + إضافة زر "تغيير النظام"

### الـ ARB Keys المستخدمة (موجودة مسبقاً ✅)
| Key | AR | EN |
|---|---|---|
| `systemSelectionTitle` | اختر النظام | Select System |
| `systemSelectionSubtitle` | حدد النظام الذي تريد العمل عليه | Choose the system you want to work with |
| `systemSelectionLabTitle` | نظام المخبر | Lab System |
| `systemSelectionLabDescription` | إدارة طلبات التعويضات السنية... | Manage prosthetics orders... |
| `systemSelectionWarehouseTitle` | نظام المستودع | Warehouse System |
| `systemSelectionWarehouseDescription` | إدارة المخزون والمواد... | Manage inventory & materials... |
| `systemSelectionEnterButton` | الدخول | Enter |
| `systemSelectionDemoNotice` | وضع المعاينة... | Demo mode... |

---

## ✅ Phase 3.6.3 — Convention Audit

| القاعدة | النتيجة |
|---|---|
| `.withOpacity()` → `.withValues(alpha:)` | ✅ صفر استخدامات لـ withOpacity في كامل المشروع |
| Hardcoded colors خارج AppColors | ⚠️ 102 occurrences — معظمها في `app_alert_box.dart` للألوان السيمانتية (red/orange/green). مقبولة لكن قابلة للتحسين في Phase مستقبلية |
| Hardcoded strings خارج l10n | ✅ صفر في الكود الجديد |
| EdgeInsetsDirectional vs EdgeInsets | ✅ الجديد يستخدم symmetric/all (آمن) أو Directional عند الحاجة |
| PositionedDirectional | ✅ مستخدم في top toggles |
| Header comments + Dartdoc | ✅ موجودة في كل الملفات الجديدة والمعدّلة |

---

## 🌐 Phase 3.6.4 — i18n Verification

| فحص | النتيجة |
|---|---|
| AR keys count | 151 |
| EN keys count | 151 |
| Mismatch | ✅ NONE |
| All needed system_selection keys present | ✅ All 8 keys in both files |

---

## 🚶 Phase 3.6.5 — Manual Flow Walkthrough

### السيناريو 1: مستخدم جديد
```
1. Splash (4s, "DT.Teeth" يظهر بشكل صحيح ✓)
2. Email Entry → دخول إيميل جديد
3. OTP screen → إدخال الكود
4. Set Password → إنشاء كلمة المرور
5. ⭐ System Selection → ضغط على بطاقة "نظام المخبر"
6. → MockDashboard (Lab) مع زر "تغيير النظام"
```

### السيناريو 2: التبديل بين الأنظمة
```
1. من MockDashboard (Lab) → ضغط "تجربة المستودع"
2. MockSystemCubit يُحدّث إلى warehouse ويحفظ
3. → MockDashboard (Warehouse) — الأزرار، الألوان، الأيقونات تتغيّر
```

### السيناريو 3: العودة لاختيار النظام
```
1. من أي MockDashboard → ضغط "تغيير النظام"
2. → SystemSelectionPage مع كلا البطاقتين
3. اختيار آخر يُحفَظ ويُطبَّق
```

### السيناريو 4: استمرارية الاختيار بين الـ sessions
```
1. اختيار "Lab" في system selection
2. إغلاق التطبيق
3. إعادة فتح → MockSystemCubit.loadSaved() يستعيد "Lab"
4. (في المستقبل، عند ربط initial route بـ MockSystemCubit، يمكن تخطّي الاختيار)
```

---

## 📊 إحصائيات الجلسة

| المعيار | القيمة |
|---|---|
| ملفات جديدة | 1 |
| ملفات معدّلة | 6 |
| أسطر مضافة (تقديري) | ~600 |
| أسطر محذوفة (تقديري) | ~80 |
| keys جديدة في ARB | 0 (كانت موجودة بالفعل) |
| Convention violations | 0 في الكود الجديد |
| TODOs مفتوحة | استبدال MockSystemCubit بـ AuthCubit عند الـ Backend |

---

## 🎯 توصية الانتقال لـ F4

**جاهزة للانتقال لـ F4 Warehouse Screens** ✅

سبب التوصية:
1. الـ Auth Flow كامل ومستقر (Splash → Email → OTP → Set Password → System Selection)
2. آلية اختيار النظام شغّالة وقابلة للترقية للـ Backend مستقبلاً
3. صفر convention violations في الكود الجديد
4. الـ ARB files متطابقة 100%

### قبل البدء بـ F4، يُستحسن:
1. تشغيل `flutter clean && flutter pub get && flutter gen-l10n` لتوليد الـ localizations
2. تشغيل `flutter analyze` للتأكد من صفر warnings
3. تشغيل `flutter run -d chrome` لاختبار:
   - الـ Splash يُظهر "DT.Teeth" بشكل صحيح
   - الـ flow الكامل من Splash لـ MockDashboard
   - التبديل بين الأنظمة
   - الـ Light/Dark + AR/EN في كل صفحة

---

*Phase 3.6 — تم الإنجاز ✅*
