// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_mock_data.dart
//
// بيانات وهمية لجداول Dashboard المستودع (مواد أكثر طلباً + مواد ستنتهي).
//
// 🎯 الهدف:
//   في غياب backend، نوفّر بيانات ثابتة مطابقة للـ HTML mockup للحفاظ على
//   التطابق البصري الكامل. هذه البيانات ستُستبدل بـ Bloc states في Phase 6.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2152–2158 + 2161
//
// 🔮 خطّة الانتقال:
//   - Phase 6: استبدال بـ WarehouseRepository.getTopRequested() / getExpiring()
//   - الواجهة لن تتغيّر — فقط مصدر البيانات.
// ════════════════════════════════════════════════════════════════════════════

import '../../presentation/widgets/dashboard/warehouse_table_badge.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          DATA CLASSES
// ══════════════════════════════════════════════════════════════════════════

/// عنصر في جدول "المواد الأكثر طلباً".
class TopRequestedMaterial {
  const TopRequestedMaterial({
    required this.name,
    required this.category,
    required this.categoryVariant,
    required this.requestCount,
    required this.quantity,
    required this.statusVariant,
    required this.statusKey,
  });

  /// اسم المادة (مثل "قفازات لاتكس M").
  final String name;

  /// فئة المادة (مثل "مستهلكات").
  final String category;

  /// نوع badge الفئة.
  final WarehouseBadgeVariant categoryVariant;

  /// عدد الطلبات (مثل 34).
  final int requestCount;

  /// الكمية المتبقّية (مثل "340 قطعة").
  final String quantity;

  /// نوع badge الحالة (متوفر/ينفد/نفد).
  final WarehouseBadgeVariant statusVariant;

  /// مفتاح l10n للحالة (مثل 'whStatusAvailable').
  final String statusKey;
}

/// عنصر في جدول "مواد ستنتهي صلاحيتها".
class ExpiringMaterial {
  const ExpiringMaterial({
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.daysLeft,
  });

  final String name;
  final String quantity;
  final String expiryDate;
  final int daysLeft;
}

// ══════════════════════════════════════════════════════════════════════════
//                          MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

/// بيانات وهمية لـ Dashboard المستودع (Phase 4.2).
class WarehouseDashboardMockData {
  WarehouseDashboardMockData._();

  /// المواد الأكثر طلباً — 5 صفوف مطابقة للـ HTML.
  ///
  /// ملاحظة: الأسماء بالعربي ثابتة هنا لأنها بيانات تجريبية تمثّل أسماء حقيقية
  /// لمواد طبية. في الإنتاج، تأتي من API بناءً على لغة المستخدم.
  static const List<TopRequestedMaterial> topRequested = [
    TopRequestedMaterial(
      name: 'قفازات لاتكس M',
      category: 'مستهلكات',
      categoryVariant: WarehouseBadgeVariant.cyan,
      requestCount: 34,
      quantity: '340 قطعة',
      statusVariant: WarehouseBadgeVariant.green,
      statusKey: 'whStatusAvailable',
    ),
    TopRequestedMaterial(
      name: 'حقن بنج موضعي',
      category: 'أدوية',
      categoryVariant: WarehouseBadgeVariant.violet,
      requestCount: 28,
      quantity: '56 حقنة',
      statusVariant: WarehouseBadgeVariant.orange,
      statusKey: 'whStatusLow',
    ),
    TopRequestedMaterial(
      name: 'خيط خياطة 3/0',
      category: 'مستهلكات',
      categoryVariant: WarehouseBadgeVariant.cyan,
      requestCount: 22,
      quantity: '44 بكرة',
      statusVariant: WarehouseBadgeVariant.green,
      statusKey: 'whStatusAvailable',
    ),
    TopRequestedMaterial(
      name: 'أكواب بلاستيكية',
      category: 'مستهلكات',
      categoryVariant: WarehouseBadgeVariant.cyan,
      requestCount: 19,
      quantity: '950 كوب',
      statusVariant: WarehouseBadgeVariant.red,
      statusKey: 'whStatusOut',
    ),
    TopRequestedMaterial(
      name: 'سيليكون طبع',
      category: 'مواد طبية',
      categoryVariant: WarehouseBadgeVariant.violet,
      requestCount: 15,
      quantity: '15 كيلو',
      statusVariant: WarehouseBadgeVariant.green,
      statusKey: 'whStatusAvailable',
    ),
  ];

  /// مواد ستنتهي صلاحيتها قريباً (مرجع HTML بسيط).
  static const List<ExpiringMaterial> expiring = [
    ExpiringMaterial(
      name: 'حقن بنج موضعي',
      quantity: '56 حقنة',
      expiryDate: '2026-05-20',
      daysLeft: 18,
    ),
    ExpiringMaterial(
      name: 'مرهم تخدير سطحي',
      quantity: '12 أنبوب',
      expiryDate: '2026-05-25',
      daysLeft: 23,
    ),
    ExpiringMaterial(
      name: 'محلول تطهير',
      quantity: '8 لتر',
      expiryDate: '2026-06-01',
      daysLeft: 30,
    ),
  ];

  // ── إحصائيات Hero ──────────────────────────────────────────────────
  static const int registeredCount = 247;
  static const int pendingOrdersCount = 3;
  static const int activeAlertsCount = 8;

  // ── إحصائيات Stat Cards ────────────────────────────────────────────
  static const int currentInventoryCount = 247;
  static const int lowStockCount = 8;
  static const int incomingOrdersCount = 3;
  static const int expiringCount = 6;

  // ── Alert Box: نفاد مخزون (3 عناصر) ────────────────────────────────
  /// أسماء المواد بالعربي ثابتة هنا لأنها بيانات mock تمثّل أسماء حقيقية.
  /// في الإنتاج تأتي من API بناءً على لغة المستخدم.
  static const List<MockAlertItem> lowStockAlertItems = [
    MockAlertItem(text: 'أكواب بلاستيكية', value: '12'),
    MockAlertItem(text: 'حقن بنج', value: '5'),
    MockAlertItem(text: 'ماسكات', value: '8'),
  ];

  // ── Alert Box: طلبيات جديدة (2 عناصر، الـ value يأتي من l10n) ──────
  static const List<MockAlertItem> newOrderAlertItems = [
    MockAlertItem(text: 'قفازات × 100', value: ''),
    MockAlertItem(text: 'جبص × 5', value: ''),
  ];
}

/// عنصر بسيط للـ Alert Box mock data.
class MockAlertItem {
  const MockAlertItem({required this.text, required this.value});

  final String text;
  final String value;
}
