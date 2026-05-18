// ════════════════════════════════════════════════════════════════════════════
// app_icons.dart
//
// أيقونات موحدة للمشروع.
// القرار 10: استخدام مكتبة iconsax_flutter.
//
// قاعدة الاستخدام:
//   - ممنوع استخدام Icons.xxx مباشرة في الشاشات.
//   - كل أيقونة تأخذ اسم واضح بالعربي يوضح دورها.
//   - إذا احتجت أيقونة جديدة، أضفها هنا بالاسم المناسب.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppIcons {
  AppIcons._();

  // ── التنقل الرئيسي (Sidebar) ────────────────────────────────────────────
  static const IconData dashboard = Iconsax.chart_2_copy;
  static const IconData materials = Iconsax.box_copy;
  static const IconData orders = Iconsax.sms_notification_copy;
  static const IconData invoices = Iconsax.receipt_2_copy;
  static const IconData reports = Iconsax.chart_3_copy;
  static const IconData notifications = Iconsax.notification_copy;
  static const IconData settings = Iconsax.setting_2_copy;
  static const IconData technicians = Iconsax.people_copy;
  static const IconData labOrders = Iconsax.hierarchy_square_copy;

  // ── Topbar ──────────────────────────────────────────────────────────────
  static const IconData search = Iconsax.search_normal_copy;
  static const IconData bell = Iconsax.notification_copy;
  static const IconData profile = Iconsax.user_copy;
  static const IconData logout = Iconsax.logout_copy;
  static const IconData menu = Iconsax.element_3_copy;
  static const IconData switchSystem = Iconsax.convert_card_copy;

  // ── الثيم ───────────────────────────────────────────────────────────────
  static const IconData darkMode = Iconsax.moon_copy;
  static const IconData lightMode = Iconsax.sun_1_copy;

  // ── الإجراءات العامة ────────────────────────────────────────────────────
  static const IconData add = Iconsax.add_copy;
  static const IconData edit = Iconsax.edit_2_copy;
  static const IconData delete = Iconsax.trash_copy;
  static const IconData save = Iconsax.save_2_copy;
  static const IconData cancel = Iconsax.close_circle_copy;
  static const IconData back = Iconsax.arrow_right_copy; // RTL = رجوع لليمين
  static const IconData forward = Iconsax.arrow_left_copy;
  static const IconData close = Iconsax.close_square_copy;
  static const IconData check = Iconsax.tick_circle_copy;
  static const IconData filter = Iconsax.filter_copy;
  static const IconData sort = Iconsax.sort_copy;
  static const IconData download = Iconsax.document_download_copy;
  static const IconData upload = Iconsax.document_upload_copy;
  static const IconData print = Iconsax.printer_copy;
  static const IconData export = Iconsax.export_1_copy;
  static const IconData refresh = Iconsax.refresh_copy;

  // ── الحالات ─────────────────────────────────────────────────────────────
  static const IconData success = Iconsax.tick_circle_copy;
  static const IconData warning = Iconsax.warning_2_copy;
  static const IconData error = Iconsax.close_circle_copy;
  static const IconData info = Iconsax.info_circle_copy;

  // ── المخبر والمستودع ───────────────────────────────────────────────────
  static const IconData tooth = Iconsax.health_copy;
  static const IconData box = Iconsax.box_1_copy;

  // ── أيقونات نظام العيادة (Clinic/Doctor) ─────────────────────────────
  static const IconData patients = Iconsax.people_copy;
  static const IconData appointments = Iconsax.calendar_copy;
  static const IconData employees = Iconsax.profile_2user_copy;
  static const IconData inventoryOps = Iconsax.box_copy;
  static const IconData doctors = Iconsax.user_copy;
  static const IconData supplier = Iconsax.truck_copy;
  static const IconData calendar = Iconsax.calendar_1_copy;
  static const IconData clock = Iconsax.clock_copy;
  static const IconData money = Iconsax.dollar_circle_copy;
  static const IconData chart = Iconsax.chart_copy;
  static const IconData stats = Iconsax.status_up_copy;

  // ── أدوات إضافية ────────────────────────────────────────────────────────
  static const IconData eye = Iconsax.eye_copy;
  static const IconData eyeSlash = Iconsax.eye_slash_copy;
  static const IconData lock = Iconsax.lock_copy;
  static const IconData unlock = Iconsax.unlock_copy;
  static const IconData more = Iconsax.more_copy;
  static const IconData star = Iconsax.star_1_copy;
  static const IconData starFill = Iconsax.star_copy;

  // ── أيقونات ميزات ذكية ─────────────────────────────────────────────────
  static const IconData auditLog = Iconsax.document_text_copy; // القرار 21
  static const IconData wastage = Iconsax.trash_copy; // القرار 22
  static const IconData urgent = Iconsax.flash_1_copy; // القرار 23 أولوية الكرسي
  static const IconData expiry = Iconsax.calendar_remove_copy; // القرار 27
  static const IconData lowStock = Iconsax.warning_2_copy; // القرار 40

  // ── Phase 2.5 — أيقونات Empty States ───────────────────────────────────
  static const IconData emptyBox = Iconsax.box_copy;
  static const IconData emptyInbox = Iconsax.sms_notification_copy;
  static const IconData emptySearch = Iconsax.search_status_copy;
  static const IconData emptyDocument = Iconsax.document_copy;
  static const IconData emptyClock = Iconsax.clock_copy;
  static const IconData emptyError = Iconsax.danger_copy;

  // ── Phase 2.5 — أيقونات التنقل الإضافية ────────────────────────────────
  static const IconData arrowForward = Iconsax.arrow_left_2_copy; // RTL
  static const IconData arrowBack = Iconsax.arrow_right_2_copy; // RTL
  static const IconData chevronDown = Iconsax.arrow_down_1_copy;
  static const IconData chevronUp = Iconsax.arrow_up_1_copy;

  // ── Phase 5.x — أيقونات الملف الشخصي وطلبات المواد ──────────────────────
  // ملاحظة: lock, star, chart, eye, materials موجودين سابقاً
  static const IconData email = Iconsax.sms_copy;
  static const IconData phone = Iconsax.call_copy;
}
