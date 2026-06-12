// ════════════════════════════════════════════════════════════════════════════
// warehouse_orders_content.dart
//
// محتوى صفحة طلبيات المستودع — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   - تابات فلترة: الكل / عاجل / جديد / جزئي / تم التوريد
//   - شبكة بطاقات (3 أعمدة على wide): كل بطاقة فيها:
//       * شارة المادة + رقم الطلب + (شارة عاجل اختيارية)
//       * صف الطالب (أحرف بدائية + اسم الجهة)
//       * صف stats (الكمية / الطالب / التاريخ)
//       * شارة الحالة
//       * زرّان (توريد + عرض)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
import '../../../data/mock/warehouse_pages_mock_data.dart';
import 'warehouse_order_details_dialog.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _OrderFilter { all, urgent, isNew, partial, fulfilled }

extension on _OrderFilter {
  String label(AppLocalizations l10n) => switch (this) {
        _OrderFilter.all => l10n.ordersFilterAll,
        _OrderFilter.urgent => l10n.ordersUrgent,
        _OrderFilter.isNew => l10n.ordersStatusNew,
        _OrderFilter.partial => l10n.ordersStatusPartial,
        _OrderFilter.fulfilled => l10n.ordersStatusFulfilled,
      };

  bool matches(WarehouseOrderItem o, {required bool urgent}) {
    switch (this) {
      case _OrderFilter.all:
        return true;
      case _OrderFilter.urgent:
        return urgent;
      case _OrderFilter.isNew:
        return o.status == WarehouseOrderStatus.newOrder;
      case _OrderFilter.partial:
        return o.status == WarehouseOrderStatus.missing;
      case _OrderFilter.fulfilled:
        return o.status == WarehouseOrderStatus.fulfilled;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                            MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseOrdersContent extends StatefulWidget {
  const WarehouseOrdersContent({super.key});

  @override
  State<WarehouseOrdersContent> createState() => _WarehouseOrdersContentState();
}

class _WarehouseOrdersContentState extends State<WarehouseOrdersContent> {
  _OrderFilter _filter = _OrderFilter.all;

  late final List<WarehouseOrderItem> _all =
      WarehouseOrdersMockData.orders;

  /// أول طلبين جديدين عاجلان (heuristic للعرض حتى يصير في backend).
  late final Set<String> _urgentIds = _computeUrgent();

  Set<String> _computeUrgent() {
    final urgent = <String>{};
    var count = 0;
    for (final o in _all) {
      if (o.status == WarehouseOrderStatus.newOrder && count < 2) {
        urgent.add(o.id);
        count++;
      }
    }
    return urgent;
  }

  bool _isUrgent(WarehouseOrderItem o) => _urgentIds.contains(o.id);

  int _count(_OrderFilter f) =>
      _all.where((o) => f.matches(o, urgent: _isUrgent(o))).length;

  List<WarehouseOrderItem> get _filtered =>
      _all.where((o) => _filter.matches(o, urgent: _isUrgent(o))).toList();

  void _onSupplyTap(BuildContext context, WarehouseOrderItem o) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        content: Text(
          context.l10n.ordersSupplyConfirmed(o.materialName, o.orderNumber),
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final list = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(context, isLight),
        const SizedBox(height: 16),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: AppEmptyState(
              icon: Icons.assignment_outlined,
              title: context.l10n.ordersEmptyTitle,
              message: context.l10n.ordersEmptyMessage,
            ),
          )
        else
          _buildGrid(list, isLight),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSegmentedTabs<_OrderFilter>(
          values: _OrderFilter.values,
          selected: _filter,
          labelOf: (f) => f.label(context.l10n),
          countOf: (f) => _count(f),
          onChanged: (f) => setState(() => _filter = f),
        ),
        const Spacer(),
        Text(
          context.l10n.ordersCountSummary(_filtered.length, _all.length),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(List<WarehouseOrderItem> orders, bool isLight) {
    // Wrap بارتفاع طبيعي حسب المحتوى — نفس نمط كروت طلبات المخبر
    // (توحيد المسافات: spacing 16 بدون فراغ داخلي زائد).
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1180
          ? 3
          : c.maxWidth >= 760
              ? 2
              : 1;
      const double spacing = 16;
      final double cardW = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final o in orders)
            SizedBox(
              width: cardW,
              child: _OrderCard(
                order: o,
                urgent: _isUrgent(o),
                isLight: isLight,
                onView: () => WarehouseOrderDetailsDialog.show(
                  context,
                  order: o,
                  urgent: _isUrgent(o),
                ),
                onSupply: () => _onSupplyTap(context, o),
              ),
            ),
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              ORDER CARD
// ══════════════════════════════════════════════════════════════════════════

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.urgent,
    required this.isLight,
    required this.onView,
    required this.onSupply,
  });
  final WarehouseOrderItem order;
  final bool urgent;
  final bool isLight;
  final VoidCallback onView;
  final VoidCallback onSupply;

  // ── Status helpers ────────────────────────────────────────────────────
  String _statusLabel(AppLocalizations l10n) => switch (order.status) {
        WarehouseOrderStatus.newOrder => l10n.ordersStatusNew,
        WarehouseOrderStatus.fulfilled => l10n.ordersStatusFulfilled,
        WarehouseOrderStatus.missing => l10n.ordersStatusPartial,
      };

  Color get _statusColor => switch (order.status) {
        WarehouseOrderStatus.newOrder => AppColors.statusInfo,
        WarehouseOrderStatus.fulfilled => AppColors.statusSuccess,
        WarehouseOrderStatus.missing => AppColors.statusProgress,
      };

  Color get _accentColor =>
      urgent ? AppColors.statusUrgent : _statusColor;

  String get _requesterInitial {
    final r = order.requester.trim();
    if (r.isEmpty) return '?';
    final firstWord = r.split(' ').first;
    return firstWord.characters.firstOrNull ?? '?';
  }

  String get _requestNumber {
    final n = order.orderNumber.replaceAll(RegExp(r'\D'), '');
    return 'REQ-1${n.padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // فرض RTL لضمان: المادة يمين، REQ يسار، شارة الحالة يمين، الأزرار يسار.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        // RTL: أوّل child=يمين، آخر=يسار.
        // المطلوب: content يمين، stripe يسار → [content أوّل, stripe آخر].
        child: Row(
          children: [
            Expanded(
              child: Padding(
                // توحيد مع كرت طلبات المخبر (أفقي 16 / عمودي 14)
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRow(l10n),
                    const SizedBox(height: 8),
                    _buildRequesterRow(),
                    const SizedBox(height: 10),
                    _buildStatsRow(l10n),
                    const SizedBox(height: 12),
                    _buildBottomRow(l10n),
                  ],
                ),
              ),
            ),
            Container(width: 4, color: _accentColor),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTopRow(AppLocalizations l10n) {
    // RTL: أوّل=يمين، آخر=يسار.
    // المطلوب فيزيائياً (مطابق mockup):
    //   [REQ يمين]  ............  [Column: المادة فوق، عاجل تحت — يسار]
    // → ترتيب children: [Text(REQ), Spacer, Column(material + urgent)].
    final materialBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusProgressBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        order.materialName,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.statusProgress,
        ),
      ),
    );
    final urgentBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusUrgentBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      // RTL داخل الـ pill: الأيقونة يمين، النص يسار → [icon, SizedBox, text]
      // لكن للنغمة الأقرب لـ "!عاجل"، نضع النص أوّل (=يمين) ثم الأيقونة بعده.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.ordersUrgent,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.statusUrgent,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.priority_high_rounded,
              size: 12, color: AppColors.statusUrgent),
        ],
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _requestNumber,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              materialBadge,
              if (urgent) ...[
                const SizedBox(height: 4),
                urgentBadge,
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequesterRow() {
    // RTL: أوّل=يمين، آخر=يسار.
    // المطلوب: اسم الطالب يمين، avatar يسار → [Flexible(name), SizedBox, avatar].
    return Row(
      children: [
        Flexible(
          child: Text(
            order.requester,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _requesterInitial,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n) {
    final txt1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final txt3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MiniStat(
              label: l10n.ordersQuantity,
              value: '${order.quantity} ${order.unit}',
              txt1: txt1,
              txt3: txt3),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MiniStat(
              label: l10n.ordersRequester,
              value: order.requester,
              txt1: txt1,
              txt3: txt3),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MiniStat(
              label: l10n.ordersDate,
              value: order.date,
              txt1: txt1,
              txt3: txt3),
        ),
      ],
    );
  }

  Widget _buildBottomRow(AppLocalizations l10n) {
    // RTL: أوّل=يمين، آخر=يسار.
    // المطلوب فيزيائياً: [Status يمين] ... [عرض وسط] [توريد يسار].
    // → ترتيب children: [Status, Spacer, View, Supply].
    return Row(
      children: [
        _StatusPill(label: _statusLabel(l10n), color: _statusColor),
        const Spacer(),
        AppButton(
          label: l10n.ordersView,
          onPressed: onView,
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.small,
        ),
        if (order.status != WarehouseOrderStatus.fulfilled) ...[
          const SizedBox(width: 6),
          AppButton(
            label: '✓ ${l10n.ordersSupply}',
            onPressed: onSupply,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              PIECES
// ══════════════════════════════════════════════════════════════════════════

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.txt1,
    required this.txt3,
  });
  final String label;
  final String value;
  final Color txt1;
  final Color txt3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: txt3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: txt1,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      // RTL: أوّل=يمين، آخر=يسار.
      // المطلوب: النص يمين، الـ dot يسار → [Text, SizedBox, dot].
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}


