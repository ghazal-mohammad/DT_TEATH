# تصميم: إعادة تصميم شاشات Auth — كارت توهج مركزي + حقول underline + زر outline

**التاريخ:** 2026-08-11
**الحالة:** موافَق عليه من المستخدم (بانتظار كتابة خطة التنفيذ)
**المرجع البصري:** `C:\Users\Asus\Desktop\AuthScreen\` (index.html/style.css/style.js) و `AuthPage (2).js` (نسخة React/Tailwind لنفس التصميم)

## الهدف والدافع

مطابقة شاشات Auth (login, email_entry, verify_code, set_password) للتصميم المرجعي المرفق من المستخدم — ليس فقط توقيت الأنيميشن، بل اللغة البصرية الكاملة: كارت محدود بحدود وتوهج في وسط الشاشة، حقول بخط سفلي (underline) بدل الصناديق الممتلئة، وزر بحدود شفافة بدل التعبئة الصلبة. الدافع: طلب المستخدم الصريح لمطابقة كاملة للمرجع، ضمن مشروع تخرّج يُقيَّم على نظافة العمارة وجودة الكود.

## قرارات النطاق المعتمدة (من جلسة الأسئلة التوضيحية)

1. **مطابقة تصميم كاملة** للمرجع (وليس أنيميشن فقط أو دمج جزئي).
2. **مرآة كاملة RTL** — المرجع LTR (أيقونات/تسميات يسار)، والتطبيق عربي RTL، فكل الاتجاهات تُعكس فعلياً (مواضع مطلقة تُقلب، لا الاعتماد على `Directionality` التلقائي وحده حيث يوجد إحداثيات `Positioned` صريحة).
3. **routing منفصل يبقى كما هو** — `/login` و `/auth/email` صفحتان منفصلتان بالراوتر (رفض دمجهما بـ widget واحد بحالة محلية toggle).
4. **كارت محدود + توهج وسط الشاشة** (max-width) بدل التصميم الحالي full-bleed للشاشة كاملة.
5. **النطاق التنفيذي:** أربع صفحات auth (login, email_entry, verify_code, set_password) — تُنفَّذ صفحة صفحة بالترتيب: login → email_entry → verify_code → set_password، مع تحقق بصري (screenshot) بعد كل صفحة قبل الانتقال للتالية.

## المعمارية

### ملفات جديدة
- `lib/features/auth/presentation/widgets/auth_underline_field.dart` — حقل خط سفلي + label عائم، يُعيد استخدام منطق اقتراحات نطاقات البريد الموجود حالياً في `email_form_field.dart` (نفس `_commonDomains`، نفس آلية الـ dropdown) لكن بغلاف بصري مختلف بالكامل.
- `lib/features/auth/presentation/widgets/auth_outline_button.dart` — زر بحدود شفافة (بديل بصري لـ `auth_submit_button.dart`)، يحافظ على منطق الـ pulse الموجود (`withPulseAnimation`, `_pulseCtrl` 2400ms) ويضيف hover-sweep (ديسكتوب فقط، عبر `MouseRegion`).

### ملفات معدَّلة
- `auth_flow_shell.dart` — يُعاد هيكلته: المحتوى يُلَف بـ `Center` + `ConstrainedBox(maxWidth: 1000, maxHeight: 580)` بدل `Positioned.fill` الحالي على كامل الشاشة. الخلفية القطرية الدوّارة (`AuthRotatingBackground`) والتوهج (`AuthGlowLinePainter`) يُحسبان بالنسبة لأبعاد الكارت لا الشاشة.
- `login_page.dart`, `email_entry_page.dart`, `verify_code_page.dart`, `set_password_page.dart` — تستبدل `EmailFormField`/`AuthSubmitButton` بـ `AuthUnderlineField`/`AuthOutlineButton`؛ تتموضع جوا حدود الكارت الجديد بدل الشاشة الكاملة؛ مواضع `Positioned` المطلقة (branding يسار/فورم يمين) تُعكس فعلياً بالوضع RTL بدل البقاء بترتيب LTR-style.

### يبقى بلا تغيير
- `route_names.dart` وكل الروابط (`/login`, `/auth/email`, إلخ).
- كل الـ Cubits (`login_cubit.dart` وغيرها) — منطق العمل لا يتأثر.
- `auth_entry_animator.dart` و `AuthStaggerDelays` — نفس قيم التوقيت (logo 0-0.35 … button 0.50-0.78)، فقط `slideOffset` يصير مُشارًا بإشارة معكوسة بوضع RTL: `Offset(isRtl ? -60 : 60, 0)` بدل ثابت.
- `auth_flow_transition.dart` (انتقال الصفحات، 900ms/760ms) — لا يُمس؛ مضبوط ومُختبر أداءً حالياً.
- `AuthCardGlowBorder` (من `auth_page_transition.dart`) — يُعاد استخدامه كما هو (نفس pulse 2800ms) لتوهج الكارت، فقط يُغلَّف الآن بـ `Center`+`ConstrainedBox` بدل التطبيق على شاشة كاملة كما في `system_selection_page.dart` حالياً.

## تفاصيل بصرية

### الكارت والخلفية
- الحاوية: `Center` → `ConstrainedBox(maxWidth: 1000, maxHeight: 580)`، مع `margin` أدنى 24px للشاشات الأضيق من ~1048px.
- الحدود: `border: 2px solid AppColors.accent` (إعادة استخدام لون النظام الحالي بدل قيمة خام `#00d4ff` من المرجع).
- `borderRadius: 12` (بدل الزوايا الحادة تماماً بالمرجع؛ تُبقي الطابع البصري بدون قسوة).
- الخلفية الداخلية (لوحة بيضاء مائلة + خط توهج) تُبنى بنفس `AuthShapeBackground`/`AuthGlowLinePainter` الحاليين، محسوبة بأبعاد الكارت.
- RTL: الفورم (الأبيض) يسار، الـ branding (الكحلي/الشعار) يمين — معكوس عن ترتيب `login_page.dart` الحالي.
- الموبايل (<750px): يبقى بلا حدود/توهج، full-width، كما هو حالياً — يطابق سلوك المرجع نفسه الذي يُسقط الأشكال القطرية عالموبايل.

### الحقول (`AuthUnderlineField`)
- بلا خلفية معبأة؛ خط سفلي 1.5px عادي → 2px `AppColors.accent` عند التركيز، بنفس مدة/منحنى `AnimatedContainer` الموجودين حالياً.
- Label عائم: ينزلق لأعلى ويصغر عند التركيز/وجود نص، عبر `AnimatedAlign` + `AnimatedDefaultTextStyle` (بلا حزمة خارجية).
- الأيقونة (`@` أو قفل) بجهة اليمين بوضع RTL (بدل يسار بالمرجع الأصلي LTR).
- اقتراحات نطاقات البريد: نفس الآلية الحالية (`_commonDomains`, `_SuggestionTile`) بلا تغيير منطقي، فقط تتموضع تحت الخط السفلي الجديد.
- الخطأ: الخط السفلي يتحول لـ `AppColors.error` + نص خطأ صغير تحته، بدل تلوين صندوق كامل.
- زر مسح النص (X): يبقى موجودًا، يتموضع يسار الحقل (جنب label) بعد ما صارت الأيقونة يمين.

### الزر (`AuthOutlineButton`)
- خلفية شفافة، حدود 2px `AppColors.accent`، نص بنفس اللون؛ شكل pill بنفس نصف قطر أزرار النظام الحالي.
- Hover (ديسكتوب فقط، `MouseRegion`): تعبئة متدرّجة تزحف من اليمين لليسار (معكوس RTL عن المرجع)، مدة 200-250ms `Curves.easeOut`، بلا `ImageFilter.blur`.
- الموبايل/اللمس: بلا hover، الزر بحالته العادية دائمًا (سلوك متوقع، لا حاجة لبديل).
- Pulse الموجود (`withPulseAnimation`, 2400ms) يبقى خاصية مستقلة فوق النمط الجديد — التمايز الحالي بين الصفحات (email/verify/setPassword مع pulse، login بدونه) يبقى كما هو.
- حالة `isLoading`: نفس spinner الحالي فوق الخلفية الشفافة الجديدة.

## التوقيتات والحركة

- `AuthStaggerDelays` (entry stagger): بلا تغيير بالقيم؛ فقط `slideOffset` بإشارة معكوسة بوضع RTL.
- `AuthFlowShell` rotation: يبقى `1500ms` / `Curves.ease`؛ فقط نطاق الحركة يُحسب بالنسبة لأبعاد الكارت (1000×580) بدل الشاشة، فتصغر الحركة تلقائيًا لتطابق حجم المرجع الفعلي.
- انتقال الصفحات (`auth_flow_transition.dart`): بلا تغيير (900ms/760ms).
- Hover-sweep الزر: 200-250ms `Curves.easeOut`.

## قيد أداء صريح

لا استخدام لـ `ImageFilter.blur` في أي عنصر جديد (الزر، الحقل). التوهجات الجديدة (الكارت، الخط) تُبنى فقط عبر `BoxShadow`/`CustomPainter`، بنفس نمط الكود الحالي. هذا القيد مبني على تجربة موثّقة في `auth_flow_transition.dart`: محاولة سابقة استخدمت `ImageFilter.blur` + أشكال قطرية دوّارة ضخمة + skew، وسبّبت jank ملحوظ، وتم التراجع عنها عمدًا لصالح نسخة خفيفة تعتمد transform/opacity فقط.

## خطة التنفيذ (تسلسل الصفحات)

1. `login_page.dart` — أول صفحة، تُبنى فيها كل المكوّنات الجديدة (`AuthUnderlineField`, `AuthOutlineButton`, الكارت المعاد هيكلته في `auth_flow_shell.dart`). تحقق بصري (screenshot عبر `run-dt-teeth` skill) قبل المتابعة.
2. `email_entry_page.dart` — إعادة استخدام نفس المكونات.
3. `verify_code_page.dart`.
4. `set_password_page.dart`.

كل صفحة تُبنى، تُشغَّل عبر `run-dt-teeth` (PowerShell، ليس Git Bash — راجع ملاحظة التوجيه أدناه)، وتُقارن سكرين شوت بالمرجع قبل الانتقال للصفحة التالية.

## ملاحظة تشغيلية

سكربت `run-dt-teeth` (`.claude/skills/run-dt-teeth/driver.mjs`) يجب أن يُشغَّل من PowerShell وليس Git Bash — Git Bash/MSYS يحوّل مسارات الراوت التي تبدأ بـ `/` (مثل `/auth/email`) إلى مسارات Windows، مما يفسد الروابط.

## خارج النطاق

- لا تعديل على أي منطق عمل (Cubits، Repositories، API contracts).
- لا تعديل على `route_names.dart` أو آلية الراوتينج نفسها.
- لا استخدام حزم خارجية جديدة لأي من العناصر البصرية (label عائم، gradient sweep) — كل شيء يُبنى بأدوات Flutter الأساسية، اتساقًا مع بقية المشروع (بلا حزم طرف-ثالث لأشياء يمكن بناؤها يدويًا).
