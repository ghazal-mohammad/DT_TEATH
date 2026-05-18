# 🦷 DT.Teeth — دليل القرارات التقنية وتنظيم المشروع
## Technical Decision Record & Project Organization Blueprint

---

## 📌 الملخص التنفيذي

هذه الوثيقة هي "خريطة الطريق" لمشروع DT.Teeth — نظام إدارة مركز طب الأسنان الشامل. تغطي نظامين فرعيين تحت مسؤوليتك: **المخبر (Lab)** و**المستودع (Warehouse)**. كل قرار تقني مبرّر بسبب واضح، مع ذكر البدائل ولماذا لم نخترها.

**الهدف:** مشروع Flutter Web واحد، Clean Architecture، جاهز للربط مع Laravel Backend، قابل لاختبار الحِمل (Load Testing) أمام الدكتور.

---

## الجزء الأول: قرارات البنية المعمارية (Architecture Decisions)

### القرار 1: مشروع واحد (Monorepo) وليس مشروعين

| | التفاصيل |
|---|---|
| **القرار** | مشروع Flutter واحد يحتوي نظامي المخبر والمستودع |
| **السبب** | مشاركة الكود المشترك (الألوان، الأبعاد، المكونات، Models). النظامان يتبادلان بيانات (المخبر يطلب مواد من المستودع). تعديل واحد بملف الثوابت ينعكس على النظامين فوراً |
| **البديل المرفوض** | مشروعين منفصلين — سيسبب تكرار كود (DRY violation)، وتضارب بالـ Models عند الربط مع الباك |
| **كيف نفصل بينهم؟** | بنظام Features: كل نظام = مجلد مستقل داخل `lib/features/`. التوجيه يتم حسب Role عند تسجيل الدخول |

### القرار 2: Clean Architecture (ليس MVC ولا MVVM تقليدي)

| | التفاصيل |
|---|---|
| **القرار** | استخدام Clean Architecture بثلاث طبقات: Presentation → Domain → Data |
| **السبب** | فصل كامل بين الـ UI والمنطق والبيانات. يمكنك بناء الواجهات الآن ببيانات وهمية (Mock)، وعند جاهزية الباك تغيّرين فقط الـ DataSource دون لمس الـ UI أو الـ Business Logic |
| **البديل المرفوض** | MVC — لا يوفر عزل كافٍ بين الطبقات. MVVM وحده — جيد لكن بدون Domain Layer يصبح الكود مرتبطاً بالـ Data مباشرة |
| **المرجع** | نفس النمط المستخدم بمشروع Educational على GitHub الخاص بك |

### القرار 3: BLoC (وليس Riverpod أو Provider أو GetX)

| | التفاصيل |
|---|---|
| **القرار** | `flutter_bloc` لإدارة الحالة |
| **السبب** | (1) نمط واضح ومنظم — كل حالة لها State و Event منفصلين. (2) قابل للاختبار بسهولة عالية (مهم للعرض أمام الدكتور). (3) متوافق مع Clean Architecture. (4) الأكثر استخداماً في المشاريع الأكاديمية والمهنية — تقدري تدافعي عنه بسهولة |
| **البديل المرفوض** | **Riverpod:** ممتاز لكن تعقيده أعلى ومنحنى التعلم أصعب لمشروع فريق. **GetX:** سهل لكنه "anti-pattern" — يخلط المسؤوليات ولا يُقبل أكاديمياً. **Provider:** بسيط جداً ولا يكفي لنظام بهذا الحجم |

### القرار 4: GoRouter (وليس Navigator 2.0 أو auto_route)

| | التفاصيل |
|---|---|
| **القرار** | `go_router` للتنقل بين الشاشات |
| **السبب** | (1) يدعم Deep Linking — ضروري لـ Flutter Web (رابط مباشر لكل صفحة). (2) يدعم Guards — حماية الصفحات حسب الصلاحيات (مخبر ≠ مستودع). (3) موصى به رسمياً من Flutter Team |
| **البديل المرفوض** | **Navigator 2.0 يدوي:** معقد جداً وكثير الكود. **auto_route:** ممتاز لكن يعتمد على Code Generation ويضيف طبقة تعقيد غير ضرورية |

### القرار 5: Freezed + json_serializable (وليس كتابة Models يدوياً)

| | التفاصيل |
|---|---|
| **القرار** | مكتبة `freezed` مع `json_serializable` لنماذج البيانات |
| **السبب** | (1) تولّد `fromJson` و `toJson` تلقائياً — عند وصول الباك تكون Models جاهزة. (2) Immutable by default — تمنع أخطاء تعديل البيانات بالغلط. (3) تدعم Default Values — التطبيق لا يتوقف عند بيانات ناقصة من الباك. (4) تدعم `copyWith` — سهولة تحديث الحالة بـ BLoC |
| **البديل المرفوض** | **كتابة يدوية:** عرضة للأخطاء وتستهلك وقتاً هائلاً مع 6 أنظمة. **built_value:** أقدم وأكثر تعقيداً من Freezed |

### القرار 6: Dio (وليس http أو Retrofit مباشرة)

| | التفاصيل |
|---|---|
| **القرار** | مكتبة `dio` للتواصل مع الـ API |
| **السبب** | (1) تدعم Interceptors — لإضافة Token تلقائياً لكل طلب. (2) تدعم إلغاء الطلبات (Cancel Token) — مهم للبحث اللحظي. (3) تدعم Upload/Download مع Progress. (4) سهلة الربط مع Either<Failure, Success> |
| **البديل المرفوض** | **http package:** بسيط جداً ولا يدعم Interceptors. **Retrofit:** يضيف طبقة Code Generation فوق Dio — ممكن نستخدمه لاحقاً لكن الآن Dio كافي |

### القرار 7: dartz (Either Pattern)

| | التفاصيل |
|---|---|
| **القرار** | مكتبة `dartz` لاستخدام نمط `Either<Failure, Entity>` في الـ Repositories |
| **السبب** | (1) كل Repository يرجع إما نجاح أو فشل — لا Exceptions غير متوقعة. (2) تقدري تشتغلي على الـ UI ببيانات Mock وتتأكدي إنو كل حالة (نجاح/فشل/تحميل) معالجة. (3) عند الربط مع الباك، فقط تغيّري الـ DataSource |
| **البديل المرفوض** | **Try-Catch عادي:** لا يجبرك على معالجة الخطأ — سهل تنسي حالة. **Result class يدوي:** ممكن لكن dartz مُختبرة ومعروفة |

### القرار 8: GetIt (Dependency Injection)

| | التفاصيل |
|---|---|
| **القرار** | `get_it` + `injectable` لحقن التبعيات |
| **السبب** | (1) فصل إنشاء الكائنات عن استخدامها — كود أنظف. (2) سهولة تبديل الـ DataSource (Mock ↔ Real API). (3) نفس النمط المستخدم بمشروعك Educational |
| **البديل المرفوض** | **حقن يدوي:** فوضوي مع 6 أنظمة. **Riverpod providers:** مرتبط بـ Riverpod وما اخترناه |

---

## الجزء الثاني: قرارات الـ Design System (الهوية البصرية)

### القرار 9: ملفات ثوابت مركزية (وليس أرقام يدوية)

| | التفاصيل |
|---|---|
| **القرار** | 4 ملفات أساسية للهوية البصرية: Colors, Sizes, Icons, Theme |
| **السبب** | بتتحاسبي على البكسل — أي تغيير لازم يكون من مكان واحد. لو طلب الدكتور تعديل لون أو حجم زر، تعدليه بملف واحد وينعكس على كل الشاشات |

**الملفات:**
- `lib/core/theme/app_colors.dart` — كل الألوان مسمّاة (Primary, Secondary, Surface...)
- `lib/core/theme/app_sizes.dart` — الأبعاد الثابتة (Padding, BorderRadius, ButtonHeight...)
- `lib/core/theme/app_icons.dart` — أيقونات موحدة (كل أيقونة بإسم واضح)
- `lib/core/theme/app_theme.dart` — ThemeData الكامل لـ Flutter (Dark + Light)

### القرار 10: Iconsax (وليس Material Icons أو FontAwesome)

| | التفاصيل |
|---|---|
| **القرار** | مكتبة `iconsax_flutter` للأيقونات |
| **السبب** | (1) تصميم حديث يناسب Dashboard. (2) أيقونات موحدة بأسلوب واحد. (3) خفيفة الوزن |
| **البديل المرفوض** | **Material Icons:** كلاسيكية وليست حديثة. **FontAwesome:** ثقيلة والنسخة المجانية محدودة. **Phosphor:** ممتازة لكن Iconsax أنسب للـ Dashboards |

### القرار 11: flutter_screenutil (وليس MediaQuery يدوي)

| | التفاصيل |
|---|---|
| **القرار** | `flutter_screenutil` للتجاوب مع أحجام الشاشات المختلفة |
| **السبب** | (1) تحدد أبعاد التصميم مرة واحدة (مثلاً 1440px عرض) وكل شي يتكيف تلقائياً. (2) ضروري لـ Flutter Web — الشاشات مختلفة جداً |
| **البديل المرفوض** | **MediaQuery يدوي:** كثير كود متكرر. **responsive_framework:** جيد لكن ScreenUtil أبسط وأدق للبكسل |

---

## الجزء الثالث: هيكل المجلدات الكامل (Folder Structure)

```
dt_teeth_app/
├── lib/
│   ├── main.dart                              # نقطة البداية
│   │
│   ├── core/                                  # 🌐 الأساسيات المشتركة
│   │   ├── theme/
│   │   │   ├── app_colors.dart                # الألوان المستخرجة من HTML
│   │   │   ├── app_sizes.dart                 # الأبعاد (Padding, Radius, Heights)
│   │   │   ├── app_icons.dart                 # الأيقونات الموحدة
│   │   │   ├── app_text_styles.dart           # أنماط النصوص
│   │   │   └── app_theme.dart                 # ThemeData (Dark + Light)
│   │   │
│   │   ├── constants/
│   │   │   ├── app_urls.dart                  # عناوين الـ API (فارغة — تُملأ عند الباك)
│   │   │   ├── app_assets.dart                # مسارات الصور والملفات
│   │   │   └── app_strings.dart               # نصوص ثابتة (رسائل خطأ، عناوين)
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart                # إعداد Dio + Interceptors
│   │   │   ├── api_result.dart                # Either<Failure, T> wrapper
│   │   │   ├── failure.dart                   # أنواع الأخطاء (Server, Network, Cache)
│   │   │   └── endpoints.dart                 # API endpoints (فارغ — جاهز للباك)
│   │   │
│   │   ├── di/
│   │   │   └── injection_container.dart       # GetIt setup
│   │   │
│   │   ├── router/
│   │   │   ├── app_router.dart                # GoRouter configuration
│   │   │   ├── route_names.dart               # أسماء الصفحات كـ constants
│   │   │   └── route_guards.dart              # حماية حسب الصلاحيات
│   │   │
│   │   └── shared_widgets/                    # مكونات مشتركة بين النظامين
│   │       ├── custom_button.dart
│   │       ├── custom_text_field.dart
│   │       ├── custom_card.dart
│   │       ├── data_table_widget.dart
│   │       ├── sidebar_widget.dart
│   │       ├── topbar_widget.dart
│   │       ├── loading_widget.dart
│   │       ├── error_widget.dart
│   │       └── empty_state_widget.dart
│   │
│   ├── features/                              # 🏗️ الميزات (كل نظام = feature)
│   │   │
│   │   ├── auth/                              # 🔐 المصادقة (مشتركة)
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_data_source.dart   # (فارغ — جاهز للباك)
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.freezed.dart        # Freezed model
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart      # (Mock data حالياً)
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart           # Abstract interface
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       └── first_login_usecase.dart
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       ├── screens/
│   │   │       │   └── login_screen.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── system_selector.dart
│   │   │
│   │   ├── lab/                               # 🧪 نظام المخبر
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   │   ├── lab_order_model.freezed.dart
│   │   │   │   │   ├── technician_model.freezed.dart
│   │   │   │   │   └── lab_report_model.freezed.dart
│   │   │   │   └── repositories/
│   │   │   │
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── lab_orders/             # BLoC خاص بطلبات الأطباء
│   │   │       │   ├── lab_technicians/        # BLoC خاص بالفنيين
│   │   │       │   └── lab_reports/            # BLoC خاص بالتقارير
│   │   │       ├── screens/
│   │   │       │   ├── lab_dashboard_screen.dart
│   │   │       │   ├── lab_orders_screen.dart
│   │   │       │   ├── lab_technicians_screen.dart
│   │   │       │   ├── lab_reports_screen.dart
│   │   │       │   ├── lab_notifications_screen.dart
│   │   │       │   └── lab_settings_screen.dart
│   │   │       └── widgets/
│   │   │           ├── order_card.dart
│   │   │           ├── order_detail_dialog.dart
│   │   │           ├── technician_card.dart
│   │   │           └── lab_stats_card.dart
│   │   │
│   │   └── warehouse/                         # 📦 نظام المستودع
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   ├── models/
│   │       │   │   ├── material_model.freezed.dart
│   │       │   │   ├── warehouse_order_model.freezed.dart
│   │       │   │   ├── invoice_model.freezed.dart
│   │       │   │   └── supplier_model.freezed.dart
│   │       │   └── repositories/
│   │       │
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   ├── repositories/
│   │       │   └── usecases/
│   │       │
│   │       └── presentation/
│   │           ├── bloc/
│   │           │   ├── inventory/              # BLoC خاص بالمخزون
│   │           │   ├── warehouse_orders/       # BLoC خاص بالطلبيات
│   │           │   ├── invoices/               # BLoC خاص بالفواتير
│   │           │   └── warehouse_reports/      # BLoC خاص بالتقارير
│   │           ├── screens/
│   │           │   ├── warehouse_dashboard_screen.dart
│   │           │   ├── materials_screen.dart
│   │           │   ├── warehouse_orders_screen.dart
│   │           │   ├── invoices_screen.dart
│   │           │   ├── warehouse_reports_screen.dart
│   │           │   ├── warehouse_notifications_screen.dart
│   │           │   └── warehouse_settings_screen.dart
│   │           └── widgets/
│   │               ├── material_card.dart
│   │               ├── material_detail_dialog.dart
│   │               ├── low_stock_alert.dart
│   │               ├── expiry_alert.dart
│   │               └── invoice_card.dart
│   │
│   └── shared/                                # 🔗 بيانات مشتركة بين الأنظمة
│       ├── models/
│       │   └── notification_model.freezed.dart
│       └── bloc/
│           └── notification_bloc/
│
├── test/                                      # 🧪 الاختبارات
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## الجزء الرابع: قائمة المكتبات الكاملة (مع التبرير)

### مكتبات أساسية (Core)

| المكتبة | الغرض | لماذا هي؟ | البديل المرفوض |
|---------|--------|-----------|----------------|
| `flutter_bloc` | إدارة الحالة | منظمة، قابلة للاختبار، أكاديمياً مقبولة | GetX (anti-pattern), Provider (بسيط جداً) |
| `go_router` | التنقل | Deep Linking لـ Web، Guards للصلاحيات | Navigator 2.0 (معقد), auto_route (code gen زائد) |
| `freezed` + `json_serializable` | نماذج البيانات | Immutable, fromJson/toJson تلقائي | كتابة يدوية (أخطاء كثيرة) |
| `dio` | HTTP Client | Interceptors, Cancel tokens | http (بسيط جداً) |
| `dartz` | Functional Error Handling | Either pattern للـ Repositories | try-catch (ناقص) |
| `get_it` + `injectable` | Dependency Injection | فصل الإنشاء عن الاستخدام | حقن يدوي (فوضوي) |

### مكتبات الـ UI

| المكتبة | الغرض | لماذا هي؟ | البديل المرفوض |
|---------|--------|-----------|----------------|
| `flutter_screenutil` | تجاوب الشاشات | بكسل دقيق على كل الأحجام | MediaQuery يدوي |
| `iconsax_flutter` | أيقونات | حديثة، موحدة، مناسبة للـ Dashboard | Material Icons (كلاسيكية) |
| `fl_chart` | رسوم بيانية | خفيفة، تفاعلية، مفتوحة المصدر | syncfusion (مدفوعة), charts_flutter (محدودة) |
| `shimmer` | Loading Animation | تجربة مستخدم احترافية أثناء التحميل | CircularProgressIndicator (بدائي) |
| `intl` | تنسيق التواريخ/الأرقام | ضروري للغة العربية وـ RTL | — |
| `flutter_svg` | عرض أيقونات SVG | أخف وأدق من PNG | — |

### مكتبات البنية التحتية (Infrastructure)

| المكتبة | الغرض | لماذا هي؟ | البديل المرفوض |
|---------|--------|-----------|----------------|
| `firebase_core` + `firebase_messaging` | إشعارات | جاهز — نربط لاحقاً مع الباك | OneSignal (أقل تكامل مع Flutter) |
| `flutter_secure_storage` | حفظ Token | مشفّر وآمن | SharedPreferences (غير مشفّر) |
| `equatable` | مقارنة الكائنات | ضروري لـ BLoC States | — |
| `build_runner` | Code Generation | يشغّل Freezed و Injectable | — |

---

## الجزء الخامس: استراتيجية Git (الريبو والبرانشات)

### إعداد الريبو المزدوج (رفع على حسابين)

```bash
# بعد إنشاء المشروع
git init
git remote add origin https://github.com/ShamAboShash/Comprehensive_Dental_Clinics_Management_system.git
git remote set-url --add --push origin https://github.com/ShamAboShash/Comprehensive_Dental_Clinics_Management_system.git
git remote set-url --add --push origin https://github.com/ghazal-mohammad/dt_teeth_app.git

# هيك كل git push يرفع على الريبوزين سوا
```

### استراتيجية البرانشات (Git Flow مبسّط)

```
main (master)          ← الكود الجاهز والمُختبر فقط
  └── develop          ← كل الشغل الجديد يندمج هنا أولاً
       ├── feature/auth          ← ميزة المصادقة
       ├── feature/lab-ui        ← واجهات المخبر
       ├── feature/warehouse-ui  ← واجهات المستودع
       ├── feature/lab-bloc      ← منطق المخبر
       └── feature/warehouse-bloc ← منطق المستودع
```

**القاعدة:** لا ترفعي مباشرة على `main`. كل ميزة = برانش. تنتهي = Pull Request على `develop`. تتأكدي إنو كلشي شغال = Merge على `main`.

### ترتيب الـ Commits

```
feat: add login screen UI
feat: add lab dashboard screen
fix: correct sidebar navigation
refactor: extract shared button widget
docs: add architecture guide
```

---

## الجزء السادس: ترتيب العمل (أولويات التنفيذ)

### المرحلة 0: الأساس (يوم 1-2)
- [ ] إنشاء مشروع Flutter Web
- [ ] إعداد `pubspec.yaml` بكل المكتبات
- [ ] تشغيل `flutter pub get` و `build_runner`
- [ ] إعداد Git + الريبو المزدوج
- [ ] إنشاء هيكل المجلدات الكامل (فارغ)

### المرحلة 1: الـ Core (يوم 3-5)
- [ ] ملف الألوان `app_colors.dart` (من ملف HTML)
- [ ] ملف الأبعاد `app_sizes.dart`
- [ ] ملف الأيقونات `app_icons.dart`
- [ ] ملف الـ Theme `app_theme.dart` (Dark + Light)
- [ ] إعداد Dio Client (فارغ — جاهز للباك)
- [ ] إعداد GetIt (injection container)
- [ ] إعداد GoRouter (الهيكل الأساسي)

### المرحلة 2: الـ Shared Widgets (يوم 6-8)
- [ ] CustomButton, CustomTextField, CustomCard
- [ ] Sidebar (مشترك — يتغير حسب النظام)
- [ ] Topbar (بحث، إشعارات، ملف شخصي)
- [ ] DataTable Widget (للجداول المشتركة)
- [ ] Loading, Error, Empty State widgets

### المرحلة 3: Auth (يوم 9-11)
- [ ] شاشة تسجيل الدخول (بكسل من HTML)
- [ ] Auth BLoC + States
- [ ] Freezed Model للمستخدم
- [ ] Mock Repository (بيانات وهمية)
- [ ] التوجيه حسب الـ Role (مخبر/مستودع)

### المرحلة 4: واجهات المخبر (يوم 12-18)
- [ ] Dashboard المخبر (إحصائيات + رسوم بيانية)
- [ ] شاشة طلبات الأطباء (قائمة + تفاصيل)
- [ ] شاشة الفنيين
- [ ] شاشة التقارير
- [ ] شاشة الإشعارات + الإعدادات

### المرحلة 5: واجهات المستودع (يوم 19-25)
- [ ] Dashboard المستودع (مخزون + تنبيهات)
- [ ] شاشة المواد (إضافة + تعديل + بحث)
- [ ] شاشة الطلبيات الواردة
- [ ] شاشة الفواتير
- [ ] شاشة التقارير + المواد الأكثر طلباً

### المرحلة 6: التكامل (يوم 26-30)
- [ ] ربط النظامين (طلب مواد من المخبر → المستودع)
- [ ] الإشعارات المشتركة
- [ ] اختبار التنقل الكامل
- [ ] Mock Data لكل السيناريوهات

### المرحلة 7: التحضير للباك آند (لاحقاً)
- [ ] استبدال Mock DataSource بـ Remote DataSource
- [ ] ربط Firebase Messaging
- [ ] ربط Auth مع Laravel API
- [ ] اختبار الحِمل (Load Testing)

---

## الجزء السابع: الألوان المستخرجة من ملفات HTML

```dart
// المستخرجة من DT_Teeth_Lab_v11.html و DT_Teeth_Warehouse_v5.html

class AppColors {
  // الألوان الأساسية
  static const Color primary = Color(0xFF1A1C4E);       // الأزرق الداكن الأساسي
  static const Color secondary = Color(0xFFED8BFA);      // الوردي
  static const Color accent = Color(0xFF9EFBEC);         // السماوي/Mint — اللون المميز

  // ألوان الحالة
  static const Color success = Color(0xFF0DBD7F);        // أخضر — نجاح
  static const Color warning = Color(0xFFFADE1F);        // أصفر — تحذير
  static const Color error = Color(0xFFEF4444);          // أحمر — خطأ
  static const Color info = Color(0xFF7DD3FC);           // أزرق فاتح — معلومات

  // ألوان الخلفية
  static const Color background = Color(0xFF1A1C4E);     // خلفية داكنة
  static const Color backgroundLight = Color(0xFF0F1035); // خلفية أغمق
  static Color surface = Colors.white.withOpacity(0.06);  // سطح البطاقات

  // ألوان النصوص
  static const Color textPrimary = Color(0xFFFFFFFF);     // نص أبيض
  static const Color textSecondary = Color(0xB3FFFFFF);   // نص أبيض 70%
  static const Color textTertiary = Color(0x80FFFFFF);    // نص أبيض 50%
  static const Color textMuted = Color(0x4DFFFFFF);       // نص أبيض 30%

  // ألوان الحدود
  static Color borderDefault = const Color(0xFF9EFBEC).withOpacity(0.12);
  static Color borderHover = const Color(0xFF9EFBEC).withOpacity(0.30);

  // ألوان الأنظمة المختلفة
  static const Color labSystem = Color(0xFFED8BFA);       // المخبر = وردي
  static const Color warehouseSystem = Color(0xFF9EFBEC); // المستودع = سماوي
}
```

---

## الجزء الثامن: الأبعاد المستخرجة من HTML

```dart
class AppSizes {
  // التدويرات (Border Radius)
  static const double radiusXS = 6.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 50.0;     // للعناصر الدائرية

  // المسافات (Padding/Margin)
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;

  // أحجام العناصر
  static const double buttonHeight = 48.0;
  static const double inputHeight = 44.0;
  static const double sidebarWidth = 240.0;
  static const double sidebarCollapsed = 70.0;
  static const double topbarHeight = 54.0;
  static const double cardMinHeight = 80.0;
  static const double iconButtonSize = 32.0;
  static const double avatarSize = 30.0;

  // أحجام النصوص
  static const double fontXS = 9.0;
  static const double fontSM = 11.0;
  static const double fontMD = 14.0;
  static const double fontLG = 18.0;
  static const double fontXL = 21.0;
  static const double fontDisplay = 32.0;
}
```

---

## الجزء التاسع: ملاحظات مهمة للعرض أمام الدكتور

### لماذا Flutter Web (وليس React أو Angular)؟
- Codebase واحد لـ Web + Mobile (المرضى لاحقاً على موبايل).
- أداء عالي مع WebAssembly (Flutter 3.x+).
- نفس لغة الـ Dart للفريق بأكمله.

### لماذا Laravel للباك (وليس Node.js أو Spring)؟
- قرار الفريق/المشرف (ثابت).
- Laravel يوفر RESTful API + Sanctum للمصادقة + Swagger للتوثيق.
- التواصل: Flutter (Dio) ↔ Laravel (API) عبر JSON.

### كيف نضمن الأداء تحت 1000 مستخدم متزامن؟
- **Flutter جانب:** Lazy Loading للشاشات، Pagination للجداول، Image Caching.
- **Laravel جانب:** Database Indexing, Query Caching, Queue for notifications.
- **الاختبار:** أداة k6 أو Apache JMeter لـ Load Testing.

### كيف نضمن RTL والعربية؟
- `intl` package + `flutter_localizations`.
- `Directionality(textDirection: TextDirection.rtl)` على مستوى التطبيق.
- كل النصوص من ملف مركزي (جاهز للترجمة لاحقاً).

---

---

## الجزء العاشر: الخطوط (Typography) — القرار 12

### الخطوط المستخدمة بالمشروع (من ملفات HTML الأصلية)

| | التفاصيل |
|---|---|
| **القرار** | خط **Cairo** كخط أساسي + **Tajawal** كخط احتياطي |
| **السبب** | (1) Cairo مصمم للعربية واللاتينية معاً — خط واحد يكفي للغتين. (2) يدعم 7 أوزان (300-900) — مرونة كاملة. (3) مقروء جداً على الشاشات. (4) مجاني من Google Fonts |
| **البديل المرفوض** | **Noto Sans Arabic:** ممتاز لكن Cairo أجمل للـ Dashboards. **Almarai:** جيد لكن أوزانه أقل (4 فقط) |

### كيف نستخدمهم بـ Flutter

```dart
// في pubspec.yaml
fonts:
  - family: Cairo
    fonts:
      - asset: assets/fonts/Cairo-Light.ttf
        weight: 300
      - asset: assets/fonts/Cairo-Regular.ttf
        weight: 400
      - asset: assets/fonts/Cairo-Medium.ttf
        weight: 500
      - asset: assets/fonts/Cairo-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Cairo-Bold.ttf
        weight: 700
      - asset: assets/fonts/Cairo-ExtraBold.ttf
        weight: 800
      - asset: assets/fonts/Cairo-Black.ttf
        weight: 900

// في app_theme.dart
ThemeData(
  fontFamily: 'Cairo',
  // ...
)
```

### خط اسم المركز "DT.Teeth"

| | التفاصيل |
|---|---|
| **القرار** | نفس خط Cairo بوزن **900 (Black)** + تأثير Gradient |
| **السبب** | في ملف HTML الأصلي، اسم المركز يظهر بـ `font-weight: 900` مع `font-size: 32px`. لا حاجة لخط مختلف — الوزن الثقيل وحده يعطي الطابع المميز |
| **التطبيق** | `Text('DT.Teeth', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 32))` مع ShaderMask للـ Gradient |

### جدول أنماط النصوص (Text Styles)

```dart
class AppTextStyles {
  // العناوين
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Cairo', fontSize: 32, fontWeight: FontWeight.w900, // اسم المركز
  );
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Cairo', fontSize: 21, fontWeight: FontWeight.w800, // عناوين الصفحات
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, // عناوين الأقسام
  );
  
  // المحتوى
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, // نص أساسي
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, // Labels
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Cairo', fontSize: 9, fontWeight: FontWeight.w400,  // تفاصيل صغيرة
  );
  
  // خاص
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5,
  );
  static const TextStyle badge = TextStyle(
    fontFamily: 'Cairo', fontSize: 9.5, fontWeight: FontWeight.w700,
  );
}
```

---

## الجزء الحادي عشر: الصور واللوغو والأصول (Assets Strategy)

### هيكل مجلد الأصول

```
assets/
├── images/
│   ├── logo/
│   │   ├── dt_teeth_logo.svg           # اللوغو الأساسي (SVG للوضوح على كل الأحجام)
│   │   ├── dt_teeth_logo_white.svg     # اللوغو أبيض (للخلفية الداكنة)
│   │   ├── dt_teeth_logo_dark.svg      # اللوغو داكن (للخلفية الفاتحة)
│   │   └── dt_teeth_icon_only.svg      # الأيقونة فقط (بدون نص — للـ Favicon والأماكن الصغيرة)
│   │
│   ├── onboarding/                     # صور شاشة الدخول (لو حبيتي تضيفي)
│   ├── empty_states/                   # صور الحالات الفارغة (لا طلبات، لا مواد...)
│   │   ├── no_orders.svg
│   │   ├── no_materials.svg
│   │   └── no_notifications.svg
│   └── illustrations/                  # رسومات توضيحية (اختياري)
│
├── icons/                              # أيقونات مخصصة (لو ما لقيتي بـ Iconsax)
│
├── fonts/                              # ملفات الخطوط
│   ├── Cairo-Light.ttf
│   ├── Cairo-Regular.ttf
│   ├── Cairo-Medium.ttf
│   ├── Cairo-SemiBold.ttf
│   ├── Cairo-Bold.ttf
│   ├── Cairo-ExtraBold.ttf
│   └── Cairo-Black.ttf
│
└── animations/                         # Lottie animations (اختياري — للـ Loading مثلاً)
```

### ملف إدارة الأصول (app_assets.dart)

```dart
class AppAssets {
  // اللوغو
  static const String logo = 'assets/images/logo/dt_teeth_logo.svg';
  static const String logoWhite = 'assets/images/logo/dt_teeth_logo_white.svg';
  static const String logoDark = 'assets/images/logo/dt_teeth_logo_dark.svg';
  static const String logoIcon = 'assets/images/logo/dt_teeth_icon_only.svg';
  
  // الحالات الفارغة
  static const String noOrders = 'assets/images/empty_states/no_orders.svg';
  static const String noMaterials = 'assets/images/empty_states/no_materials.svg';
  static const String noNotifications = 'assets/images/empty_states/no_notifications.svg';
}
```

### ملاحظة عن اللوغو

اللوغو الحالي بملفات HTML هو صورة PNG مشفرة بـ base64 (سن مع خطوط). لازم تعمليلو:
1. **تصدير SVG نظيف** — أفضل من PNG لأنو Vector ما بيتبكسل على أي حجم
2. **تحضير 3 نسخ:** أبيض (Dark mode)، داكن (Light mode)، أيقونة فقط
3. **لو ما عندك SVG:** يمكنك استخدام الـ PNG الموجود مؤقتاً وتحوليه لاحقاً

---

## الجزء الثاني عشر: Firebase — القرار 13

| | التفاصيل |
|---|---|
| **القرار** | إنشاء مشروع Firebase **لاحقاً** عند مرحلة الربط مع الباك |
| **السبب** | Firebase في مشروعنا = **فقط Notifications** (FCM). ما بنستخدم Firestore أو Firebase Auth لأنو الباك Laravel. إنشاء المشروع هلق = إعداد بدون فائدة فعلية |

### شو بنستخدم من Firebase (ومالنا)

| الخدمة | نستخدمها؟ | السبب |
|--------|-----------|-------|
| **Firebase Cloud Messaging (FCM)** | ✅ نعم | إشعارات Push — Laravel يرسل عبر FCM |
| Firebase Authentication | ❌ لا | الباك Laravel يتكفل بالمصادقة (Sanctum) |
| Cloud Firestore | ❌ لا | قاعدة البيانات على Laravel (MySQL/PostgreSQL) |
| Firebase Storage | ❌ لا | الملفات تُخزن على سيرفر Laravel |
| Firebase Analytics | ⚠️ اختياري | ممكن لاحقاً لتتبع الاستخدام |
| Firebase Crashlytics | ⚠️ اختياري | ممكن لاحقاً لتتبع الأخطاء |

### الخطوات عند الإعداد (لاحقاً)

```
1. ادخلي على https://console.firebase.google.com
2. أنشئي مشروع باسم "dt-teeth-app"
3. أضيفي تطبيق Web (Flutter Web)
4. انسخي firebase_options.dart للمشروع
5. أعطي الـ Server Key لفريق الباك (Laravel يحتاجه لإرسال الإشعارات)
```

### شو نعمل هلق (Placeholder)

```dart
// lib/core/services/notification_service.dart
class NotificationService {
  // TODO: ربط Firebase Messaging عند جاهزية الباك
  
  Future<void> initialize() async {
    // سيتم إعداد FCM هنا
  }
  
  Future<void> requestPermission() async {
    // طلب صلاحية الإشعارات
  }
  
  void onMessageReceived(dynamic message) {
    // معالجة الإشعار الوارد
  }
}
```

---

## الجزء الثالث عشر: اللغة الإنكليزية (Localization) — القرار 14

| | التفاصيل |
|---|---|
| **القرار** | المشروع بالعربية فقط حالياً، مع بنية جاهزة للإنكليزية لاحقاً |
| **السبب** | (1) الـ SRS لم يذكر متطلب للإنكليزية. (2) المستخدمون عرب. (3) إضافة لغة ثانية الآن = ضعف وقت التطوير. (4) البنية الجاهزة تسمح بإضافتها بساعات لاحقاً |

### كيف نجهز البنية (بدون تنفيذ الترجمة)

```dart
// lib/core/constants/app_strings.dart
// كل النصوص الثابتة هنا — لو طُلبت الترجمة، نحولهم لملفات ARB

class AppStrings {
  // Auth
  static const String login = 'تسجيل الدخول';
  static const String email = 'البريد / رقم الموظف';
  static const String password = 'كلمة المرور';
  static const String firstLogin = 'أول مرة';
  
  // Lab
  static const String labSystem = 'نظام المخبر';
  static const String doctorOrders = 'طلبات الأطباء';
  static const String technicians = 'الفنيون';
  
  // Warehouse
  static const String warehouseSystem = 'نظام المستودع';
  static const String materials = 'المواد';
  static const String orders = 'الطلبيات';
  static const String invoices = 'الفواتير';
  
  // Shared
  static const String dashboard = 'لوحة التحكم';
  static const String reports = 'التقارير';
  static const String notifications = 'الإشعارات';
  static const String settings = 'الإعدادات';
  static const String search = 'بحث...';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String noData = 'لا توجد بيانات';
  static const String error = 'حدث خطأ';
  static const String retry = 'إعادة المحاولة';
}
```

### لو الدكتور طلب إنكليزي (الخطة B)

1. نحول `app_strings.dart` إلى ملفات `.arb` (JSON-like)
2. نستخدم `flutter_localizations` + `intl`
3. نضيف Language Switcher بالإعدادات
4. **الوقت المتوقع:** يوم واحد (لأنو كل النصوص بمكان واحد أصلاً)

---

## الجزء الرابع عشر: أشياء ناقصة لازم تكون بالمشروع

### 1. نظام الثيم (Dark/Light Mode) — القرار 15

ملفات HTML عندك فيها **Dark Mode و Light Mode** جاهزين! لازم ندعمهم:

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.background,
    // ... باقي الإعدادات
  );
  
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.backgroundLight,
    // ... ألوان Light Mode من ملف HTML
  );
}

// BLoC للتبديل بين الثيمات
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> { ... }
```

### 2. Error Handling شامل (ضروري للعرض أمام الدكتور)

```
lib/core/error/
├── exceptions.dart          # ServerException, CacheException, NetworkException
├── failures.dart            # ServerFailure, CacheFailure, NetworkFailure  
└── error_handler.dart       # يحول Exception → Failure + رسالة عربية واضحة
```

### 3. نظام الـ Mock Data (مهم جداً قبل الباك)

```
lib/core/mock/
├── mock_lab_data.dart       # بيانات وهمية للمخبر (طلبات، فنيين، تقارير)
├── mock_warehouse_data.dart # بيانات وهمية للمستودع (مواد، فواتير، طلبيات)
└── mock_auth_data.dart      # مستخدمين وهميين (مدير مخبر، أمين مستودع)
```

### 4. Loading States لكل شاشة (UX احترافي)

كل BLoC State لازم يغطي 4 حالات:
- `Initial` — قبل أي طلب
- `Loading` — جاري التحميل (Shimmer effect)
- `Success` — البيانات وصلت
- `Error` — خطأ مع رسالة واضحة + زر إعادة

### 5. Responsive Layout (مهم لـ Flutter Web)

```
lib/core/layout/
├── responsive_layout.dart    # يقرر: Desktop أو Tablet أو Mobile
├── desktop_layout.dart       # Sidebar + Content (مثل HTML الحالي)
├── tablet_layout.dart        # Sidebar قابل للطي + Content
└── mobile_layout.dart        # Bottom Navigation + Content
```

### 6. ملف README.md احترافي (للريبو)

```markdown
# DT.Teeth — نظام إدارة مركز طب الأسنان الشامل

## 📋 الوصف
نظام ويب متكامل لإدارة المخبر والمستودع ضمن مركز طب أسنان.

## 🛠 التقنيات
- Flutter Web (Dart)
- Clean Architecture + BLoC
- Laravel Backend (قيد التطوير)

## 🚀 التشغيل
flutter pub get
flutter run -d chrome

## 📁 هيكل المشروع
[الهيكل الكامل]

## 👥 الفريق
[أسماء الفريق]
```

### 7. ملف analysis_options.yaml صارم

```yaml
# تفعيل قواعد Lint صارمة — يمنع الكود السيء
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    require_trailing_commas: true
```

---

## ملخص التحديثات الجديدة

| القرار | الموضوع | الخلاصة |
|--------|---------|---------|
| #12 | الخطوط | Cairo (أساسي) + Tajawal (احتياطي) — يدعم عربي وإنكليزي |
| #13 | Firebase | نعم مشروع Firebase — لاحقاً — فقط للإشعارات (FCM) |
| #14 | الإنكليزية | لا هلق — بنية جاهزة بملف Strings مركزي |
| #15 | Dark/Light | ندعم الاثنين (موجودين بملف HTML أصلاً) |

---

> **آخر تحديث:** أبريل 2026 (النسخة 3)
> **المسؤولة:** غزال — نظام المخبر + المستودع
> **حالة الباك آند:** لم يبدأ بعد — الواجهات تعمل على Mock Data
> **إجمالي القرارات التقنية الموثقة:** 25 قرار

---

## الجزء الخامس عشر: Error Handling الاحترافي — القرار 16

### فلسفة معالجة الأخطاء

> **القاعدة الذهبية:** المستخدم لا يرى أبداً شاشة بيضاء أو رسالة إنكليزية تقنية. كل خطأ = رسالة عربية واضحة + إجراء ممكن.

### هيكل Failure Classes

```dart
// lib/core/error/failures.dart

abstract class Failure {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});
}

// أخطاء السيرفر
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
  
  factory ServerFailure.fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400: return const ServerFailure('البيانات المرسلة غير صحيحة', code: '400');
      case 401: return const ServerFailure('انتهت صلاحية الجلسة — سجّل دخولك مجدداً', code: '401');
      case 403: return const ServerFailure('ليس لديك صلاحية للوصول لهذه الصفحة', code: '403');
      case 404: return const ServerFailure('العنصر المطلوب غير موجود', code: '404');
      case 409: return const ServerFailure('يوجد تعارض — تم تعديل البيانات من مستخدم آخر', code: '409');
      case 422: return const ServerFailure('تحقق من الحقول المطلوبة', code: '422');
      case 500: return const ServerFailure('خطأ في السيرفر — حاول مرة أخرى بعد قليل', code: '500');
      case 503: return const ServerFailure('السيرفر في صيانة — عد لاحقاً', code: '503');
      default:  return ServerFailure('خطأ غير متوقع ($statusCode)', code: '$statusCode');
    }
  }
}

// أخطاء الشبكة
class NetworkFailure extends Failure {
  const NetworkFailure() : super('لا يوجد اتصال بالإنترنت — تحقق من الشبكة');
}

// أخطاء التخزين المحلي
class CacheFailure extends Failure {
  const CacheFailure() : super('خطأ في البيانات المحلية — حاول مجدداً');
}

// أخطاء التحقق (Validation)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('انتهت مهلة الانتظار — السيرفر لا يستجيب');
}
```

### كيف تظهر الأخطاء للمستخدم

```dart
// lib/core/shared_widgets/error_widget.dart
// شاشة خطأ موحدة بـ: أيقونة + رسالة عربية + زر "إعادة المحاولة"
// لا شاشات بيضاء أبداً!

class AppErrorWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback onRetry;
  // يعرض: رسالة الخطأ + زر إعادة + اقتراح حل
}
```

---

## الجزء السادس عشر: Performance & Optimization — القرار 17

### مبدأ الأداء: زمن استجابة أقل من ثانيتين (من SRS)

| التقنية | الهدف | التطبيق |
|---------|-------|---------|
| `const` Widgets | منع إعادة البناء غير الضرورية | كل Widget ثابت يُعلّم بـ `const` — يوفر ~60% من عمليات إعادة الرسم |
| `ListView.builder` | عرض 10,000+ سجل بسلاسة | **Lazy rendering** — يرسم فقط العناصر الظاهرة على الشاشة. لو عندك 10,000 مادة بالمستودع، يرسم فقط ~15 ظاهرة |
| `Pagination` | تقليل حمل البيانات | لا نجلب كل السجلات دفعة واحدة — 20 سجل بكل صفحة + "تحميل المزيد" |
| `Image Caching` | سرعة تحميل الصور | `cached_network_image` — الصورة تُحمّل مرة واحدة وتُخزّن محلياً |
| `Debounce` في البحث | تقليل طلبات API | ينتظر 300ms بعد آخر حرف قبل إرسال طلب البحث — بدل طلب لكل حرف |
| `Shimmer Loading` | UX أثناء التحميل | بدل شاشة بيضاء فارغة، يظهر "هيكل" رمادي متوهج يحاكي شكل البيانات |

### كود مثال — ListView.builder مع 10,000 مادة

```dart
// ❌ غلط — يبني كل العناصر دفعة واحدة
ListView(
  children: materials.map((m) => MaterialCard(m)).toList(),
)

// ✅ صح — يبني فقط الظاهر على الشاشة
ListView.builder(
  itemCount: materials.length,    // حتى لو 10,000
  itemBuilder: (context, index) => const MaterialCard(material: materials[index]),
)
```

### 1000 مستخدم متزامن — كيف نتحمل؟

| الجانب | التقنية |
|--------|---------|
| **Flutter (الفرونت)** | Lazy Loading, Pagination, Local Caching, Debounced Search |
| **Laravel (الباك)** | Database Indexing, Query Caching (Redis), Queue Workers للإشعارات |
| **الاختبار** | أداة **k6** أو **Apache JMeter** لمحاكاة 1000 مستخدم متزامن |

---

## الجزء السابع عشر: انقطاع الإنترنت — القرار 18 (Offline Strategy)

| | التفاصيل |
|---|---|
| **القرار** | Local Caching باستخدام `Hive` + Connectivity Listener |
| **السبب** | نظام طبي لا يجب أن يتوقف لو انقطع الإنترنت 5 دقائق. البيانات المهمة تُخزّن محلياً وتتزامن عند العودة |
| **البديل** | **ObjectBox:** أسرع لكن أثقل وأعقد. **SharedPreferences:** لا يكفي لبيانات معقدة. **sqflite:** ممتاز لكن أثقل من Hive لحالتنا |

### كيف يعمل

```
1. المستخدم يفتح صفحة المواد
2. الطلب يذهب للـ API
3. البيانات تُعرض وتُخزّن محلياً (Hive)
4. ← لو انقطع الإنترنت ← تُعرض النسخة المحلية + Banner "وضع عدم الاتصال"
5. ← لو رجع الإنترنت ← يتزامن تلقائياً + يختفي Banner
```

### HydratedBloc — حفظ حالة الـ BLoC — القرار 19

| | التفاصيل |
|---|---|
| **القرار** | استخدام `hydrated_bloc` لحفظ حالة BLoC في Local Storage |
| **السبب** | لو المستخدم أغلق المتصفح فجأة أثناء ملء نموذج أو تصفح قائمة، عند الفتح مجدداً يعود لنفس النقطة |
| **كيف؟** | `HydratedBloc` يحفظ الـ State تلقائياً ويستعيده عند إعادة الفتح |

```dart
class WarehouseOrdersBloc extends HydratedBloc<OrdersEvent, OrdersState> {
  @override
  OrdersState? fromJson(Map<String, dynamic> json) => OrdersState.fromJson(json);
  
  @override
  Map<String, dynamic>? toJson(OrdersState state) => state.toJson();
}
```

---

## الجزء الثامن عشر: ميزات ذكية تميّز المشروع (Smart Features)

### الميزة 1: توليد الفواتير PDF — القرار 20

| | التفاصيل |
|---|---|
| **القرار** | زر "تصدير PDF" في صفحات الفواتير والتقارير |
| **المكتبة** | `pdf` package + `printing` package |
| **السبب** | أي نظام إداري بدون مخرجات ورقية يعتبر ناقصاً. الدكتور سيسأل: "كيف أطبع فاتورة؟" |
| **التطبيق** | زر واحد ← يولّد PDF بهوية المركز (لوغو + ألوان + بيانات) ← يفتح في نافذة طباعة أو تحميل |

```dart
// lib/features/warehouse/presentation/utils/pdf_generator.dart
class InvoicePdfGenerator {
  static Future<Uint8List> generate(InvoiceEntity invoice) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(children: [
          // لوغو المركز
          // بيانات الفاتورة
          // جدول المواد والأسعار
          // الإجمالي
          // توقيع رئيس المستودع
        ]),
      ),
    );
    return pdf.save();
  }
}
```

### الميزة 2: سجل النشاطات (Audit Log) — القرار 21

| | التفاصيل |
|---|---|
| **القرار** | شاشة "سجل النشاطات" في كل نظام |
| **السبب** | **فكرتك صحيحة 100%.** في أنظمة المستودعات والمخابر، أهم سؤال هو "من فعل ماذا ومتى؟". هذا يثبت أنك تفكري في أمان البيانات ومنع التلاعب |
| **كيف يعمل** | كل عملية (إضافة مادة، تغيير حالة طلبية، حذف) تُسجّل بـ: اسم المستخدم + العملية + الوقت + التفاصيل |

```dart
// نموذج سجل النشاط
@freezed
class ActivityLog with _$ActivityLog {
  const factory ActivityLog({
    required String id,
    required String userId,
    required String userName,
    required String action,        // "سحب مواد" / "تغيير حالة طلبية"
    required String details,       // "سحب 10 قطع زركون"
    required DateTime timestamp,
    required String module,        // "warehouse" / "lab"
  }) = _ActivityLog;
}
```

### عرض السجل

```
📋 سجل النشاطات (اليوم)
━━━━━━━━━━━━━━━━━━━━━
09:00 ص | محمد علي | سحب 10 قطع زركون من المستودع
09:15 ص | سامر حسن | أنهى طلبية LAB-044 (جسر — د. خالد)
10:30 ص | رئيس المخبر | وكّل طلبية LAB-045 لـ محمد علي
11:00 ص | رئيس المستودع | أضاف مادة جديدة: سيليكون طبع × 20
```

### الميزة 3: إدارة الهالك (Wastage Management) — القرار 22

| | التفاصيل |
|---|---|
| **القرار** | زر "تبليغ عن هالك" في نظام المخبر والمستودع |
| **السبب** | فكرة قوية جداً! الإدارة تحب هذه الميزة لأنها تكشف الهدر المالي وتساعد في دقة الجرد الشهري (UC-17 بالـ SRS) |
| **كيف يعمل** | الفني يضغط "تبليغ عن هالك" → يختار المادة → يحدد الكمية → يكتب السبب (خطأ تقني / مادة تالفة / كسر أثناء التصنيع) → الكمية تنقص من المستودع تلقائياً |

```dart
@freezed
class WastageReport with _$WastageReport {
  const factory WastageReport({
    required String id,
    required String materialId,
    required String materialName,
    required int quantity,
    required String reason,        // "خطأ تقني" / "مادة تالفة" / "كسر"
    required String reportedBy,
    required DateTime timestamp,
    required String relatedOrderId, // الطلبية المرتبطة (لو في)
  }) = _WastageReport;
}
```

### الميزة 4: أولوية الكرسي (Chair-side Priority) — القرار 23

| | التفاصيل |
|---|---|
| **القرار** | علامة "مريض على الكرسي — عاجل" على الطلبيات |
| **السبب** | أحياناً المريض موجود على كرسي العلاج والدكتور ينتظر المخبر لتعديل بسيط. هالطلبية لازم تتصدر القائمة |
| **كيف يعمل** | السكرتيرة/الطبيب يحدد "Urgent - Patient on Chair" ← الطلبية تظهر بلون أحمر وامض بأعلى قائمة المخبر ← إشعار صوتي لرئيس المخبر |
| **للدكتور** | "النظام يراعي حالة الازدحام داخل المركز ويعطي أولوية للمريض الموجود فعلياً لتقليل وقت الانتظار" |

### الميزة 5: الفوترة التلقائية (Automatic Billing Integration) — القرار 24

| | التفاصيل |
|---|---|
| **فكرتك** | المخبري لا يتدخل في المال، لكن عند إنهاء العمل والضغط على "تم"، النظام يرسل التكلفة تلقائياً لنظام السكرتيرة |
| **هل صحيحة؟** | **نعم، صحيحة 100% وممتازة!** هاي ميزة احترافية تربط المخبر بالمحاسبة بدون تدخل يدوي |
| **هل لازم نطبقها؟** | **نعم، لكن كـ "بنية جاهزة"** — لأنو نظام السكرتيرة ليس من مسؤوليتك. نبني الجزء الخاص بالمخبر (إرسال التكلفة) ونترك الاستقبال لفريق السكرتيرة |

```
التدفق:
1. المخبري ينهي تلبيسة → يضغط "تم"
2. النظام يحسب: نوع العمل (PFM) = 20$ + المواد المستخدمة = 5$ → إجمالي = 25$
3. يُرسل "إشعار تكلفة" لنظام السكرتيرة
4. السكرتيرة تشوف: "فاتورة المريض X يجب أن تزيد بـ 25$"
```

```dart
// الجزء الخاص بالمخبر (نبنيه نحن)
class LabCostCalculator {
  static double calculateOrderCost(LabOrderEntity order) {
    // سعر ثابت حسب نوع العمل
    final laborCost = _getLaborCost(order.type); // crown, bridge, etc.
    // + سعر المواد المستهلكة
    final materialCost = _getMaterialCost(order.materialsUsed);
    return laborCost + materialCost;
  }
}

// عند الضغط على "تم"
// يُنشأ CostNotification ويُرسل للباك
// الباك يوزعه على نظام السكرتيرة
```

### الميزة 6: البحث المتقدم (Global Search / Command Palette) — القرار 25

| | التفاصيل |
|---|---|
| **القرار** | مربع بحث شامل في Topbar (اختصار Ctrl+K) |
| **السبب** | يعطي طابعاً احترافياً جداً. بدل ما يفتح كل شاشة ويدور — يكتب ويحصل |
| **كيف يعمل** | كتابة "زركون" → يبحث بالمستودع (مواد) + بالمخبر (طلبيات فيها زركون). كتابة "د. سارة" → يعرض طلبيات د. سارة |

```dart
// lib/core/shared_widgets/global_search.dart
class GlobalSearchWidget extends StatelessWidget {
  // يظهر بـ Ctrl+K أو بالضغط على مربع البحث
  // يبحث في: المواد، الطلبيات، الفواتير، الفنيين
  // يعرض النتائج مصنفة حسب النوع
}
```

---

## الجزء التاسع عشر: إدارة الفنيين والدوامات (Lab Technicians)

### المتطلب (من SRS — UC-71)

> "يتيح النظام لرئيس المخبر عرض قائمة المخبريين (الفنيين) مع معلوماتهم وأوقات دوامهم."

### التطبيق — التحقق من الدوام قبل التوكيل

```dart
class TechnicianAvailabilityChecker {
  /// يتحقق: هل الفني ضمن وقت عمله؟
  static bool isAvailable(TechnicianEntity tech) {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    return currentTime.isAfter(tech.shiftStart) && currentTime.isBefore(tech.shiftEnd);
  }
  
  /// يعرض فقط الفنيين المتاحين للتوكيل
  static List<TechnicianEntity> getAvailableTechnicians(List<TechnicianEntity> all) {
    return all.where((t) => isAvailable(t) && t.currentOrder == null).toList();
  }
}
```

### سيناريو التوكيل

```
1. رئيس المخبر يفتح طلبية LAB-045
2. يضغط "توكيل"
3. النظام يعرض فقط الفنيين:
   ✅ المتاحين (ضمن وقت الدوام)
   ✅ غير مشغولين (ما عندهم طلبية حالية)
   ❌ يخفي الفنيين خارج الدوام أو المشغولين
4. يختار الفني → تتسند الطلبية → يظهر اسم الفني على البطاقة
```

---

## الجزء العشرون: ملخص الـ Smart Features الكامل

| # | الميزة | النظام | القيمة للدكتور |
|---|--------|--------|---------------|
| 1 | **PDF Generation** | مشترك | "النظام ينتج مخرجات ورقية" |
| 2 | **Audit Log** | مشترك | "أمان البيانات — من فعل ماذا ومتى" |
| 3 | **Wastage Management** | مخبر + مستودع | "كشف الهدر المالي ودقة الجرد" |
| 4 | **Chair-side Priority** | مخبر | "تقليل وقت انتظار المريض على الكرسي" |
| 5 | **Auto Billing** | مخبر → سكرتيرة | "ربط تلقائي بين التصنيع والمحاسبة" |
| 6 | **Global Search (Ctrl+K)** | مشترك | "بحث شامل بضغطة واحدة" |
| 7 | **Technician Shift Check** | مخبر | "التوكيل الذكي — فقط الفنيين المتاحين" |
| 8 | **Offline Mode + HydratedBloc** | مشترك | "النظام يعمل حتى بدون إنترنت" |

---

## الجزء الحادي والعشرون: المكتبات الجديدة المطلوبة

| المكتبة | الغرض | القرار |
|---------|--------|--------|
| `pdf` + `printing` | توليد فواتير PDF | #20 |
| `hive` + `hive_flutter` | تخزين محلي (Offline) | #18 |
| `hydrated_bloc` | حفظ حالة BLoC | #19 |
| `connectivity_plus` | كشف انقطاع الإنترنت | #18 |
| `cached_network_image` | تخزين الصور | #17 |

---

## ملخص التحديثات — النسخة 3

| القرار | الموضوع | الخلاصة |
|--------|---------|---------|
| #16 | Error Handling | Failure classes + رسائل عربية لكل حالة خطأ (400-503) |
| #17 | Performance | const Widgets, ListView.builder, Pagination, Debounce |
| #18 | Offline | Hive caching + Connectivity listener + Auto-sync |
| #19 | HydratedBloc | حفظ الحالة — المستخدم يعود لنفس النقطة عند إعادة الفتح |
| #20 | PDF Generation | فواتير وتقارير بصيغة PDF قابلة للطباعة |
| #21 | Audit Log | سجل نشاطات — من فعل ماذا ومتى |
| #22 | Wastage | تبليغ عن هالك — كشف الهدر المالي |
| #23 | Chair Priority | أولوية المريض على الكرسي — طلبية عاجلة وامضة |
| #24 | Auto Billing | تكلفة تلقائية من المخبر للسكرتيرة |
| #25 | Global Search | Command Palette بـ Ctrl+K — بحث شامل |

---

## الجزء الثاني والعشرون: وحدات القياس المتعددة (Unit Conversion) — القرار 26

### المشكلة

المستودع يشتري "كرتونة كفوف" (100 قطعة)، لكن العيادة تطلب "5 قطع". لازم النظام يفهم العلاقة بين الوحدات.

### الحل — نظام وحدات ذكي

```dart
@freezed
class MaterialUnit with _$MaterialUnit {
  const factory MaterialUnit({
    required String purchaseUnit,    // وحدة الشراء: "كرتونة"
    required String consumeUnit,     // وحدة الصرف: "قطعة"
    required double conversionRate,  // معدل التحويل: 1 كرتونة = 100 قطعة
  }) = _MaterialUnit;
}

// مثال عملي
// المادة: قفازات لاتكس
// purchaseUnit: "كرتونة"
// consumeUnit: "قطعة"  
// conversionRate: 100
//
// المخزون: 3 كراتين = 300 قطعة (متاح للصرف)
// الدكتور يطلب 50 قطعة → النظام يعرف إنو = نصف كرتونة
// المستودع يتنبه لما ينزل تحت كرتونة واحدة (100 قطعة)
```

### العرض بالواجهة

```
📦 قفازات لاتكس M
━━━━━━━━━━━━━━━━
المخزون: 3 كراتين (300 قطعة)
وحدة الشراء: كرتونة (100 قطعة)
وحدة الصرف: قطعة
الحد الأدنى: 100 قطعة (كرتونة واحدة)
```

### أمثلة على الوحدات بالمركز

| المادة | وحدة الشراء | وحدة الصرف | التحويل |
|--------|------------|-----------|---------|
| قفازات | كرتونة | قطعة | 1:100 |
| مخدر | علبة | حقنة | 1:50 |
| خيط خياطة | صندوق | بكرة | 1:12 |
| سيليكون | كيلو | غرام | 1:1000 |
| شاش طبي | علبة | قطعة | 1:50 |

---

## الجزء الثالث والعشرون: تتبع الصلاحية الذكي (Expiry Tracking) — القرار 27

### القاعدة: FEFO — First Expiry, First Out

> المواد الأقرب لانتهاء الصلاحية تُصرف أولاً (مثل المخدر).

### نظام التنبيهات المتدرج

```dart
enum ExpiryLevel {
  safe,        // أخضر — أكثر من 90 يوم
  warning,     // أصفر — 30-90 يوم
  danger,      // برتقالي — 7-30 يوم
  critical,    // أحمر وامض — أقل من 7 أيام
  expired,     // أسود مشطوب — منتهية الصلاحية
}

class ExpiryChecker {
  static ExpiryLevel check(DateTime expiryDate) {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return ExpiryLevel.expired;
    if (daysLeft <= 7) return ExpiryLevel.critical;
    if (daysLeft <= 30) return ExpiryLevel.danger;
    if (daysLeft <= 90) return ExpiryLevel.warning;
    return ExpiryLevel.safe;
  }
}
```

### العرض بالواجهة — لون المادة يتغير تلقائياً

```
🔴 مطهّر كحولي — ينتهي خلال 7 أيام (25/03/2026) ← صرّفه أولاً!
🟠 سيليكون طبع — ينتهي خلال 23 يوم (10/04/2026)
🟡 حقن بنج — ينتهي خلال 28 يوم (15/04/2026)
🟢 قفازات لاتكس — ينتهي خلال 9 أشهر (31/12/2026)
⚫ [محذوف] مادة X — منتهية الصلاحية ← تم حظر الصرف تلقائياً
```

### قاعدة ذكية

```dart
// عند طلب صرف مادة، النظام يختار تلقائياً الدفعة الأقرب لانتهاء الصلاحية
class SmartDispenser {
  static MaterialBatch selectBatch(List<MaterialBatch> batches) {
    // يرتب حسب تاريخ الصلاحية (الأقرب أولاً)
    // يتجاهل الدفعات المنتهية
    // يختار أقرب دفعة صالحة = FEFO
    final valid = batches.where((b) => b.expiryDate.isAfter(DateTime.now()));
    return valid.reduce((a, b) => a.expiryDate.isBefore(b.expiryDate) ? a : b);
  }
}
```

---

## الجزء الرابع والعشرون: منع التلاعب والطلبيات الوهمية (Anti-Fraud System)

### الاستراتيجية 1: المصادقة الثنائية للطلب (Double-Handshake) — القرار 28

> **القاعدة:** لا يوجد صرف بدون طلب. لا يوجد طلب بدون مرجع.

```
الدكتور ← يُنشئ طلب مواد (Request ID: REQ-001)
    ↓
المستودع ← يرى الطلب ← يصرف بناءً على REQ-001
    ↓
❌ زر "صرف مادة" لا يظهر إلا إذا كان هناك طلب رقمي قادم
❌ أمين المستودع لا يستطيع إنشاء فاتورة صرف "من رأسه"
```

```dart
// في واجهة المستودع
class DispenseMaterialButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // الزر يظهر فقط لو في طلب مرتبط
    if (order.requestId == null) {
      return const SizedBox.shrink(); // مخفي — لا صرف بدون طلب
    }
    return ElevatedButton(
      onPressed: () => _dispense(order),
      child: const Text('صرف المادة'),
    );
  }
}
```

### الاستراتيجية 2: سجل التدقيق غير القابل للمحو (Immutable Audit Log) — القرار 29

> **الصندوق الأسود للمشروع:** حتى لو عدّل أمين المستودع كمية لاحقاً، السجل يكشف كل شي.

```dart
@freezed
class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required String id,
    required DateTime timestamp,
    required String userId,
    required String userName,
    required String userRole,          // "مدير مخبر" / "أمين مستودع"
    required String action,            // "CREATE" / "UPDATE" / "DELETE" / "DISPENSE"
    required String entity,            // "material" / "order" / "invoice"
    required String entityId,          // "M001"
    required String description,       // "تغيير كمية قفازات من 10 إلى 5"
    String? oldValue,                  // القيمة القديمة: "10"
    String? newValue,                  // القيمة الجديدة: "5"
    required String ipAddress,         // عنوان IP — لتتبع الجهاز
  }) = _AuditLogEntry;
}
```

### القواعد البرمجية للسجل

```
✅ كل عملية تُسجّل تلقائياً (لا يمكن للمستخدم تجاوزها)
✅ السجل Read-Only — لا أحد يمحيه أو يعدله
✅ فقط Admin يقدر يشوفه (لا المخبري ولا أمين المستودع)
✅ يسجل: القيمة القديمة + القيمة الجديدة + من + متى + من أي جهاز
```

### مثال على ما يظهر للإدارة

```
📋 سجل التدقيق — المستودع
━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ 16:00 | أمين المستودع | تعديل كمية
   المادة: قفازات لاتكس
   القديم: 10 → الجديد: 5
   السبب: [لم يُدخل سبب] ← ⚠️ تنبيه: تعديل بدون تبرير

✅ 09:15 | أمين المستودع | صرف مادة
   المادة: مخدر × 2 حقنة
   المرجع: طلب REQ-018 (د. سارة)
   ← مطابق للطلب ✓
```

### الاستراتيجية 3: الربط المرجعي (Reference Integrity) — القرار 30

> **كل طلب مواد من المخبر للمستودع لازم يكون مرتبط بطلبية سنية لمريض حقيقي.**

```dart
// عند إنشاء طلب مواد من المخبر
class CreateMaterialRequest {
  final String materialId;
  final int quantity;
  final String labOrderId;      // ← إلزامي: رقم طلبية المريض
  final String requestedBy;
  
  // التحقق الذكي
  bool isReasonable() {
    // لو المخبري طلب 5 بلوكات زركون
    // والطلبية المرتبطة = تلبيسة واحدة (تحتاج بلوك واحد)
    // ← النظام ينبّه: "الكمية المطلوبة تتجاوز الحاجة المتوقعة"
    final expectedQty = _getExpectedQuantity(labOrderId, materialId);
    return quantity <= expectedQty * 1.5; // هامش 50% للهالك
  }
}
```

---

## الجزء الخامس والعشرون: نظام الحجز المؤقت (Reserved Stock) — القرار 31

### المشكلة

دكتورين يطلبون آخر علبة مخدر بنفس الثانية. بدون حجز = تضارب (Conflict).

### الحل — 3 حقول للمخزون

```dart
@freezed
class StockStatus with _$StockStatus {
  const factory StockStatus({
    required int inStock,       // الكمية الفعلية بالمستودع: 10
    required int reserved,      // محجوز (طلبات قيد الانتظار): 2
    required int available,     // المتاح للطلب: 8 (= inStock - reserved)
  }) = _StockStatus;
}
```

### التدفق الكامل

```
الحالة الأولية:
┌─────────────────────────────────┐
│ مخدر موضعي                     │
│ المخزون: 10  |  محجوز: 0       │
│ المتاح: 10                     │
└─────────────────────────────────┘

← د. سارة تطلب 3 حقن
┌─────────────────────────────────┐
│ مخدر موضعي                     │
│ المخزون: 10  |  محجوز: 3       │
│ المتاح: 7    ← هذا ما يراه     │
│                  أي شخص آخر     │
└─────────────────────────────────┘

← أمين المستودع يوافق على طلب د. سارة
┌─────────────────────────────────┐
│ مخدر موضعي                     │
│ المخزون: 7   |  محجوز: 0       │
│ المتاح: 7                      │
│ [حالة: قيد النقل → بانتظار     │
│  تأكيد استلام د. سارة]         │
└─────────────────────────────────┘

← أمين المستودع يرفض
┌─────────────────────────────────┐
│ مخدر موضعي                     │
│ المخزون: 10  |  محجوز: 0       │
│ المتاح: 10   ← عاد كما كان    │
└─────────────────────────────────┘
```

### الفائدة

```
❌ بدون حجز: دكتورين يطلبون آخر 5 حقن بنفس الوقت = إحباط
✅ مع حجز: أول من يطلب "يحجز" → الثاني يرى إنو المتاح أقل
```

---

## الجزء السادس والعشرون: تأكيد الاستلام (Check-in System) — القرار 32

### المشكلة

المستودع يقول "صرفنا 10 علب"، المخبر يقول "وصلنا 8 بس". مين الصادق؟

### الحل — عملية الصرف من خطوتين

```
الخطوة 1: المستودع يصرف
┌────────────────────────────┐
│ حالة الصرفية: قيد النقل 🚚  │
│ المسؤولية: أمين المستودع    │
│ حتى يتم تأكيد الاستلام     │
└────────────────────────────┘

الخطوة 2: المخبر يؤكد الاستلام
┌────────────────────────────┐
│ حالة الصرفية: تم الاستلام ✅ │
│ المسؤولية: انتقلت للمخبري   │
│ الفرق: 0 ← مطابق          │
└────────────────────────────┘
```

```dart
enum DispenseStatus {
  pending,      // بانتظار موافقة المستودع
  approved,     // وافق المستودع
  inTransit,    // قيد النقل — المسؤولية على المستودع
  received,     // المخبر أكد الاستلام — المسؤولية انتقلت
  disputed,     // المخبر أبلغ عن فرق في الكمية ← تنبيه أحمر
}
```

### لو في فرق بالكمية

```
المستودع صرف: 10 علب مخدر
المخبر استلم: 8 علب فقط
← المخبر يضغط "إبلاغ عن فرق"
← النظام ينشئ: Discrepancy Alert
← التنبيه يظهر عند: الإدارة + أمين المستودع + في Audit Log
← المستودع ملزم يبرر الفرق
```

---

## الجزء السابع والعشرون: المطابقة التلقائية — تقرير آخر اليوم (Reconciliation) — القرار 33

### التقرير المتقاطع (Cross-Report)

```
┌──────────────── تقرير نهاية اليوم ────────────────┐
│                                                      │
│  📦 زاوية المستودع:          🧪 زاوية المخبر:       │
│  ─────────────────          ─────────────────        │
│  صرفنا اليوم:               استلمنا اليوم:           │
│  • قفازات: 100 قطعة         • قفازات: 100 قطعة  ✅  │
│  • مخدر: 10 حقن             • مخدر: 8 حقن      ⚠️  │
│  • زركون: 3 بلوك            • زركون: 3 بلوك    ✅  │
│                                                      │
│  ⚠️ تنبيه: فرق في المخدر (2 حقن مفقودة)            │
│  ← يتطلب تحقيق من الإدارة                           │
└──────────────────────────────────────────────────────┘
```

```dart
class ReconciliationReport {
  final DateTime date;
  final List<ReconciliationItem> items;
  
  bool get hasDiscrepancies => items.any((i) => i.dispatched != i.received);
  List<ReconciliationItem> get discrepancies => 
    items.where((i) => i.dispatched != i.received).toList();
}

@freezed
class ReconciliationItem with _$ReconciliationItem {
  const factory ReconciliationItem({
    required String materialName,
    required int dispatched,     // ما صرفه المستودع
    required int received,       // ما أكده المستلم
    required int difference,     // الفرق
    required bool isMatched,     // مطابق؟
  }) = _ReconciliationItem;
}
```

---

## الجزء الثامن والعشرون: هيكل المجلدات المحدّث (بعد الميزات الجديدة)

### إضافات على هيكل المجلدات الأصلي

```
lib/features/
├── warehouse/
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── material_entity.dart         # + حقول وحدة القياس + صلاحية
│   │   │   ├── stock_status_entity.dart     # 🆕 inStock / reserved / available
│   │   │   ├── dispense_entity.dart         # 🆕 حالة الصرف (قيد النقل / مُستلم)
│   │   │   ├── wastage_report_entity.dart   # 🆕 تقرير الهالك
│   │   │   └── reconciliation_entity.dart   # 🆕 تقرير المطابقة
│   │   │
│   │   └── usecases/
│   │       ├── dispense_material.dart       # 🆕 صرف مع حجز مؤقت
│   │       ├── confirm_receipt.dart          # 🆕 تأكيد استلام
│   │       ├── report_discrepancy.dart       # 🆕 إبلاغ عن فرق
│   │       └── generate_reconciliation.dart  # 🆕 تقرير المطابقة
│   │
│   └── presentation/
│       ├── screens/
│       │   ├── reconciliation_screen.dart    # 🆕 شاشة المطابقة
│       │   └── expiry_tracking_screen.dart   # 🆕 شاشة الصلاحيات
│       └── widgets/
│           ├── stock_status_badge.dart       # 🆕 شارة (متاح/محجوز/نفذ)
│           ├── expiry_color_indicator.dart   # 🆕 لون حسب الصلاحية
│           └── dispense_status_stepper.dart  # 🆕 مراحل الصرف
│
├── lab/
│   └── presentation/
│       ├── screens/
│       │   └── receipt_confirmation_screen.dart  # 🆕 تأكيد الاستلام
│       └── widgets/
│           └── chair_priority_badge.dart    # 🆕 شارة "مريض على الكرسي"
│
└── shared/
    ├── models/
    │   └── audit_log_entry.dart             # 🆕 سجل التدقيق
    └── services/
        ├── audit_service.dart               # 🆕 تسجيل كل عملية تلقائياً
        └── expiry_checker_service.dart      # 🆕 فحص الصلاحيات يومياً
```

---

## الجزء التاسع والعشرون: Freezed Models المحدّثة للمواد

```dart
@freezed
class MaterialEntity with _$MaterialEntity {
  const factory MaterialEntity({
    required String id,
    required String name,
    required String type,              // "مستهلكات" / "أدوية" / "مواد طبية" / "معدات"
    
    // وحدات القياس (القرار 26)
    required String purchaseUnit,      // وحدة الشراء: "كرتونة"
    required String consumeUnit,       // وحدة الصرف: "قطعة"
    required double conversionRate,    // 1 كرتونة = 100 قطعة
    
    // المخزون الثلاثي (القرار 31)
    required int inStock,              // الكمية الفعلية
    required int reserved,             // المحجوز
    @Default(0) int available,         // المتاح = inStock - reserved
    
    required int minQuantity,          // الحد الأدنى (بوحدة الصرف)
    required double pricePerUnit,      // السعر لكل وحدة صرف
    
    // الصلاحية (القرار 27)
    required DateTime expiryDate,
    @Default(false) bool isExpiringSoon,
    @Default(false) bool isExpired,
    @Default(false) bool isLowStock,
    
    String? supplierId,
    String? batchNumber,               // رقم الدفعة — لتتبع الصلاحية بدقة
  }) = _MaterialEntity;
}
```

---

---

## الجزء الثلاثون: منطق حساب نسبة الإنجاز (Completion Rate Engine) — القرار 34

### المشكلة

الداشبورد يعرض "نسبة الإنجاز" لكن بدون معادلة واضحة — كيف تُحسب؟

### الحل — معادلة On-Time Completion Rate

```
نسبة الإنجاز = (عدد الطلبات المسلّمة ضمن الموعد ÷ إجمالي الطلبات المسلّمة) × 100
```

- **ضمن الموعد** = الطلب اتسلّم قبل أو عند الـ Deadline
- **الـ Deadline** = لحظة بدء التصنيع + 48 ساعة (انظر القرار 35)
- الطلبات يلي ما خلصت بعد **لا تدخل** بالحساب — فقط المسلّمة

```dart
class CompletionRateCalculator {
  /// يحسب نسبة الإنجاز لفترة معينة
  static double calculate(List<LabOrder> completedOrders) {
    if (completedOrders.isEmpty) return 100.0;
    
    final onTime = completedOrders.where((order) {
      final deadline = order.manufacturingStartedAt!
          .add(const Duration(hours: 48));
      return order.deliveredAt!.isBefore(deadline) || 
             order.deliveredAt!.isAtSameMomentAs(deadline);
    }).length;
    
    return (onTime / completedOrders.length) * 100;
  }
}
```

### لماذا هذه المعادلة؟

| البديل | المشكلة |
|--------|---------|
| حساب كل الطلبات (بما فيها المعلقة) | يعطي نسبة مضللة — طلب جديد لم يبدأ بعد يخفض النسبة |
| حساب بناءً على عدد الأيام | لا يعكس الأداء الحقيقي — طلب صعب يحتاج وقت أكثر |
| **On-Time Rate (اختيارنا)** | يقيس الالتزام الفعلي بالمواعيد — عادل ودقيق |

---

## الجزء الحادي والثلاثون: قاعدة الـ 48 ساعة والطلبات العاجلة — القرار 35

### المشكلة

كيف يعرف النظام إن الطلب "ينتهي اليوم"؟ ومتى يبدأ العد التنازلي؟

### الحل — Deadline Engine

```
بدء العد = لحظة تغيير حالة الطلب إلى "قيد التصنيع"
الموعد النهائي (Deadline) = بدء العد + 48 ساعة
```

**المهم:** العد لا يبدأ عند وصول الطلب (حالة "جديد")، بل عند **بدء التصنيع فعلاً**.

```dart
@freezed
class LabOrder with _$LabOrder {
  const factory LabOrder({
    required String id,
    required String type,             // تلبيسة، جسر، ...
    required OrderStatus status,
    required DateTime createdAt,      // وقت وصول الطلب
    DateTime? manufacturingStartedAt, // ← بدء التصنيع (بدء العد)
    DateTime? readyAt,                // وقت الجاهزية
    DateTime? deliveredAt,            // وقت التسليم الفعلي
    String? assignedTechnicianId,     // المخبري المسؤول
    String? doctorId,
    String? patientName,
  }) = _LabOrder;
  
  /// الموعد النهائي — بعد 48 ساعة من بدء التصنيع
  DateTime? get deadline => manufacturingStartedAt
      ?.add(const Duration(hours: 48));
  
  /// هل ينتهي اليوم؟
  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    return deadline!.year == now.year && 
           deadline!.month == now.month && 
           deadline!.day == now.day;
  }
  
  /// الوقت المتبقي
  Duration? get timeRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now());
  }
  
  /// هل تأخر؟
  bool get isOverdue => 
    deadline != null && DateTime.now().isAfter(deadline!);
}
```

### حالات الطلب الكاملة (المُحدّثة)

```dart
enum OrderStatus {
  newOrder,            // جديد — وصل من الطبيب (العد لم يبدأ)
  pendingMaterials,    // 🆕 معلّق — بانتظار مواد من المستودع
  manufacturing,       // قيد التصنيع ← هنا يبدأ عد الـ 48 ساعة
  ready,               // جاهز للتسليم
  delivered,           // تم التسليم
  rejected,            // مرفوض — مع ذكر السبب
}
```

> **🆕 الحالة الجديدة "معلّق — بانتظار مواد":** عندما تكون المادة غير متوفرة بالمخبر لكن موجودة بالمستودع، الطلب يُعلّق حتى وصول المواد. العد التنازلي لا يبدأ إلا بعد تحويل الحالة إلى "قيد التصنيع".

---

## الجزء الثاني والثلاثون: نظام تقييم أداء الفريق (Performance Scoring) — القرار 36

### المشكلة

كيف نحدد مين أداؤه منيح ومين لا؟ وكيف نعرف إن المخبري خلّص طلبه ويقدر يستلم غيره؟

### الحل — نظام تقييم بثلاثة محاور مع أوزان

```
الدرجة الكلية = (عدد الطلبات × 0.40) + (سرعة التنفيذ × 0.35) + (الالتزام بالمواعيد × 0.25)
```

```dart
class TechnicianPerformance {
  final String technicianId;
  final String name;
  final int completedOrders;       // عدد الطلبات المنفذة بالشهر
  final double avgExecutionHours;  // متوسط وقت التنفيذ بالساعات
  final double onTimeRate;         // نسبة التسليم بالوقت (0-100)
  final TechnicianAvailability availability; // حالة التوفر

  /// حساب درجة الأداء (0-100) — نسبية مقارنة بالأفضل
  double calculateScore({
    required int maxOrders,        // أعلى عدد طلبات بالفريق
    required double minAvgTime,    // أقل متوسط وقت بالفريق
  }) {
    final orderScore = (completedOrders / maxOrders) * 100;
    final speedScore = (minAvgTime / avgExecutionHours) * 100;
    final timeScore = onTimeRate;
    
    return (orderScore * 0.40) + (speedScore * 0.35) + (timeScore * 0.25);
  }
}
```

### حالات توفر المخبري (Technician Availability)

```dart
enum TechnicianAvailability {
  busy,         // مشغول — لديه طلب قيد التنفيذ حالياً
  available,    // متاح — أنهى طلبه الحالي وجاهز لاستلام طلب جديد
  unavailable,  // غير متاح — إجازة أو خارج الدوام
}
```

### كيف يعرف النظام أن المخبري أنهى عمله؟

```
عندما يغيّر المخبري حالة الطلب من "قيد التصنيع" → "جاهز"
  ← النظام تلقائياً يغيّر حالة المخبري من "مشغول" → "متاح"
  ← يظهر لرئيس المخبر أن هذا الفني جاهز لاستلام طلب جديد
  ← يرسل إشعار: "الفني [الاسم] أنهى طلبه وجاهز لمهمة جديدة"
```

```dart
/// BLoC Event: عند تغيير حالة الطلب
class UpdateOrderStatusEvent extends LabEvent {
  final String orderId;
  final OrderStatus newStatus;
}

/// في الـ BLoC handler:
if (newStatus == OrderStatus.ready) {
  // 1. تحديث الطلب
  order = order.copyWith(status: OrderStatus.ready, readyAt: DateTime.now());
  
  // 2. تحرير المخبري تلقائياً
  technician = technician.copyWith(
    availability: TechnicianAvailability.available,
    currentOrderId: null,
  );
  
  // 3. إشعار رئيس المخبر
  notificationService.send(
    to: labManagerId,
    title: '✅ ${technician.name} أنهى الطلب ${order.id}',
    body: 'الفني متاح الآن لاستلام طلب جديد',
  );
  
  // 4. إشعار الطبيب
  notificationService.send(
    to: order.doctorId,
    title: '🦷 طلبك ${order.id} جاهز للاستلام',
    body: 'يمكنك استلام الطلب من المخبر',
  );
}
```

---

## الجزء الثالث والثلاثون: نظام تقييم الرضا (Satisfaction Rating) — القرار 37

### المشكلة

كيف نحدد نسبة رضا الأطباء عن عمل المخبر؟

### الحل — تقييم بعد كل استلام

```
بعد تسليم كل طلب ← النظام يطلب من الطبيب تقييم (1-5 نجوم)
نسبة الرضا = (مجموع التقييمات ÷ (عدد التقييمات × 5)) × 100
```

```dart
@freezed
class OrderRating with _$OrderRating {
  const factory OrderRating({
    required String orderId,
    required String doctorId,
    required int stars,           // 1-5
    String? comment,              // ملاحظة اختيارية
    required DateTime ratedAt,
  }) = _OrderRating;
}

class SatisfactionCalculator {
  static double calculate(List<OrderRating> ratings) {
    if (ratings.isEmpty) return 100.0;
    final totalStars = ratings.fold<int>(0, (sum, r) => sum + r.stars);
    return (totalStars / (ratings.length * 5)) * 100;
  }
  
  /// نسبة الرضا لمخبري معين
  static double forTechnician(
    String techId, 
    List<OrderRating> allRatings,
    List<LabOrder> allOrders,
  ) {
    final techOrderIds = allOrders
        .where((o) => o.assignedTechnicianId == techId)
        .map((o) => o.id)
        .toSet();
    final techRatings = allRatings
        .where((r) => techOrderIds.contains(r.orderId))
        .toList();
    return calculate(techRatings);
  }
}
```

### سير العمل

```
1. الطبيب يرسل طلب ← المخبر يصنّع ← يسلّم
2. حالة الطلب تتغير إلى "تم التسليم"
3. النظام يعرض للطبيب popup: "قيّم جودة العمل (1-5 نجوم)"
4. الطبيب يقيّم ← التقييم يُحفظ
5. يظهر بتقرير المخبر: "نسبة رضا الأطباء هذا الشهر: 94%"
```

---

## الجزء الرابع والثلاثون: منطق التوفر وحالة "معلّق" — القرار 38

### المشكلة

عند وصول طلب جديد وتحديد "غير متوفر" — بناءً على ماذا؟ المواد الموجودة بالمخبر فقط؟ أم بالمستودع كله؟

### الحل — ثلاث حالات بناءً على مستويين من المخزون

```
عند وصول طلب جديد:
├── المواد المطلوبة موجودة بالمخبر بكمية كافية؟
│   ├── ✅ نعم → حالة الطلب: "قيد التصنيع" → يبدأ العمل فوراً
│   └── ❌ لا → المواد موجودة بالمستودع؟
│       ├── ✅ نعم → حالة الطلب: "معلّق — بانتظار مواد"
│       │            → يُنشأ طلب توريد تلقائي للمستودع
│       │            → يُرسل إشعار للطبيب بالتأخير
│       └── ❌ لا → حالة الطلب: "مرفوض — المادة غير متوفرة"
│                    → يُرسل إشعار للطبيب بالسبب
```

```dart
class MaterialAvailabilityChecker {
  final LabInventoryRepository labInventory;
  final WarehouseRepository warehouseInventory;

  /// يفحص توفر المواد لطلب معين
  Future<AvailabilityResult> check(LabOrder order) async {
    // 1. فحص مخزون المخبر أولاً
    final labStock = await labInventory.getQuantity(order.requiredMaterialId);
    if (labStock >= order.requiredQuantity) {
      return AvailabilityResult.availableInLab;
    }
    
    // 2. فحص مخزون المستودع
    final whStock = await warehouseInventory.getAvailable(order.requiredMaterialId);
    if (whStock >= order.requiredQuantity) {
      return AvailabilityResult.availableInWarehouse; // ← معلّق
    }
    
    // 3. غير متوفر بالكامل
    return AvailabilityResult.unavailable; // ← مرفوض
  }
}

enum AvailabilityResult {
  availableInLab,        // موجود بالمخبر → ابدأ التصنيع
  availableInWarehouse,  // موجود بالمستودع → طلب توريد + تعليق
  unavailable,           // غير موجود → رفض مع سبب
}
```

### إشعار الطبيب بالتأخير

```dart
/// عند تعليق الطلب بسبب نقص مواد
void notifyDoctorOfDelay(LabOrder order, DateTime estimatedArrival) {
  final newDeadline = estimatedArrival.add(const Duration(hours: 48));
  
  notificationService.send(
    to: order.doctorId,
    title: '⏳ الطلب ${order.id} معلّق مؤقتاً',
    body: 'بسبب نقص مواد — الموعد المتوقع الجديد: '
          '${DateFormat('dd/MM HH:mm').format(newDeadline)}',
    type: NotificationType.orderDelayed,
  );
}

/// عند وصول المواد وبدء التصنيع
void notifyDoctorManufacturingStarted(LabOrder order) {
  notificationService.send(
    to: order.doctorId,
    title: '🔧 بدأ تصنيع طلبك ${order.id}',
    body: 'الموعد المتوقع: ${DateFormat('dd/MM HH:mm').format(order.deadline!)}',
    type: NotificationType.orderStarted,
  );
}
```

---

## الجزء الخامس والثلاثون: واجهة طلبات المواد من المستودع (Lab → Warehouse Orders) — القرار 39

### المشكلة

لا توجد واجهة بالمخبر لطلب مواد من المستودع أو تتبع الطلبيات أو تسجيل الاستلام.

### الحل — صفحة جديدة: "طلبات المستودع" بالسايدبار

```
الصفحة تحتوي:
┌──────────────────────────────────────────────────┐
│ 🏭 طلبات المستودع                                │
│                                                    │
│ [إنشاء طلبية جديدة]  [تصفية: الكل ▼]            │
│                                                    │
│ ┌─ الطلبيات النشطة ─────────────────────────────┐ │
│ │ REQ-001  قفازات × 200    ⏳ بانتظار الموافقة  │ │
│ │ REQ-002  سيليكون × 5     🚚 قيد التوصيل       │ │
│ │ REQ-003  حقن بنج × 50    ✅ تم التوصيل        │ │
│ └────────────────────────────────────────────────┘ │
│                                                    │
│ عند وصول المواد:                                   │
│ [✅ تأكيد الاستلام] → إدخال الكمية المستلمة       │
│ → تُضاف الكمية تلقائياً لمخزون المخبر             │
│ → إذا كان هناك طلب معلّق ← يتحول لـ "قيد التصنيع"│
└──────────────────────────────────────────────────┘
```

### حالات طلبية المواد

```dart
enum MaterialRequestStatus {
  pending,       // بانتظار موافقة المستودع
  approved,      // وافق المستودع
  inTransit,     // قيد التوصيل
  delivered,     // تم التوصيل — بانتظار تأكيد المخبر
  received,      // تأكيد الاستلام من المخبر ✅
  rejected,      // رفض المستودع — مع سبب
}
```

### هيكل المجلدات — الإضافة

```
lib/features/lab/
├── presentation/
│   ├── screens/
│   │   ├── lab_material_requests_screen.dart   # 🆕 صفحة طلبات المستودع
│   │   └── lab_receipt_confirmation_screen.dart # 🆕 تأكيد الاستلام
│   └── widgets/
│       └── material_request_card.dart          # 🆕 كارد طلبية مواد
├── domain/
│   ├── entities/
│   │   └── material_request_entity.dart        # 🆕
│   └── usecases/
│       ├── create_material_request.dart         # 🆕 إنشاء طلبية
│       ├── confirm_material_receipt.dart        # 🆕 تأكيد استلام
│       └── get_material_requests.dart           # 🆕 جلب الطلبيات
└── data/
    ├── models/
    │   └── material_request_model.freezed.dart  # 🆕
    └── repositories/
        └── material_request_repository_impl.dart # 🆕
```

---

## الجزء السادس والثلاثون: خوارزمية التنبيه الذكي لنفاد المواد (Smart Stock Alert) — القرار 40

### المشكلة

الطريقة التقليدية `if (quantity < 5) alert()` غبية — مادة تُستخدم 50 مرة باليوم تحتاج تنبيه مبكر، ومادة نادرة الاستخدام لا تحتاج.

### الحل — خوارزمية بناءً على معدل الاستهلاك (Consumption-Based Alert)

```
أيام متبقية = الكمية الحالية ÷ متوسط الاستهلاك اليومي (آخر 30 يوم)
```

```dart
class SmartStockAlertService {
  /// يحسب عدد الأيام المتبقية قبل نفاد المادة
  static StockAlertLevel checkMaterial({
    required int currentQuantity,
    required List<ConsumptionRecord> last30DaysConsumption,
    required int minQuantity, // الحد الأدنى كـ fallback
  }) {
    // حساب متوسط الاستهلاك اليومي
    final totalConsumed = last30DaysConsumption
        .fold<int>(0, (sum, r) => sum + r.quantity);
    final avgDailyConsumption = totalConsumed / 30.0;
    
    // حماية من القسمة على صفر (مادة لم تُستخدم خلال 30 يوم)
    if (avgDailyConsumption == 0) {
      // fallback للحد الأدنى التقليدي
      return currentQuantity <= minQuantity 
          ? StockAlertLevel.warning 
          : StockAlertLevel.safe;
    }
    
    final daysRemaining = currentQuantity / avgDailyConsumption;
    
    if (daysRemaining <= 3) return StockAlertLevel.critical;  // 🔴 أحمر
    if (daysRemaining <= 7) return StockAlertLevel.warning;   // 🟠 برتقالي
    if (daysRemaining <= 14) return StockAlertLevel.caution;  // 🟡 أصفر
    return StockAlertLevel.safe;                               // 🟢 آمن
  }
}

enum StockAlertLevel {
  critical,  // 🔴 أقل من 3 أيام — طلب فوري
  warning,   // 🟠 3-7 أيام — خطط للطلب
  caution,   // 🟡 7-14 يوم — راقب
  safe,      // 🟢 أكثر من 14 يوم — آمن
}
```

### مثال عملي

```
┌─────────────────────────────────────────────────────┐
│ المادة         │ الكمية │ استهلاك/يوم │ أيام متبقية │
│────────────────│────────│─────────────│─────────────│
│ قفازات لاتكس   │  200   │    15       │  13 يوم 🟡  │
│ حقن بنج        │   12   │     4       │   3 أيام 🔴 │
│ خيط خياطة      │   44   │     2       │  22 يوم 🟢  │
│ سيليكون طبع    │    3   │   0.5       │   6 أيام 🟠 │
│ بلوك زركون     │    8   │     0       │  آمن 🟢*    │
└─────────────────────────────────────────────────────┘
* بلوك الزركون: صفر استهلاك خلال 30 يوم ← fallback للحد الأدنى
```

### لماذا هذه الخوارزمية وليس الحد الثابت؟

| الطريقة | المشكلة |
|---------|---------|
| **حد ثابت (أقل من 5)** | مادة تُستخدم 50/يوم ← تنبهك متأخر جداً! |
| **حد ثابت (أقل من 50)** | مادة نادرة ← تنبهات كاذبة مزعجة |
| **Consumption-Based (اختيارنا)** | ذكي — يتكيف مع كل مادة حسب استخدامها الفعلي |

---

## الجزء السابع والثلاثون: الطلبات حسب النوع بالتقارير — القرار 41

### المشكلة

كيف يتحدد توزيع "تلبيسات 55%، جسور 30%، أخرى 15%" بواجهة التقارير؟

### الحل — تجميع بناءً على حقل نوع الطلب + فلتر الفترة

```dart
class OrderTypeReport {
  /// يحسب توزيع الطلبات حسب النوع لفترة معينة
  static Map<String, OrderTypeStats> generate({
    required List<LabOrder> orders,
    required DateTime from,
    required DateTime to,
  }) {
    final filtered = orders.where((o) =>
      o.createdAt.isAfter(from) && o.createdAt.isBefore(to)
    ).toList();
    
    final grouped = <String, List<LabOrder>>{};
    for (final order in filtered) {
      grouped.putIfAbsent(order.type, () => []).add(order);
    }
    
    return grouped.map((type, typeOrders) => MapEntry(
      type,
      OrderTypeStats(
        type: type,
        count: typeOrders.length,
        percentage: (typeOrders.length / filtered.length) * 100,
        avgTime: _calculateAvgTime(typeOrders),
      ),
    ));
  }
}
```

**الأنواع الممكنة** (يحددها الطبيب عند إرسال الطلب):

```dart
enum LabOrderType {
  crown,      // تلبيسة
  bridge,     // جسر
  veneer,     // قشرة
  denture,    // طقم أسنان
  implant,    // زرعة
  retainer,   // مثبت
  nightGuard, // واقي ليلي
  other,      // أخرى
}
```

---

## الجزء الثامن والثلاثون: فلتر التاريخ التفاعلي (Reactive Date Filter) — القرار 42

### المشكلة

لما المستخدم يختار تاريخ أو شهر من الفلتر أعلى الصفحة، لا يتغير شيء حتى يضغط زر — المطلوب تحديث فوري.

### الحل — Reactive Filter بـ BLoC

```dart
/// Event: عند تغيير الفلتر
class DateFilterChanged extends ReportEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final FilterPeriod period; // today, week, month, year, custom
}

/// في الـ BLoC:
on<DateFilterChanged>((event, emit) async {
  emit(state.copyWith(isLoading: true));
  
  final orders = await getOrdersUseCase(
    from: event.startDate,
    to: event.endDate,
  );
  
  emit(state.copyWith(
    isLoading: false,
    filteredOrders: orders,
    currentPeriod: event.period,
    // كل الإحصائيات تُعاد حسابها تلقائياً
    completionRate: CompletionRateCalculator.calculate(orders),
    typeDistribution: OrderTypeReport.generate(orders: orders, ...),
    teamPerformance: PerformanceCalculator.calculate(orders, ...),
  ));
});
```

### القاعدة في الـ UI

```dart
/// في الـ Widget — عند تغيير أي فلتر يُرسل Event فوراً
DropdownButton<FilterPeriod>(
  value: state.currentPeriod,
  onChanged: (period) {
    // ← فوراً بدون زر "تطبيق"
    context.read<ReportBloc>().add(DateFilterChanged(period: period!));
  },
  items: [
    DropdownMenuItem(value: FilterPeriod.today, child: Text('اليوم')),
    DropdownMenuItem(value: FilterPeriod.week, child: Text('هذا الأسبوع')),
    DropdownMenuItem(value: FilterPeriod.month, child: Text('هذا الشهر')),
    DropdownMenuItem(value: FilterPeriod.year, child: Text('هذا السنة')),
    DropdownMenuItem(value: FilterPeriod.custom, child: Text('مخصص')),
  ],
);
```

**المبدأ:** كل `onChanged` يُطلق Event ← الـ BLoC يعيد حساب كل شيء ← الـ UI يتحدث تلقائياً عبر `BlocBuilder`. لا حاجة لزر "تطبيق".

---

## الجزء التاسع والثلاثون: تخصيص حجم الخط من الإعدادات (Font Size Customization) — القرار 43

### المشكلة

الدكتور علّق أن الخط صغير. المطلوب: المستخدم يقدر يكبّر أو يصغّر الخط من الإعدادات بدون ما يتأثر حجم الـ Components (الأزرار، الكروت، الحقول).

### الحل — Text Scale Factor مع حدود (Clamped Text Scaling)

```dart
/// ثوابت أحجام الخط المسموحة
class FontScaleConfig {
  static const double minScale = 0.85;   // أصغر حجم مسموح
  static const double defaultScale = 1.0; // الحجم الافتراضي
  static const double maxScale = 1.35;    // أكبر حجم مسموح
  static const double step = 0.05;        // خطوة التكبير/التصغير
  
  /// الخيارات المتاحة للمستخدم
  static const List<FontScaleOption> options = [
    FontScaleOption(label: 'صغير', scale: 0.85),
    FontScaleOption(label: 'متوسط', scale: 0.95),
    FontScaleOption(label: 'عادي', scale: 1.0),
    FontScaleOption(label: 'كبير', scale: 1.15),
    FontScaleOption(label: 'كبير جداً', scale: 1.35),
  ];
}
```

### كيف يعمل بدون ما يأثر على الـ Components؟

**المفتاح:** نستخدم `MediaQuery.textScalerOf()` فقط على النصوص، بينما أبعاد الـ Widgets (أزرار، كروت، أيقونات) تبقى ثابتة لأنها معرّفة بـ `ScreenUtil` وليس بنسب الخط.

```dart
/// في الـ MaterialApp أو أعلى مستوى
class DTTeethApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                // ← هذا يأثر فقط على Text widgets
                textScaler: TextScaler.linear(settings.fontScale),
              ),
              child: child!,
            );
          },
          // ...
        );
      },
    );
  }
}
```

### لماذا هذا الأسلوب وليس تغيير fontSize مباشرة؟

| الأسلوب | المشكلة |
|---------|---------|
| **تغيير fontSize بكل widget** | لازم تعدّل مئات الأماكن — كابوس صيانة |
| **تغيير fontSize بالـ Theme فقط** | الـ Widgets يلي تستخدم أحجام ثابتة ما تتأثر |
| **TextScaler (اختيارنا)** | يؤثر على كل النصوص تلقائياً — الـ Widgets تبقى ثابتة لأن أبعادها معرّفة بـ `ScreenUtil` بوحدات مطلقة وليس نسبية للخط |

### ماذا عن النص الطويل يلي بيطلع من المربع؟

```dart
/// كل Text widget يلي بمكان محدود لازم يكون عنده:
Text(
  'نص طويل جداً',
  overflow: TextOverflow.ellipsis, // ← يقص مع نقاط ...
  maxLines: 2,                     // ← أقصى عدد أسطر
  softWrap: true,                  // ← يلف للسطر التالي
)

/// والـ Container الأب لازم يكون:
Container(
  constraints: BoxConstraints(
    minHeight: 40.h,  // حد أدنى بـ ScreenUtil — ثابت
  ),
  // لا نضع maxHeight ثابت — نترك المحتوى يتمدد عمودياً
  child: Text(...),
)
```

**القاعدة:** استخدم `minHeight` بدل `height` الثابت ← إذا النص كبر، الكارد يتمدد للأسفل بدل ما النص يطلع لبرا.

### حفظ تفضيل المستخدم

```dart
/// يُحفظ محلياً بـ SharedPreferences/SecureStorage
class FontScaleRepository {
  static const _key = 'user_font_scale';
  
  Future<void> save(double scale) async {
    await storage.write(key: _key, value: scale.toString());
  }
  
  Future<double> load() async {
    final value = await storage.read(key: _key);
    return double.tryParse(value ?? '') ?? FontScaleConfig.defaultScale;
  }
}
```

### واجهة الإعدادات

```
┌──────────────────────────────────────────┐
│ 🔤 حجم الخط                              │
│                                          │
│  صغير   متوسط   [عادي]   كبير   كبير جداً│
│   ○       ○       ●       ○       ○      │
│                                          │
│  معاينة: "هذا مثال على حجم الخط الحالي"  │
│                                          │
│  * لا يؤثر على حجم الأزرار والأيقونات    │
└──────────────────────────────────────────┘
```

---

## الجزء الأربعون: التجاوب مع جميع الشاشات (Full Responsive Layout) — القرار 44

### المشكلة

لازم يفتح النظام من الموبايل ويكون قابل للتصفح بدون مشاكل — مش بس الديسكتوب.

### الحل — Responsive Layout بثلاث نقاط قطع (Breakpoints)

```dart
class AppBreakpoints {
  static const double mobile = 600;    // موبايل: < 600px
  static const double tablet = 900;    // تابلت: 600-900px
  static const double desktop = 900;   // ديسكتوب: > 900px
}
```

### استراتيجية التجاوب

```
Desktop (> 900px):
┌──────────┬─────────────────────────────────┐
│ Sidebar  │           المحتوى               │
│ (240px)  │                                 │
│          │    [Stat] [Stat] [Stat] [Stat]  │
│          │                                 │
│          │    ┌─ جدول ──────┐  ┌─ تنبيهات ┐│
│          │    │             │  │          ││
│          │    └─────────────┘  └──────────┘│
└──────────┴─────────────────────────────────┘

Tablet (600-900px):
┌─────────────────────────────────────────┐
│ ☰  DT.Teeth        🔍  🔔  👤          │
├─────────────────────────────────────────┤
│    [Stat] [Stat]    [Stat] [Stat]       │
│                                         │
│    ┌─ جدول ────────────────────────┐    │
│    │                               │    │
│    └───────────────────────────────┘    │
│    ┌─ تنبيهات ─────────────────────┐    │
│    │                               │    │
│    └───────────────────────────────┘    │
└─────────────────────────────────────────┘
← Sidebar = Drawer يفتح بزر ☰

Mobile (< 600px):
┌─────────────────────┐
│ ☰  DT.Teeth    🔔   │
├─────────────────────┤
│   [Stat]  [Stat]    │
│   [Stat]  [Stat]    │
│                     │
│ ┌─ جدول ──────────┐ │
│ │ (scrollable →)  │ │
│ └─────────────────┘ │
│                     │
│ ┌─ تنبيهات ───────┐ │
│ │                 │ │
│ └─────────────────┘ │
└─────────────────────┘
← كل شي عمودي
← الجدول يتمرر أفقياً
← Sidebar = Drawer
```

### التنفيذ بـ Flutter

```dart
/// Widget مشترك يتكيف مع حجم الشاشة
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppBreakpoints.mobile) {
          return mobile;
        } else if (constraints.maxWidth < AppBreakpoints.desktop) {
          return tablet ?? desktop;
        }
        return desktop;
      },
    );
  }
}
```

### قواعد التجاوب

```dart
/// 1. الـ Grid يتكيف
class ResponsiveStatGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // موبايل: 2 أعمدة — تابلت: 3 — ديسكتوب: 4
        final columns = constraints.maxWidth < 600 ? 2 
                       : constraints.maxWidth < 900 ? 3 : 4;
        return GridView.count(
          crossAxisCount: columns,
          children: statCards,
        );
      },
    );
  }
}

/// 2. الـ Sidebar يختفي على الموبايل ويصير Drawer
class AppShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    return Scaffold(
      drawer: isDesktop ? null : const AppDrawer(), // ← Drawer للموبايل
      body: Row(
        children: [
          if (isDesktop) const AppSidebar(), // ← Sidebar للديسكتوب فقط
          Expanded(child: content),
        ],
      ),
    );
  }
}

/// 3. الجداول تتمرر أفقياً على الشاشات الصغيرة
SingleChildScrollView(
  scrollDirection: Axis.horizontal, // ← تمرير أفقي
  child: DataTable(
    columns: [...],
    rows: [...],
  ),
)
```

### لماذا هذه الاستراتيجية؟

| البديل | المشكلة |
|--------|---------|
| **تصميم واحد ثابت** | لا يعمل على الموبايل — النص يتقاطع والأزرار تختفي |
| **تطبيق موبايل منفصل** | كود مكرر وصيانة مضاعفة — نحن مشروع Flutter Web واحد |
| **responsive_framework** | جيد لكن ScreenUtil + LayoutBuilder أخف وأدق وكافي |
| **LayoutBuilder + Breakpoints (اختيارنا)** | تحكم كامل بكل widget — مع ScreenUtil للأبعاد الدقيقة |

### ملاحظة عن flutter_screenutil

```dart
/// في main.dart — التصميم الأساسي بعرض 1440px
ScreenUtilInit(
  designSize: const Size(1440, 900), // أبعاد التصميم الأساسي (ديسكتوب)
  minTextAdapt: true,
  splitScreenMode: true,
  builder: (context, child) => const DTTeethApp(),
);
```

`ScreenUtil` يحول الأبعاد الثابتة تلقائياً — فـ `240.w` للـ Sidebar على شاشة 1440px يصير `120.w` على شاشة 720px. لكن **التخطيط العام** (عمودي vs أفقي، Sidebar vs Drawer) يتم بـ `LayoutBuilder` مع الـ Breakpoints.

---

## ملخص التحديثات — النسخة 5

| القرار | الموضوع | الخلاصة |
|--------|---------|---------|
| #26 | Unit Conversion | وحدات شراء ≠ وحدات صرف (كرتونة ↔ قطعة) |
| #27 | Expiry Tracking | FEFO + تنبيهات متدرجة بالألوان + حظر تلقائي للمنتهية |
| #28 | Double-Handshake | لا صرف بدون طلب رقمي مسبق |
| #29 | Immutable Audit Log | سجل تدقيق لا يُمحى — الصندوق الأسود |
| #30 | Reference Integrity | كل طلب مرتبط بطلبية مريض حقيقي |
| #31 | Reserved Stock | حجز مؤقت يمنع التضارب بين طلبين |
| #32 | Check-in System | تأكيد استلام — المسؤولية تنتقل رسمياً |
| #33 | Reconciliation | تقرير مطابقة يومي — كشف أي فرق بقطعة واحدة |
| **#34** | **Completion Rate** | **نسبة الإنجاز = الطلبات المسلّمة بالوقت ÷ إجمالي المسلّمة** |
| **#35** | **48h Deadline** | **العد يبدأ من "قيد التصنيع" + حالة "معلّق" الجديدة** |
| **#36** | **Performance Scoring** | **تقييم بـ 3 محاور: كمية + سرعة + التزام + حالات توفر المخبري** |
| **#37** | **Satisfaction Rating** | **تقييم 1-5 نجوم من الطبيب بعد كل استلام** |
| **#38** | **Availability Logic** | **فحص مخبر أولاً → مستودع → رفض + حالة "معلّق — بانتظار مواد"** |
| **#39** | **Lab→Warehouse Orders** | **صفحة جديدة بالمخبر لطلب مواد + تأكيد استلام** |
| **#40** | **Smart Stock Alert** | **تنبيه بناءً على معدل الاستهلاك اليومي وليس حد ثابت** |
| **#41** | **Type Distribution** | **تقارير حسب نوع الطلب مع فلتر الفترة** |
| **#42** | **Reactive Filter** | **كل تغيير بالفلتر يحدّث الصفحة فوراً بدون زر** |
| **#43** | **Font Customization** | **تكبير/تصغير الخط من الإعدادات بدون تأثر الـ Components** |
| **#44** | **Full Responsive** | **تجاوب مع موبايل + تابلت + ديسكتوب بـ 3 breakpoints** |

> **آخر تحديث:** أبريل 2026 (النسخة 5)
> **المسؤولة:** غزال — نظام المخبر + المستودع
> **إجمالي القرارات التقنية الموثقة:** 44 قرار
> **إجمالي الأسطر:** ~2,700+ سطر
