// ════════════════════════════════════════════════════════════════════════════
// app_search.dart
//
// مُجمِّع البحث العالمي لمركز الأوامر (Ctrl+K / زر التوب-بار). يجمع نتائج من:
//   • التنقّل: صفحات نظام المستخدم الحالي (قفز سريع).
//   • البيانات المُخزّنة (cache) في المستودعات: طلبات، منتجات، فنّيون، مواد،
//     طلبات مواد، مخزون — بلا طلب شبكة إضافي (يعتمد ما حُمِّل مسبقاً).
//
// بحث عالمي من طرفنا بحت (بلا باك، بلا مخاطر مفاتيح) — يخدم "التنظيم".
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../auth/auth_models.dart';
import '../auth/current_user.dart';
import '../di/injection_container.dart';
import '../router/route_names.dart';
import '../../features/lab/domain/repositories/lab_orders_repository.dart';
import '../../features/lab/domain/repositories/lab_products_repository.dart';
import '../../features/lab/domain/repositories/lab_repository.dart';
import '../../features/lab/domain/repositories/lab_material_requests_repository.dart';
import '../../features/lab/domain/repositories/lab_stock_repository.dart';

/// فئة النتيجة (لتجميعها بصريًا في اللوحة).
enum SearchCategory { navigation, order, product, technician, material, request }

/// نتيجة بحث واحدة في مركز الأوامر.
class SearchHit {
  const SearchHit({
    required this.category,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final SearchCategory category;
  final IconData icon;
  final String title;
  final String subtitle;

  /// المسار الذي يُنتقل إليه عند الاختيار.
  final String route;
}

/// مُجمِّع البحث — دالّة نقيّة تُرجع نتائج مطابِقة لنصّ الاستعلام.
class AppSearch {
  const AppSearch._();

  /// أقصى عدد نتائج لكل فئة (لبقاء اللوحة خفيفة).
  static const int _perCategory = 6;

  /// يبني نتائج البحث لنصّ [query]. فارغ ⇒ يعرض التنقّل فقط (قفز سريع).
  static List<SearchHit> query(String query) {
    final q = query.trim();
    final role = CurrentUser.instance.role;
    final hits = <SearchHit>[];

    // ── التنقّل (دائمًا) ─────────────────────────────────────────────────────
    for (final nav in _navFor(role)) {
      if (q.isEmpty || nav.title.contains(q)) hits.add(nav);
    }
    if (q.isEmpty) return hits;

    // ── بيانات المخبر المُخزّنة (فقط لمدير المخبر) ───────────────────────────
    if (role == EmployeeRole.labManager) {
      _addOrders(hits, q);
      _addProducts(hits, q);
      _addTechnicians(hits, q);
      _addRequests(hits, q);
      _addStock(hits, q);
    }
    return hits;
  }

  // ── التنقّل حسب الدور ──────────────────────────────────────────────────────
  static List<SearchHit> _navFor(EmployeeRole? role) {
    if (role == EmployeeRole.warehouseManager) {
      return const [
        SearchHit(category: SearchCategory.navigation, icon: Icons.dashboard_outlined, title: 'الصفحة الرئيسية', subtitle: 'لوحة المستودع', route: RouteNames.warehouseDashboard),
        SearchHit(category: SearchCategory.navigation, icon: Icons.inventory_2_outlined, title: 'المواد', subtitle: 'مواد المستودع', route: RouteNames.warehouseMaterials),
        SearchHit(category: SearchCategory.navigation, icon: Icons.receipt_long_outlined, title: 'الطلبات', subtitle: 'طلبات المستودع', route: RouteNames.warehouseOrders),
        SearchHit(category: SearchCategory.navigation, icon: Icons.description_outlined, title: 'الفواتير', subtitle: 'فواتير المستودع', route: RouteNames.warehouseInvoices),
        SearchHit(category: SearchCategory.navigation, icon: Icons.person_outline, title: 'الملف الشخصي', subtitle: '', route: RouteNames.warehouseSettings),
        SearchHit(category: SearchCategory.navigation, icon: Icons.settings_outlined, title: 'الإعدادات', subtitle: '', route: RouteNames.warehouseSettings),
      ];
    }
    // الافتراضي: مدير المخبر.
    return const [
      SearchHit(category: SearchCategory.navigation, icon: Icons.dashboard_outlined, title: 'الصفحة الرئيسية', subtitle: 'لوحة المخبر', route: RouteNames.labDashboard),
      SearchHit(category: SearchCategory.navigation, icon: Icons.assignment_outlined, title: 'طلبات الأطباء', subtitle: 'الطلبات', route: RouteNames.labOrders),
      SearchHit(category: SearchCategory.navigation, icon: Icons.groups_outlined, title: 'إدارة المخبريين', subtitle: 'الفنّيون', route: RouteNames.labTechnicians),
      SearchHit(category: SearchCategory.navigation, icon: Icons.inventory_2_outlined, title: 'مخزون المخبر', subtitle: 'المخزون', route: RouteNames.labInventory),
      SearchHit(category: SearchCategory.navigation, icon: Icons.category_outlined, title: 'منتجات المخبر', subtitle: 'الكتالوج', route: RouteNames.labProducts),
      SearchHit(category: SearchCategory.navigation, icon: Icons.local_shipping_outlined, title: 'طلبات المواد', subtitle: 'طلب مواد للمخبر', route: RouteNames.labMaterialRequests),
      SearchHit(category: SearchCategory.navigation, icon: Icons.person_outline, title: 'الملف الشخصي', subtitle: '', route: RouteNames.labSettings),
      SearchHit(category: SearchCategory.navigation, icon: Icons.settings_outlined, title: 'الإعدادات', subtitle: '', route: RouteNames.labSettings),
    ];
  }

  // ── مصادر البيانات (من الكاش فقط — بلا طلب شبكة) ─────────────────────────
  static void _addOrders(List<SearchHit> hits, String q) {
    final cached = _safe(() => sl<LabOrdersRepository>().cached) ?? const [];
    var n = 0;
    for (final o in cached) {
      if (n >= _perCategory) break;
      if (o.id.contains(q) || o.doctor.contains(q) || o.type.contains(q) ||
          o.material.contains(q)) {
        hits.add(SearchHit(
          category: SearchCategory.order,
          icon: Icons.assignment_outlined,
          title: '${o.id} — ${o.doctor}',
          subtitle: '${o.type} · ${o.material}',
          route: RouteNames.labOrders,
        ));
        n++;
      }
    }
  }

  static void _addProducts(List<SearchHit> hits, String q) {
    final cached = _safe(() => sl<LabProductsRepository>().cached) ?? const [];
    var n = 0;
    for (final p in cached) {
      if (n >= _perCategory) break;
      if (p.name.contains(q) || p.type.contains(q) || p.material.contains(q)) {
        hits.add(SearchHit(
          category: SearchCategory.product,
          icon: Icons.category_outlined,
          title: p.name,
          subtitle: '${p.type} · ${p.material}',
          route: RouteNames.labProducts,
        ));
        n++;
      }
    }
  }

  static void _addTechnicians(List<SearchHit> hits, String q) {
    final cached =
        _safe(() => sl<LabRepository>().cachedTechnicians) ?? const [];
    var n = 0;
    for (final t in cached) {
      if (n >= _perCategory) break;
      if (t.name.contains(q)) {
        hits.add(SearchHit(
          category: SearchCategory.technician,
          icon: Icons.person_outline,
          title: t.name,
          subtitle: t.isActive ? 'يعمل' : 'متوقّف',
          route: RouteNames.labTechnicians,
        ));
        n++;
      }
    }
  }

  static void _addRequests(List<SearchHit> hits, String q) {
    final cached =
        _safe(() => sl<LabMaterialRequestsRepository>().cached) ?? const [];
    var n = 0;
    for (final r in cached) {
      if (n >= _perCategory) break;
      if (r.material.contains(q) || r.id.contains(q)) {
        hits.add(SearchHit(
          category: SearchCategory.request,
          icon: Icons.local_shipping_outlined,
          title: r.material,
          subtitle: '${r.id} · ${r.quantity} ${r.unit}',
          route: RouteNames.labMaterialRequests,
        ));
        n++;
      }
    }
  }

  static void _addStock(List<SearchHit> hits, String q) {
    final cached = _safe(() => sl<LabStockRepository>().cached) ?? const [];
    var n = 0;
    for (final s in cached) {
      if (n >= _perCategory) break;
      if (s.material.contains(q)) {
        hits.add(SearchHit(
          category: SearchCategory.material,
          icon: Icons.inventory_2_outlined,
          title: s.material,
          subtitle: '${s.quantity} ${s.unit}',
          route: RouteNames.labInventory,
        ));
        n++;
      }
    }
  }

  /// يتجاهل أي فشل في حلّ مستودع غير مُسجَّل/غير مُحمَّل (يبقى البحث حيًّا).
  static T? _safe<T>(T Function() f) {
    try {
      return f();
    } catch (_) {
      return null;
    }
  }
}
