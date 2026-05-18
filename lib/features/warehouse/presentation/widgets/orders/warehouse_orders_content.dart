// ════════════════════════════════════════════════════════════════════════════
// warehouse_orders_content.dart
//
// المحتوى الكامل لصفحة الطلبيات — Phase 4.4 مكتملة.
//
// 🎯 الهدف:
//   - 4 filter chips (الكل / جديد / تم / غير موجود)
//   - جدول 7 أعمدة: رقم الطلب / المادة / الكمية / الطالب / التاريخ / الحالة / إجراء
//   - Modal: تفاصيل الطلب + إجراءات (تأكيد / رفض / مادة بديلة)
//   - Empty/Loading states
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — pg-o
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../../../warehouse/data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          MAIN CONTENT WIDGET
// ══════════════════════════════════════════════════════════════════════════

/// المحتوى الكامل لصفحة الطلبيات.
class WarehouseOrdersContent extends StatefulWidget {
  const WarehouseOrdersContent({super.key});

  @override
  State<WarehouseOrdersContent> createState() => _WarehouseOrdersContentState();
}

class _WarehouseOrdersContentState extends State<WarehouseOrdersContent> {
  // 0=الكل، 1=جديد، 2=تم، 3=غير موجود
  int _filterIndex = 0;

  List<WarehouseOrderItem> get _filteredOrders {
    switch (_filterIndex) {
      case 1:
        return WarehouseOrdersMockData.orders
            .where((o) => o.status == WarehouseOrderStatus.newOrder)
            .toList();
      case 2:
        return WarehouseOrdersMockData.orders
            .where((o) => o.status == WarehouseOrderStatus.fulfilled)
            .toList();
      case 3:
        return WarehouseOrdersMockData.orders
            .where((o) => o.status == WarehouseOrderStatus.missing)
            .toList();
      default:
        return WarehouseOrdersMockData.orders;
    }
  }

  int _countForFilter(int idx) {
    switch (idx) {
      case 1:
        return WarehouseOrdersMockData.orders
            .where((o) => o.status == WarehouseOrderStatus.newOrder)
            .length;
      case 2:
        return WarehouseOrdersMockData.orders
            .where((o) => o.status == WarehouseOrderStatus.fulfilled)
            .length;
      case 3:
        return WarehouseOrdersMockData.orders
            .where((o) => o.status == WarehouseOrderStatus.missing)
            .length;
      default:
        return WarehouseOrdersMockData.orders.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── شريط الفلاتر ────────────────────────────────────────────
        AppPageActionBar(
          filter: _buildFilterChips(context),
        ),

        // ── الجدول أو empty state ───────────────────────────────────
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.whOrdersTitle,
              message: context.l10n.noData,
            ),
          )
        else
          _buildTable(context, orders, isLight),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          FILTER CHIPS
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildFilterChips(BuildContext context) {
    final labels = [
      '${context.l10n.whFilterAll} (${_countForFilter(0)})',
      '${context.l10n.whOrderFilterNew} (${_countForFilter(1)})',
      '${context.l10n.whOrderFilterDone} (${_countForFilter(2)})',
      '${context.l10n.whOrderFilterMissing} (${_countForFilter(3)})',
    ];

    return AppFilterChipRow(
      options: labels,
      selectedIndex: _filterIndex,
      onChanged: (i) => setState(() => _filterIndex = i),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          TABLE
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildTable(
      BuildContext context, List<WarehouseOrderItem> orders, bool isLight) {
    final headerStyle = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      color: isLight ? AppColors.lightText4 : AppColors.darkText4,
      letterSpacing: 0.8,
    );

    final cellStyle = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isLight ? AppColors.lightText1 : AppColors.darkText1,
    );

    final borderColor =
        isLight ? AppColors.lightBorder : AppColors.darkBorder;
    final headerBg = isLight
        ? const Color(0x1ABED8FA)
        : const Color(0x0F9EFBEC);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        decoration: BoxDecoration(
          color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 940.0;
            final effectiveWidth = tableWidth < 940 ? 940.0 : tableWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: effectiveWidth,
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(110), // رقم الطلب
                    1: FlexColumnWidth(2.5), // المادة
                    2: FixedColumnWidth(90), // الكمية
                    3: FlexColumnWidth(1.8), // الطالب
                    4: FixedColumnWidth(120), // التاريخ
                    5: FixedColumnWidth(120), // الحالة
                    6: FixedColumnWidth(120), // إجراء
                  },
              children: [
                // ── Header ────────────────────────────────────────
                TableRow(
                  decoration: BoxDecoration(color: headerBg),
                  children: [
                    _headerCell(context.l10n.whOrderNumber, headerStyle),
                    _headerCell(context.l10n.whMaterialName, headerStyle),
                    _headerCell(context.l10n.whMaterialQuantity, headerStyle),
                    _headerCell(context.l10n.whOrderRequester, headerStyle),
                    _headerCell(context.l10n.whOrderDate, headerStyle),
                    _headerCell(context.l10n.whOrderStatus, headerStyle),
                    _headerCell(context.l10n.whOrderAction, headerStyle),
                  ],
                ),

                // ── Rows ──────────────────────────────────────────
                for (final order in orders)
                  _buildRow(context, order, cellStyle, borderColor, isLight),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _headerCell(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Text(text, style: style, textAlign: TextAlign.right),
    );
  }

  TableRow _buildRow(
    BuildContext context,
    WarehouseOrderItem order,
    TextStyle cellStyle,
    Color borderColor,
    bool isLight,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      children: [
        // رقم الطلب
        _cell(
          Text(
            order.orderNumber,
            style: cellStyle.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.dashCyan,
            ),
          ),
        ),

        // المادة
        _cell(
          Text(order.materialName, style: cellStyle),
        ),

        // الكمية
        _cell(
          Text(
            '${order.quantity} ${order.unit}',
            style: cellStyle.copyWith(fontSize: 13),
          ),
        ),

        // الطالب
        _cell(
          Text(order.requester, style: cellStyle),
        ),

        // التاريخ
        _cell(
          Text(
            order.date,
            style: cellStyle.copyWith(
              fontSize: 13,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ),

        // الحالة
        _cell(_buildStatusBadge(context, order.status)),

        // إجراء
        _cell(_buildActionButton(context, order)),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: child,
    );
  }

  Widget _buildStatusBadge(BuildContext context, WarehouseOrderStatus status) {
    switch (status) {
      case WarehouseOrderStatus.newOrder:
        return AppBadge(
          text: context.l10n.whOrderStatusNew,
          variant: AppBadgeVariant.gold,
        );
      case WarehouseOrderStatus.fulfilled:
        return AppBadge(
          text: context.l10n.whOrderStatusFulfilled,
          variant: AppBadgeVariant.green,
        );
      case WarehouseOrderStatus.missing:
        return AppBadge(
          text: context.l10n.whOrderStatusMissing,
          variant: AppBadgeVariant.redAnimated,
        );
    }
  }

  Widget _buildActionButton(BuildContext context, WarehouseOrderItem order) {
    if (order.status == WarehouseOrderStatus.fulfilled ||
        order.status == WarehouseOrderStatus.missing) {
      return Text(
        '—',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightText4
              : AppColors.darkText4,
        ),
      );
    }

    return AppButton(
      label: context.l10n.confirm,
      onPressed: () => _showOrderDetails(context, order),
      variant: AppButtonVariant.primary,
      size: AppButtonSize.small,
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          ORDER DETAILS DIALOG
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _showOrderDetails(
      BuildContext context, WarehouseOrderItem order) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _OrderDetailsDialog(order: order),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ORDER DETAILS DIALOG
// ════════════════════════════════════════════════════════════════════════════

class _OrderDetailsDialog extends StatelessWidget {
  const _OrderDetailsDialog({required this.order});

  final WarehouseOrderItem order;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? [AppColors.baseComponent, const Color(0xFFF5F8FF)]
                : [AppColors.modalDarkStart, AppColors.modalDarkEnd],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل الطلب',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? AppColors.lightText1
                                : AppColors.darkText1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.orderNumber,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            color: AppColors.dashCyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),

            // ── تفاصيل ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              child: Column(
                children: [
                  _detailRow(context, 'المادة', order.materialName, isLight),
                  const SizedBox(height: 12),
                  _detailRow(context, 'الكمية',
                      '${order.quantity} ${order.unit}', isLight),
                  const SizedBox(height: 12),
                  _detailRow(context, 'الطالب', order.requester, isLight),
                  const SizedBox(height: 12),
                  _detailRow(context, 'التاريخ', order.date, isLight),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            ),

            // ── أزرار الإجراءات ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSizes.spaceLG),
              child: Row(
                children: [
                  // تأكيد
                  Expanded(
                    child: AppButton(
                      label: context.l10n.confirm,
                      onPressed: () => Navigator.pop(context),
                      variant: AppButtonVariant.primary,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // مادة بديلة
                  Expanded(
                    child: AppButton(
                      label: 'مادة بديلة',
                      onPressed: () => Navigator.pop(context),
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // رفض
                  Expanded(
                    child: AppButton(
                      label: context.l10n.delete,
                      onPressed: () => Navigator.pop(context),
                      variant: AppButtonVariant.danger,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      BuildContext context, String label, String value, bool isLight) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
      ],
    );
  }
}
