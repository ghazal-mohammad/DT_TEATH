// ════════════════════════════════════════════════════════════════════════════
// app_system_type.dart
//
// تعداد يمثّل الأنظمة الفرعية في DT.Teeth (المخبر / المستودع).
// يُستخدم في كل الـ widgets اللي لازم تتكيّف مع نظام معيّن — زي:
//   - AppSidebar (يغيّر ألوان الـ active state والـ badge)
//   - AppSidebarItem (لون الـ .on state يختلف بين lab و warehouse)
//   - AppSidebarSystemBadge (خلفية وحدود الشارة)
//
// المرجع البصري: CSS variables في HTML الأصلي:
//   - .sys-badge.lab  → rgba(237,139,250,...)  (بنفسجي)
//   - .sys-badge.wh   → rgba(249,115,22,...)   (برتقالي)
//   - .ni.on (lab)    → rgba(237,139,250,...)  على اللايت
//   - .ni.on (wh)     → rgba(125,211,252,...)  (سماوي في Warehouse)
//
// ملاحظة تصميمية: رغم إن الـ HTML عنده Lab=بنفسجي، فإنه داخل الـ Warehouse HTML
// الـ .ni.on يستخدم سماوي مختلف (125,211,252). نحن نوحّد الهوية بحيث يستخدم
// كل نظام لونه الأساسي المعرّف في app_colors.dart:
//   - lab       → AppColors.labSystem       (#ED8BFA وردي/بنفسجي)
//   - warehouse → AppColors.warehouseSystem (#9EFBEC سماوي)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';

/// نوع النظام الفرعي في DT.Teeth.
///
/// كل نظام له هوية بصرية خاصة (ألوان + أيقونة + اسم) تنعكس في:
/// - ألوان الشارات والـ active state في السايدبار
/// - عنوان الصفحة في التوب بار
/// - رسالة الترحيب
enum AppSystemType {
  /// نظام المخبر — المسؤول عن تصنيع أطقم الأسنان والتركيبات.
  /// اللون المميّز: وردي/بنفسجي (#ED8BFA).
  lab,

  /// نظام المستودع — المسؤول عن إدارة المواد والطلبيات والفواتير.
  /// اللون المميّز: سماوي (#9EFBEC).
  warehouse,
}

/// Extension تضيف خصائص مفيدة لكل نظام — ألوان، اسم، أيقونة...
extension AppSystemTypeX on AppSystemType {
  /// اللون الأساسي للنظام (يُستخدم للـ active state والـ accent).
  Color get primaryColor {
    switch (this) {
      case AppSystemType.lab:
        return AppColors.labSystem; // #ED8BFA
      case AppSystemType.warehouse:
        return AppColors.warehouseSystem; // #9EFBEC
    }
  }

  /// خلفية شارة النظام (.sys-badge) — شفّافة.
  /// من CSS: `.sys-badge.lab { background:rgba(237,139,250,0.08) }`
  /// من CSS: `.sys-badge.wh  { background:rgba(249,115,22,0.08) }`
  /// ملاحظة: في تطبيقنا نستخدم primaryColor بشفافية 0.08 لتوحيد الهوية.
  Color get badgeBgColor {
    return primaryColor.withValues(alpha: 0.08);
  }

  /// حدود شارة النظام.
  /// من CSS: `border:1px solid rgba(237,139,250,0.2)` للمخبر.
  Color get badgeBorderColor {
    return primaryColor.withValues(alpha: 0.2);
  }

  /// لون نص الشارة — نفس primaryColor.
  Color get badgeTextColor => primaryColor;

  /// لون الـ active state في الـ sidebar items.
  /// في Warehouse HTML: `.ni.on { color:var(--cyan-b); background:linear-gradient(90deg,rgba(125,211,252,0.1),rgba(125,211,252,0.02)) }`
  /// في Lab HTML:       نفس السلوك لكن بلون مختلف.
  /// هنا نستخدم primaryColor كلون الـ active.
  Color get activeColor => primaryColor;

  /// خلفية الـ active state في السايدبار (gradient).
  /// من CSS: `background:linear-gradient(90deg, rgba(cyan, 0.15), rgba(cyan, 0.03))`
  List<Color> get activeGradient {
    return [
      primaryColor.withValues(alpha: 0.15),
      primaryColor.withValues(alpha: 0.03),
    ];
  }

  /// النص المختصر المعروض في الـ sidebar badge (مترجم).
  String shortLabel(BuildContext context) {
    switch (this) {
      case AppSystemType.lab:
        return context.l10n.labSystemBadge;
      case AppSystemType.warehouse:
        return context.l10n.warehouseSystemBadge;
    }
  }

  /// أيقونة النظام.
  IconData get icon {
    switch (this) {
      case AppSystemType.lab:
        return AppIcons.tooth;
      case AppSystemType.warehouse:
        return AppIcons.box;
    }
  }


  /// النظام الثاني (للتبديل).
  AppSystemType get other {
    switch (this) {
      case AppSystemType.lab:
        return AppSystemType.warehouse;
      case AppSystemType.warehouse:
        return AppSystemType.lab;
    }
  }
}
