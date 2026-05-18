# DT.Teeth — Feature 2 Changelog

## Phase 2.3 + 2.4 — Shared Widgets Library

**التاريخ:** هذه المحادثة (أبريل 2026)  
**المصدر البصري:** `DT_Teeth_Lab_v12_Enhanced.html`

---

## ✅ المضاف

### Phase 2.3 — Primitives (7 widgets)
| الملف | المصدر في HTML (السطر) | الوصف |
|---|---|---|
| `primitives/app_badge.dart` | 757–767 | شارة + 5 variants + pulse animation |
| `primitives/app_button.dart` | 769–776 | زر + 3 variants + 2 sizes + loading |
| `primitives/app_icon_button.dart` | 778–789 | زر أيقونة 32×32 + 4 variants |
| `primitives/app_filter_chip.dart` | 791–803 | شريحة تصفية + AppFilterChipRow |
| `primitives/app_card.dart` | 656–681 | بطاقة glass morphism + header |
| `primitives/app_stat_card.dart` | 685–739 | KPI Card + 5 variants + countUp |
| `primitives/app_progress_bar.dart` | 824–826 | شريط تقدم + 5 variants |

### Phase 2.4 — Composites (6 widgets)
| الملف | المصدر في HTML (السطر) | الوصف |
|---|---|---|
| `forms/app_form_field.dart` | 805–814 | حقل نص + validation + direction auto |
| `forms/app_form_select.dart` | 815–820 | قائمة منسدلة |
| `forms/app_form_grid.dart` | 821–822 | Grid 2/3 أعمدة + responsive |
| `data/app_data_table.dart` | 741–755 | جدول + sorting + loading + empty |
| `feedback/app_alert_box.dart` | 828–860 | صندوق تنبيه + shimmer + pulse |
| `layout/app_dashboard_hero.dart` | 1547–1605 | Hero banner + stats + dividers |

### ملفات مساعدة
- `shared_widgets.dart` — Barrel export للاستيراد الموحد
- `README.md` — دليل المعمارية والاستخدام
- `_legacy_phase_2_3/` — أرشيف النسخ السابقة (يمكن حذفها)

---

## 📊 الإحصائيات

- **إجمالي الأسطر:** ~3,350 سطر Dart
- **عدد الـ widgets:** 13
- **Breakpoints responsive:** 3 (560/600/900 px)
- **Animations مطابقة لـ CSS:** 5 (alertPulse, countUp, shimmer, transition, cubic-bezier)
- **التوثيق:** Dartdoc كاملة (/// على كل parameter و class)
- **Light/Dark mode:** مدعوم تلقائياً في كل widget

---

## 🎯 قواعد معيارية مطبّقة

1. **لا `withOpacity()`** — استخدمنا `withValues(alpha:)` (API الجديد في Flutter 3.27+)
2. **لا `Container` عشوائية** للـ badges/buttons
3. **RTL افتراضي** — لا `left/right`، بل `horizontal/vertical`
4. **`const` حيث ممكن** لتحسين الأداء
5. **Dartdoc** على كل `public` widget/parameter
6. **مرجع HTML في الـ header** لكل ملف — للمطوّر اللاحق

---

## 🔜 المتبقي في Feature 2

### Phase 2.5 (محادثة تالية)
- [ ] Sidebar (نظام التنقل الجانبي)
- [ ] Topbar (شريط علوي مع search + notifications)
- [ ] Empty states (illustrations للشاشات الفارغة)
- [ ] Shimmer loaders (skeleton screens)

### Phase 2.6 (محادثة تالية)
- [ ] `widgets_showcase.dart` — صفحة Demo لكل widget
- [ ] `flutter analyze` + إصلاح أي تحذير
- [ ] Golden tests لكل widget
- [ ] ZIP نهائي مع تقرير verification شامل
