# Shared Widgets — مكتبة المكوّنات الموحّدة

> **قاعدة الذهب:** أي مكوّن يُعاد استخدامه في أكثر من شاشة واحدة يجب أن يكون هنا.  
> لا يُسمح ببناء `Container` مخصّص في شاشة لمحاكاة badge/button/card موجود هنا.

---

## 📁 الهيكلة

```
shared/widgets/
├── shared_widgets.dart      ← Barrel export (استخدمه دائماً)
│
├── primitives/              ← اللبنات الأساسية (ذرّات)
│   ├── app_badge.dart       ← شارة حالة + 5 variants
│   ├── app_button.dart      ← زر + 3 variants (primary/secondary/danger)
│   ├── app_card.dart        ← بطاقة glass morphism + header اختياري
│   ├── app_filter_chip.dart ← شريحة تصفية قابلة للتبديل
│   ├── app_icon_button.dart ← زر أيقونة 32x32 + 4 variants
│   ├── app_progress_bar.dart← شريط تقدم 4px + 5 variants
│   └── app_stat_card.dart   ← بطاقة KPI + 5 variants
│
├── forms/                   ← حقول النماذج
│   ├── app_form_field.dart  ← حقل نص + label + validation
│   ├── app_form_select.dart ← قائمة منسدلة
│   └── app_form_grid.dart   ← تخطيط شبكي 2/3 أعمدة (responsive)
│
├── data/                    ← عرض البيانات
│   └── app_data_table.dart  ← جدول + sorting + loading + empty
│
├── feedback/                ← تنبيهات للمستخدم
│   └── app_alert_box.dart   ← صندوق تنبيه (danger/warning) + shimmer
│
└── layout/                  ← مكوّنات التخطيط الكبيرة
    └── app_dashboard_hero.dart ← hero banner للداشبورد
```

---

## 🎯 كيف تستخدم

### الاستيراد الموحّد
```dart
import 'package:dt_teeth/shared/widgets/shared_widgets.dart';
```

هذا يمنحك وصولاً إلى كل المكوّنات بدون استيرادات متعدّدة.

### مثال شامل — شاشة مستودع
```dart
class WarehouseDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero banner
        AppDashboardHero(
          title: 'مرحباً، أحمد',
          subtitle: 'لديك 3 تنبيهات جديدة',
          stats: [
            AppDashboardHeroStat(value: '247', label: 'مادة'),
            AppDashboardHeroStat(value: '12', label: 'طلب جديد'),
          ],
        ),

        // KPI Grid
        AppStatGrid(children: [
          AppStatCard(
            icon: Icons.inventory_2,
            value: '247',
            label: 'عدد المواد',
            variant: AppStatCardVariant.cyan,
          ),
          AppStatCard(
            icon: Icons.warning,
            value: '5',
            label: 'مواد حرجة',
            variant: AppStatCardVariant.red,
            trend: AppStatTrend.up,
            trendLabel: '+2',
          ),
        ]),

        // Alert Box
        AppAlertBox(
          variant: AppAlertBoxVariant.danger,
          icon: Icons.error,
          title: 'مخزون حرج',
          items: [
            AppAlertBoxItem(text: 'قفازات L', value: '3 قطع'),
            AppAlertBoxItem(text: 'كمامات', value: 'نفذت'),
          ],
        ),

        // Data Table داخل Card
        AppCard(
          header: AppCardHeader(
            title: 'المواد',
            badge: '247',
            actionLabel: 'عرض الكل',
            onActionTap: () {},
          ),
          child: AppDataTable<Material>(
            data: materials,
            columns: [
              AppDataColumn(
                label: 'المادة',
                flex: 3,
                sortable: true,
                sortValue: (m) => m.name,
                cellBuilder: (m) => Text(m.name),
              ),
              AppDataColumn(
                label: 'الحالة',
                width: 120,
                cellBuilder: (m) => AppBadge(
                  text: m.statusLabel,
                  variant: m.isCritical
                      ? AppBadgeVariant.redAnimated
                      : AppBadgeVariant.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## 🧬 مبادئ التصميم

### 1. Pixel-Perfect مع HTML المرجع
كل widget يحتوي في رأس الملف على CSS الأصلي من `DT_Teeth_Lab_v12_Enhanced.html`
مع رقم السطر بالضبط. أي تعديل يجب أن يبقى مطابقاً.

### 2. Light/Dark Mode تلقائي
لا تمرّر ألواناً يدوياً. كل widget يكتشف الـ theme من `Theme.of(context).brightness`.

### 3. RTL افتراضياً
كل النصوص محاذاة يميناً. المسافات تستخدم `horizontal/vertical` (ليس left/right).

### 4. Validation + Error states في الـ Forms
`AppFormField` يدعم:
- `required: true` → نجمة حمراء بعد الـ label
- `validator: (v) => ...` → رسالة خطأ أسفل الحقل + إطار أحمر

### 5. Hover + Animations مطابقة لـ CSS
كل tap/hover يطابق الـ transition في HTML:
- `transition:all 0.2s` → `Duration(milliseconds: 200)`
- `cubic-bezier(0.34,1.4,0.64,1)` → `Cubic(0.34, 1.4, 0.64, 1)`

---

## ⚠️ تحذيرات للمطوّرين

### ❌ لا تفعل
```dart
// خطأ: إعادة بناء badge من الصفر
Container(
  padding: EdgeInsets.all(4),
  decoration: BoxDecoration(color: Colors.green, ...),
  child: Text('مكتمل'),
)
```

### ✅ افعل
```dart
AppBadge(text: 'مكتمل', variant: AppBadgeVariant.green)
```

### ❌ لا تستورد ملفات فردية
```dart
import 'package:dt_teeth/shared/widgets/primitives/app_badge.dart';
```

### ✅ استخدم الـ barrel
```dart
import 'package:dt_teeth/shared/widgets/shared_widgets.dart';
```

---

## 🗂️ المراحل المُنجزة

- ✅ **Phase 2.3** — Primitives (Badge, Button, Card, StatCard, IconButton, FilterChip, ProgressBar)
- ✅ **Phase 2.4** — Composites (FormField, FormSelect, FormGrid, DataTable, AlertBox, DashboardHero)
- 🔜 **Phase 2.5** — Sidebar, Topbar, Empty States, Shimmer
- 🔜 **Phase 2.6** — Verification Phase + showcase

---

## 📂 أرشيف `_legacy_phase_2_3/`

في جذر المشروع مجلد `_legacy_phase_2_3/` يحتوي على الإصدار السابق من نفس المكوّنات
(بهيكلة مختلفة: `badges/`, `buttons/`, `cards/`, إلخ). **هذا المجلد للمرجعية فقط**
ويُستبعد من الـ build. يمكن حذفه بأمان بعد التحقّق من المكوّنات الجديدة.

---

## 🔗 المرجع البصري

- `DT_Teeth_Lab_v12_Enhanced.html` — شاشات المخبر (اللون: وردي/بنفسجي)
- `DT_Teeth_Warehouse_v6_Enhanced.html` — شاشات المستودع (اللون: سماوي/أزرق)

كلاهما يستخدم نفس مكتبة الـ widgets مع تبديل الـ theme colors فقط.
