// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_content.dart
//
// المحتوى الكامل لـ Dashboard المستودع — يجمع كل widgets الـ Dashboard
// في layout موحّد مطابق للـ HTML mockup.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2127–2204
//
// Layout:
//   ┌─────────────────────────────────────────────────────────────────┐
//   │                    Dashboard Hero (full width)                   │
//   ├─────────────────────────────────────────────────────────────────┤
//   │  StatCard │  StatCard │  StatCard │  StatCard  (4 cards)         │
//   ├─────────────────────────────────────────────────────────────────┤
//   │  Top Requested Table (flex)         │  Alert Red (290px)         │
//   │  Expiring Table     (flex)          │  Alert Orange              │
//   │                                     │  Quick Actions             │
//   │                                     │  Donut Chart               │
//   └─────────────────────────────────────────────────────────────────┘
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../shared/widgets/data/app_data_table.dart';
import '../../../data/mock/warehouse_dashboard_mock_data.dart';
import 'warehouse_alert_box.dart';
import 'warehouse_dashboard_card.dart';
import 'warehouse_dashboard_hero.dart';
import 'warehouse_donut_chart.dart';
import 'warehouse_quick_action_grid.dart';
import 'warehouse_stat_card.dart';
import 'warehouse_table_badge.dart';

/// المحتوى الكامل لـ Dashboard المستودع.
///
/// يحتوي على:
/// 1. Hero card مع 3 إحصائيات
/// 2. صف من 4 stat cards
/// 3. صف رئيسي مكوّن من عمودين:
///    - يسار (flex): جدول مواد أكثر طلباً + جدول صلاحيات
///    - يمين (290px): alert boxes + quick actions + donut chart
class WarehouseDashboardContent extends StatelessWidget {
  const WarehouseDashboardContent({super.key});

  // نقطة كسر للـ responsive — تحت هذا، نتحول لـ stacked layout.
  static const double _twoColumnBreakpoint = 1100.0;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool useTwoColumn = width >= _twoColumnBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. Hero ──────────────────────────────────────────────────
        const WarehouseDashboardHero(
          registeredCount: WarehouseDashboardMockData.registeredCount,
          pendingOrdersCount: WarehouseDashboardMockData.pendingOrdersCount,
          activeAlertsCount: WarehouseDashboardMockData.activeAlertsCount,
        ),

        // ── 2. Stat Cards Row ────────────────────────────────────────
        _buildStatCards(context),
        const SizedBox(height: 18),

        // ── 3. Main Content (responsive: 2-col أو stacked) ──────────
        if (useTwoColumn)
          _buildTwoColumnLayout(context)
        else
          _buildStackedLayout(context),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          STAT CARDS
  // ────────────────────────────────────────────────────────────────────────

  /// صف من 4 stat cards (يستخدم Grid على شاشات أصغر).
  Widget _buildStatCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // عند عرض > 800px → 4 أعمدة. تحت ذلك → 2.
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: crossAxisCount == 4 ? 1.65 : 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            WarehouseStatCard(
              variant: WarehouseStatCardVariant.cyan,
              icon: AppIcons.box,
              value: WarehouseDashboardMockData.currentInventoryCount,
              label: context.l10n.whStatCurrentInventory,
              chipText: '+4',
              chipType: WarehouseStatChipType.up,
              onTap: () => context.go(RouteNames.warehouseMaterials),
            ),
            WarehouseStatCard(
              variant: WarehouseStatCardVariant.red,
              icon: AppIcons.warning,
              value: WarehouseDashboardMockData.lowStockCount,
              label: context.l10n.whStatLowStockMaterials,
              chipText: context.l10n.whStatusLow,
              chipType: WarehouseStatChipType.down,
              onTap: () => context.go(RouteNames.warehouseMaterials),
            ),
            WarehouseStatCard(
              variant: WarehouseStatCardVariant.orange,
              icon: AppIcons.orders,
              value: WarehouseDashboardMockData.incomingOrdersCount,
              label: context.l10n.whStatIncomingOrders,
              chipText: context.l10n.whOrderStatusNew,
              chipType: WarehouseStatChipType.warn,
              onTap: () => context.go(RouteNames.warehouseOrders),
            ),
            WarehouseStatCard(
              variant: WarehouseStatCardVariant.green,
              icon: AppIcons.refresh,
              value: WarehouseDashboardMockData.expiringCount,
              label: context.l10n.whStatExpiringMaterials,
              chipText: context.l10n.whStatusLow,
              chipType: WarehouseStatChipType.up,
              onTap: () => context.go(RouteNames.warehouseReports),
            ),
          ],
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          LAYOUT VARIANTS
  // ────────────────────────────────────────────────────────────────────────

  /// Layout بعمودين (تصميم HTML الأصلي).
  Widget _buildTwoColumnLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── العمود الأيسر (flex) — الجداول ───────────────────────────
        Expanded(child: _buildLeftColumn(context)),
        const SizedBox(width: 16),

        // ── العمود الأيمن (290px ثابت) — alerts + quick actions ─────
        SizedBox(
          width: 290,
          child: _buildRightColumn(context),
        ),
      ],
    );
  }

  /// Layout متراص (للشاشات الصغيرة).
  Widget _buildStackedLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLeftColumn(context),
        const SizedBox(height: 14),
        _buildRightColumn(context),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          COLUMNS
  // ────────────────────────────────────────────────────────────────────────

  /// العمود الأيسر — جدولين (مواد أكثر طلباً + صلاحيات).
  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // الجدول 1: المواد الأكثر طلباً
        WarehouseDashboardCard(
          margin: const EdgeInsets.only(bottom: 16),
          header: WarehouseCardHeader(
            title: '⭐ ${context.l10n.whSectionTopRequested}',
            caption: context.l10n.whSectionTopRequestedCaption,
            actionLabel: '${context.l10n.whFullReport} ←',
            onActionTap: () => context.go(RouteNames.warehouseReports),
          ),
          child: _buildTopRequestedTable(context),
        ),

        // الجدول 2: مواد ستنتهي صلاحيتها
        WarehouseDashboardCard(
          header: WarehouseCardHeader(
            title: '⏰ ${context.l10n.whSectionExpiringSoon}',
            caption: context.l10n.whSectionExpiringCaption,
          ),
          child: _buildExpiringTable(context),
        ),
      ],
    );
  }

  /// العمود الأيمن — 4 widgets (alert × 2 + quick actions + donut).
  Widget _buildRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Alert: نفاد مخزون
        WarehouseAlertBox(
          variant: WarehouseAlertBoxVariant.red,
          icon: AppIcons.warning,
          title: context.l10n.whAlertLowStockTitle,
          subtitle: context.l10n.whAlertLowStockSubtitle(8),
          items: WarehouseDashboardMockData.lowStockAlertItems
              .map((m) => WarehouseAlertItemData(
                    text: m.text,
                    value: m.value,
                    onTap: () => context.go(RouteNames.warehouseMaterials),
                  ))
              .toList(growable: false),
        ),

        // Alert: طلبيات جديدة
        WarehouseAlertBox(
          variant: WarehouseAlertBoxVariant.orange,
          icon: AppIcons.orders,
          title: context.l10n.whAlertNewOrdersTitle,
          subtitle: context.l10n.whAlertNewOrdersSubtitle(3),
          items: WarehouseDashboardMockData.newOrderAlertItems
              .map((m) => WarehouseAlertItemData(
                    text: m.text,
                    value: context.l10n.whOrderStatusNew,
                    onTap: () => context.go(RouteNames.warehouseOrders),
                  ))
              .toList(growable: false),
        ),
        const SizedBox(height: 14),

        // Quick Actions
        WarehouseQuickActionGrid.standard(
          context: context,
          onAddMaterial: () => context.go(RouteNames.warehouseMaterials),
          onAddInvoice: () => context.go(RouteNames.warehouseInvoices),
          onReports: () => context.go(RouteNames.warehouseReports),
          onOrders: () => context.go(RouteNames.warehouseOrders),
        ),
        const SizedBox(height: 14),

        // Donut Chart
        WarehouseDonutChart.standard(context: context),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          TABLES
  // ────────────────────────────────────────────────────────────────────────

  /// جدول "المواد الأكثر طلباً".
  Widget _buildTopRequestedTable(BuildContext context) {
    return AppDataTable<TopRequestedMaterial>(
      data: WarehouseDashboardMockData.topRequested,
      columns: [
        // المادة
        AppDataColumn<TopRequestedMaterial>(
          label: context.l10n.whMaterialName,
          flex: 3,
          cellBuilder: (m) => Text(
            m.name,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightText1
                  : AppColors.darkText1,
            ),
          ),
        ),
        // الفئة
        AppDataColumn<TopRequestedMaterial>(
          label: context.l10n.whMaterialCategory,
          flex: 2,
          cellBuilder: (m) => WarehouseTableBadge(
            variant: m.categoryVariant,
            text: m.category,
          ),
        ),
        // الطلبات
        AppDataColumn<TopRequestedMaterial>(
          label: context.l10n.whReportRequestCount,
          flex: 1,
          cellBuilder: (m) => Text(
            m.requestCount.toString(),
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.dashCyan,
            ),
          ),
        ),
        // الكمية
        AppDataColumn<TopRequestedMaterial>(
          label: context.l10n.whMaterialQuantity,
          flex: 2,
          cellBuilder: (m) => Text(
            m.quantity,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightText1
                  : AppColors.darkText1,
            ),
          ),
        ),
        // الحالة
        AppDataColumn<TopRequestedMaterial>(
          label: context.l10n.whOrderStatus,
          flex: 2,
          cellBuilder: (m) => WarehouseTableBadge(
            variant: m.statusVariant,
            text: _statusText(context, m.statusKey),
          ),
        ),
      ],
    );
  }

  /// جدول "مواد ستنتهي صلاحيتها".
  Widget _buildExpiringTable(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppDataTable<ExpiringMaterial>(
      data: WarehouseDashboardMockData.expiring,
      columns: [
        AppDataColumn<ExpiringMaterial>(
          label: context.l10n.whMaterialName,
          flex: 3,
          cellBuilder: (e) => Text(
            e.name,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
        AppDataColumn<ExpiringMaterial>(
          label: context.l10n.whMaterialQuantity,
          flex: 2,
          cellBuilder: (e) => Text(
            e.quantity,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
        AppDataColumn<ExpiringMaterial>(
          label: context.l10n.whMaterialExpiryDate,
          flex: 2,
          cellBuilder: (e) => Text(
            e.expiryDate,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ),
        AppDataColumn<ExpiringMaterial>(
          label: context.l10n.whExpiryDaysLeft,
          flex: 2,
          cellBuilder: (e) => Text(
            '${e.daysLeft}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppColors.expiryColorFor(e.daysLeft),
            ),
          ),
        ),
      ],
    );
  }

  /// helper لتحويل status key إلى نص l10n.
  String _statusText(BuildContext context, String key) {
    switch (key) {
      case 'whStatusAvailable':
        return context.l10n.whStatusAvailable;
      case 'whStatusLow':
        return context.l10n.whStatusLow;
      case 'whStatusOut':
        return context.l10n.whStatusOut;
      default:
        return key;
    }
  }
}
