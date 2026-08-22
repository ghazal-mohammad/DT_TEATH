// ════════════════════════════════════════════════════════════════════════════
// warehouse_pages_mock_data.dart
//
// بيانات وهمية لصفحات: الطلبيات، الفواتير، التقارير، الإشعارات.
//
// 🎯 الهدف:
//   توفير بيانات ثابتة تطابق HTML mockup تماماً لكل الصفحات المتبقّية.
//   في Phase 6، هذه البيانات تُستبدل ببيانات حقيقية من الـ API.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/warehouse_notification.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          ORDERS MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

enum WarehouseOrderStatus { newOrder, fulfilled, missing }

class WarehouseOrderItem {
  const WarehouseOrderItem({
    required this.id,
    required this.orderNumber,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.requester,
    required this.date,
    required this.status,
    this.notes,
  });

  final String id;
  final String orderNumber;
  final String materialName;
  final String quantity;
  final String unit;
  final String requester;
  final String date;
  final WarehouseOrderStatus status;
  final String? notes;
}

class WarehouseOrdersMockData {
  WarehouseOrdersMockData._();

  static const List<WarehouseOrderItem> orders = [
    WarehouseOrderItem(
      id: 'o1',
      orderNumber: 'ORD-001',
      materialName: 'قفازات لاتكس M',
      quantity: '100',
      unit: 'قطعة',
      requester: 'د. خالد سعيد',
      date: '2026-05-10',
      status: WarehouseOrderStatus.newOrder,
    ),
    WarehouseOrderItem(
      id: 'o2',
      orderNumber: 'ORD-002',
      materialName: 'حقن بنج موضعي',
      quantity: '20',
      unit: 'حقنة',
      requester: 'د. سارة أحمد',
      date: '2026-05-10',
      status: WarehouseOrderStatus.newOrder,
    ),
    WarehouseOrderItem(
      id: 'o3',
      orderNumber: 'ORD-003',
      materialName: 'خيط خياطة 3/0',
      quantity: '5',
      unit: 'بكرة',
      requester: 'المخبر',
      date: '2026-05-09',
      status: WarehouseOrderStatus.fulfilled,
    ),
    WarehouseOrderItem(
      id: 'o4',
      orderNumber: 'ORD-004',
      materialName: 'جبص طبي',
      quantity: '3',
      unit: 'كيلو',
      requester: 'د. محمد علي',
      date: '2026-05-09',
      status: WarehouseOrderStatus.fulfilled,
    ),
    WarehouseOrderItem(
      id: 'o5',
      orderNumber: 'ORD-005',
      materialName: 'مادة تلبيسة زركون',
      quantity: '5',
      unit: 'بلوك',
      requester: 'المخبر',
      date: '2026-05-08',
      status: WarehouseOrderStatus.missing,
    ),
    WarehouseOrderItem(
      id: 'o6',
      orderNumber: 'ORD-006',
      materialName: 'أكواب بلاستيكية',
      quantity: '200',
      unit: 'كوب',
      requester: 'السكرتيرة',
      date: '2026-05-08',
      status: WarehouseOrderStatus.newOrder,
    ),
    WarehouseOrderItem(
      id: 'o7',
      orderNumber: 'ORD-007',
      materialName: 'ماسكات طبية',
      quantity: '50',
      unit: 'قطعة',
      requester: 'د. خالد سعيد',
      date: '2026-05-07',
      status: WarehouseOrderStatus.fulfilled,
    ),
    WarehouseOrderItem(
      id: 'o8',
      orderNumber: 'ORD-008',
      materialName: 'سيليكون طبع',
      quantity: '2',
      unit: 'كيلو',
      requester: 'المخبر',
      date: '2026-05-06',
      status: WarehouseOrderStatus.fulfilled,
    ),
  ];
}

// ══════════════════════════════════════════════════════════════════════════
//                          INVOICES MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

enum InvoiceType { purchase, usage }

class WarehouseInvoiceItem {
  const WarehouseInvoiceItem({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.total,
    required this.date,
    this.supplier,
    this.notes,
  });

  final String id;
  final String invoiceNumber;
  final InvoiceType type;
  final String materialName;
  final String quantity;
  final String unit;
  final double unitPrice;
  final double total;
  final String date;
  final String? supplier;
  final String? notes;
}

class WarehouseInvoicesMockData {
  WarehouseInvoicesMockData._();

  static const List<WarehouseInvoiceItem> invoices = [
    WarehouseInvoiceItem(
      id: 'i1',
      invoiceNumber: 'INV-2026-001',
      type: InvoiceType.purchase,
      materialName: 'قفازات لاتكس M',
      quantity: '10',
      unit: 'كرتونة',
      unitPrice: 15000,
      total: 150000,
      date: '2026-05-10',
      supplier: 'شركة المستلزمات الطبية',
    ),
    WarehouseInvoiceItem(
      id: 'i2',
      invoiceNumber: 'INV-2026-002',
      type: InvoiceType.usage,
      materialName: 'حقن بنج موضعي',
      quantity: '30',
      unit: 'حقنة',
      unitPrice: 1200,
      total: 36000,
      date: '2026-05-09',
    ),
    WarehouseInvoiceItem(
      id: 'i3',
      invoiceNumber: 'INV-2026-003',
      type: InvoiceType.purchase,
      materialName: 'سيليكون طبع',
      quantity: '5',
      unit: 'كيلو',
      unitPrice: 25000,
      total: 125000,
      date: '2026-05-09',
      supplier: 'دار الطب للمستلزمات',
    ),
    WarehouseInvoiceItem(
      id: 'i4',
      invoiceNumber: 'INV-2026-004',
      type: InvoiceType.usage,
      materialName: 'خيط خياطة 3/0',
      quantity: '8',
      unit: 'بكرة',
      unitPrice: 3500,
      total: 28000,
      date: '2026-05-08',
    ),
    WarehouseInvoiceItem(
      id: 'i5',
      invoiceNumber: 'INV-2026-005',
      type: InvoiceType.purchase,
      materialName: 'ماسكات طبية',
      quantity: '5',
      unit: 'علبة',
      unitPrice: 8000,
      total: 40000,
      date: '2026-05-07',
      supplier: 'شركة المستلزمات الطبية',
    ),
    WarehouseInvoiceItem(
      id: 'i6',
      invoiceNumber: 'INV-2026-006',
      type: InvoiceType.usage,
      materialName: 'أكواب بلاستيكية',
      quantity: '100',
      unit: 'قطعة',
      unitPrice: 150,
      total: 15000,
      date: '2026-05-06',
    ),
  ];

  // ── ملخص الأسبوع ─────────────────────────────────────────────────
  static const double weeklyPurchaseTotal = 315000;
  static const double weeklyUsageTotal = 79000;
  static const double weeklyLossTotal = 12000;
}

// ══════════════════════════════════════════════════════════════════════════
//                          REPORTS MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

class ReportTopMaterial {
  const ReportTopMaterial({
    required this.rank,
    required this.name,
    required this.category,
    required this.requestCount,
    required this.cost,
  });

  final int rank;
  final String name;
  final String category;
  final int requestCount;
  final double cost;
}

class MonthlyOrderData {
  const MonthlyOrderData({
    required this.month,
    required this.count,
  });

  final String month;
  final int count;
}

class WarehouseReportsMockData {
  WarehouseReportsMockData._();

  static const List<ReportTopMaterial> topMaterials = [
    ReportTopMaterial(
        rank: 1,
        name: 'قفازات لاتكس M',
        category: 'مستهلكات',
        requestCount: 34,
        cost: 510000),
    ReportTopMaterial(
        rank: 2,
        name: 'حقن بنج موضعي',
        category: 'أدوية',
        requestCount: 28,
        cost: 336000),
    ReportTopMaterial(
        rank: 3,
        name: 'خيط خياطة 3/0',
        category: 'مستهلكات',
        requestCount: 22,
        cost: 77000),
    ReportTopMaterial(
        rank: 4,
        name: 'أكواب بلاستيكية',
        category: 'مستهلكات',
        requestCount: 19,
        cost: 28500),
    ReportTopMaterial(
        rank: 5,
        name: 'سيليكون طبع',
        category: 'مواد طبية',
        requestCount: 15,
        cost: 375000),
    ReportTopMaterial(
        rank: 6,
        name: 'ماسكات طبية',
        category: 'مستهلكات',
        requestCount: 14,
        cost: 112000),
    ReportTopMaterial(
        rank: 7,
        name: 'جبص طبي',
        category: 'مواد طبية',
        requestCount: 11,
        cost: 88000),
    ReportTopMaterial(
        rank: 8,
        name: 'بلوكات زركون',
        category: 'مواد طبية',
        requestCount: 9,
        cost: 540000),
    ReportTopMaterial(
        rank: 9,
        name: 'مرهم تخدير سطحي',
        category: 'أدوية',
        requestCount: 8,
        cost: 64000),
    ReportTopMaterial(
        rank: 10,
        name: 'محلول تطهير',
        category: 'مستهلكات',
        requestCount: 7,
        cost: 42000),
  ];

  static const List<MonthlyOrderData> monthlyOrders = [
    MonthlyOrderData(month: 'يناير', count: 42),
    MonthlyOrderData(month: 'فبراير', count: 38),
    MonthlyOrderData(month: 'مارس', count: 55),
    MonthlyOrderData(month: 'أبريل', count: 47),
    MonthlyOrderData(month: 'مايو', count: 29),
  ];

  // ── الملخص المالي ─────────────────────────────────────────────────
  static const double weeklyPurchases = 315000;
  static const double usageCost = 79000;
  static const double expiredLoss = 12000;
}

// ══════════════════════════════════════════════════════════════════════════
//                          NOTIFICATIONS MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

// النموذج انتقل لـ domain/entities/warehouse_notification.dart عند ربط الباك.

class WarehouseNotificationsMockData {
  WarehouseNotificationsMockData._();

  static const List<WarehouseNotification> notifications = [
    WarehouseNotification(
      id: 'n1',
      title: 'تنبيه نفاد مخزون',
      body: 'قفازات لاتكس M — تبقّى 12 قطعة فقط (الحد الأدنى: 100)',
      time: 'منذ 15 دقيقة',
      category: NotificationCategory.low,
      isRead: false,
      actionLabel: 'عرض المادة',
    ),
    WarehouseNotification(
      id: 'n2',
      title: 'صلاحية قريبة',
      body: 'مطهّر كحولي — تنتهي صلاحيته خلال 7 أيام (25/05/2026)',
      time: 'منذ 1 ساعة',
      category: NotificationCategory.expiry,
      isRead: false,
      actionLabel: 'مراجعة',
    ),
    WarehouseNotification(
      id: 'n3',
      title: 'طلبية جديدة',
      body: 'طلب قفازات × 100 من د. خالد سعيد — بانتظار الموافقة',
      time: 'منذ 2 ساعة',
      category: NotificationCategory.order,
      isRead: false,
      actionLabel: 'معالجة',
    ),
    WarehouseNotification(
      id: 'n4',
      title: 'طلبية جديدة',
      body: 'طلب جبص طبي × 3 كيلو من المخبر',
      time: 'منذ 3 ساعات',
      category: NotificationCategory.order,
      isRead: true,
    ),
    WarehouseNotification(
      id: 'n5',
      title: 'تنبيه نفاد مخزون',
      body: 'حقن بنج موضعي — تبقّى 5 حقن (الحد الأدنى: 20)',
      time: 'أمس',
      category: NotificationCategory.low,
      isRead: true,
    ),
    WarehouseNotification(
      id: 'n6',
      title: 'صلاحية قريبة',
      body: 'سيليكون طبع — تنتهي صلاحيته خلال 23 يوم',
      time: 'أمس',
      category: NotificationCategory.expiry,
      isRead: true,
    ),
    WarehouseNotification(
      id: 'n7',
      title: 'تقرير أسبوعي',
      body: 'ملخص هذا الأسبوع: 6 طلبيات، 315,000 ل.ل. مشتريات',
      time: 'قبل 2 يوم',
      category: NotificationCategory.general,
      isRead: true,
    ),
  ];
}
