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

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../data/mock/warehouse_pages_mock_data.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _OrderFilter { all, urgent, isNew, partial, fulfilled }

extension on _OrderFilter {
  String get label => switch (this) {
        _OrderFilter.all => 'الكل',
        _OrderFilter.urgent => 'عاجل',
        _OrderFilter.isNew => 'جديد',
        _OrderFilter.partial => 'جزئي',
        _OrderFilter.fulfilled => 'تم التوريد',
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

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final list = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(isLight),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: AppEmptyState(
              icon: Icons.assignment_outlined,
              title: 'لا توجد طلبيات',
              message: 'لا يوجد طلبيات تطابق الفلتر الحالي',
            ),
          )
        else
          _buildGrid(list, isLight),
      ],
    );
  }

  Widget _buildToolbar(bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _OrderFilter.values
                .map((f) => _PillChip(
                      label: '${f.label} ${_count(f)}',
                      selected: f == _filter,
                      onTap: () => setState(() => _filter = f),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${_filtered.length} طلبية من أصل ${_all.length}',
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
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1180
          ? 3
          : c.maxWidth >= 760
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: switch (cols) { 3 => 1.15, 2 => 1.4, _ => 1.7 },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: orders
            .map((o) => _OrderCard(
                  order: o,
                  urgent: _isUrgent(o),
                  isLight: isLight,
                ))
            .toList(),
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
  });
  final WarehouseOrderItem order;
  final bool urgent;
  final bool isLight;

  // ── Status helpers ────────────────────────────────────────────────────
  String get _statusLabel => switch (order.status) {
        WarehouseOrderStatus.newOrder => 'جديد',
        WarehouseOrderStatus.fulfilled => 'تم التوريد',
        WarehouseOrderStatus.missing => 'جزئي',
      };

  Color get _statusColor => switch (order.status) {
        WarehouseOrderStatus.newOrder => const Color(0xFF2C7FDB),
        WarehouseOrderStatus.fulfilled => const Color(0xFF1F9B6E),
        WarehouseOrderStatus.missing => const Color(0xFF7A4FCF),
      };

  Color get _accentColor =>
      urgent ? const Color(0xFFD9434E) : _statusColor;

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
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: _accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRow(),
                    const SizedBox(height: 10),
                    _buildRequesterRow(),
                    const SizedBox(height: 12),
                    _buildStatsRow(),
                    const Spacer(),
                    const SizedBox(height: 10),
                    _buildBottomRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFE3FA),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              order.materialName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7A4FCF),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        if (urgent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD9434E).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.priority_high_rounded,
                    size: 12, color: Color(0xFFD9434E)),
                SizedBox(width: 2),
                Text(
                  'عاجل',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD9434E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
        const Spacer(),
        Text(
          _requestNumber,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }

  Widget _buildRequesterRow() {
    return Row(
      children: [
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
        const SizedBox(width: 10),
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
      ],
    );
  }

  Widget _buildStatsRow() {
    final txt1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final txt3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _MiniStat(label: 'الكمية', value: '${order.quantity} ${order.unit}', txt1: txt1, txt3: txt3),
        ),
        Expanded(
          child: _MiniStat(label: 'الطالب', value: order.requester, txt1: txt1, txt3: txt3),
        ),
        Expanded(
          child: _MiniStat(label: 'التاريخ', value: order.date, txt1: txt1, txt3: txt3),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        _StatusPill(label: _statusLabel, color: _statusColor),
        const Spacer(),
        if (order.status != WarehouseOrderStatus.fulfilled)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 6),
            child: AppButton(
              label: '✓ توريد',
              onPressed: () {},
              variant: AppButtonVariant.primary,
              size: AppButtonSize.small,
            ),
          ),
        AppButton(
          label: 'عرض',
          onPressed: () {},
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.small,
        ),
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
            fontSize: 10.5,
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
            fontSize: 12.5,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = selected
        ? AppColors.primary
        : (isLight ? AppColors.baseComponent : AppColors.darkSurface);
    final fg = selected
        ? Colors.white
        : (isLight ? AppColors.lightText1 : AppColors.darkText1);
    final border = selected
        ? AppColors.primary
        : (isLight ? AppColors.lightBorder : AppColors.darkBorder);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
