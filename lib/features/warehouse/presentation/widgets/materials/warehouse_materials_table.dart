// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_table.dart
//
// جدول المواد + خلاياه — part of warehouse_materials_content.dart (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_materials_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          3) TABLE SECTION
// ══════════════════════════════════════════════════════════════════════════

class _TableSection extends StatelessWidget {
  const _TableSection({
    required this.total,
    required this.all,
    required this.filtered,
    required this.status,
    required this.onStatusChange,
    required this.isLight,
    required this.onAddTap,
    required this.onRowTap,
    required this.onMovement,
    required this.onDeactivate,
    required this.onViewLogs,
  });

  final int total;
  final List<WarehouseMaterial> all;
  final List<WarehouseMaterial> filtered;
  final _StatusFilter status;
  final ValueChanged<_StatusFilter> onStatusChange;
  final bool isLight;
  final VoidCallback onAddTap;
  final ValueChanged<WarehouseMaterial> onRowTap;
  final ValueChanged<WarehouseMaterial> onMovement;
  final ValueChanged<WarehouseMaterial> onDeactivate;
  final VoidCallback onViewLogs;

  int _statusCount(_StatusFilter s) =>
      all.where(s.matches).length;

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
      child: Column(
        children: [
          _buildHeader(context),
          Divider(
            height: 1,
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: context.l10n.whMaterialsEmptyTitle,
                message: context.l10n.whMaterialsEmptyMessage,
              ),
            )
          else
            _MaterialsTable(
              rows: filtered,
              isLight: isLight,
              onRowTap: onRowTap,
              onMovement: onMovement,
              onDeactivate: onDeactivate,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: LayoutBuilder(builder: (context, c) {
        final isNarrow = c.maxWidth < 720;
        final title = Row(
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              context.l10n.whMaterialsTitle,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
            ),
            const SizedBox(width: 8),
            _CountBadge(count: total),
          ],
        );

        final tabs = AppSegmentedTabs<_StatusFilter>(
          values: _StatusFilter.values,
          selected: status,
          labelOf: (v) => v.label(context.l10n),
          countOf: (v) => _statusCount(v),
          onChanged: onStatusChange,
        );

        final logsBtn = AppButton.secondary(
          label: context.l10n.whStockLogButton,
          onPressed: onViewLogs,
          size: AppButtonSize.small,
          icon: Icons.receipt_long_outlined,
        );

        final addBtn = AppButton(
          label: '+ ${context.l10n.whMaterialsAdd}',
          onPressed: onAddTap,
          variant: AppButtonVariant.primary,
          size: AppButtonSize.small,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                title,
                const Spacer(),
                logsBtn,
                const SizedBox(width: 8),
                addBtn,
              ]),
              const SizedBox(height: 10),
              tabs,
            ],
          );
        }
        return Row(
          children: [
            title,
            const Spacer(),
            tabs,
            const SizedBox(width: 10),
            logsBtn,
            const SizedBox(width: 10),
            addBtn,
          ],
        );
      }),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusProgressBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.statusProgress,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          4) MATERIALS TABLE
// ══════════════════════════════════════════════════════════════════════════

class _MaterialsTable extends StatelessWidget {
  const _MaterialsTable({
    required this.rows,
    required this.isLight,
    required this.onRowTap,
    required this.onMovement,
    required this.onDeactivate,
  });
  final List<WarehouseMaterial> rows;
  final bool isLight;
  final ValueChanged<WarehouseMaterial> onRowTap;
  final ValueChanged<WarehouseMaterial> onMovement;
  final ValueChanged<WarehouseMaterial> onDeactivate;

  @override
  Widget build(BuildContext context) {
    // إزالة الـ horizontal SingleChildScrollView + ConstrainedBox السابقة —
    // كانت تعطي عرض غير محدود للـ Column → Expanded children تطلع بـ 0 عرض
    // فيختفي الجدول. هلق الـ Column يأخذ عرض الأب الطبيعي مباشرة.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableHeader(isLight: isLight),
        for (var i = 0; i < rows.length; i++)
          _TableDataRow(
            material: rows[i],
            isLight: isLight,
            isLast: i == rows.length - 1,
            onTap: () => onRowTap(rows[i]),
            onMovement: () => onMovement(rows[i]),
            onDeactivate: () => onDeactivate(rows[i]),
          ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isLight ? AppColors.tableHeader : AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(flex: 2, child: _HCell(context.l10n.whColCode)),
          Expanded(flex: 3, child: _HCell(context.l10n.whColName)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColCategory)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColStock)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColPrice)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColCompany)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColDosage)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColStatus)),
          Expanded(flex: 2, child: _HCell(context.l10n.whMovementColumn)),
        ],
      ),
    );
  }
}

class _HCell extends StatelessWidget {
  const _HCell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText3,
      ),
    );
  }
}

class _TableDataRow extends StatelessWidget {
  const _TableDataRow({
    required this.material,
    required this.isLight,
    required this.isLast,
    required this.onTap,
    required this.onMovement,
    required this.onDeactivate,
  });
  final WarehouseMaterial material;
  final bool isLight;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onMovement;
  final VoidCallback onDeactivate;

  String get _code => 'MAT-${material.id.padLeft(3, '0').substring(material.id.length > 3 ? material.id.length - 3 : 0)}';

  String get _priceStr {
    final p = material.pricePerUnit;
    final s = p == p.roundToDouble() ? p.toStringAsFixed(0) : p.toString();
    return '$s ل.س';
  }

  @override
  Widget build(BuildContext context) {
    final txt1 = isLight ? AppColors.lightText1 : AppColors.darkText1;
    final txt3 = isLight ? AppColors.lightText3 : AppColors.darkText3;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast
                  ? Colors.transparent
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                _code,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: txt3,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                material.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: txt1,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _CategoryDot(category: material.category),
            ),
            Expanded(
              flex: 2,
              child: _StockCell(material: material),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _priceStr,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  color: txt3,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                material.companyName.isEmpty ? '—' : material.companyName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  color: txt1,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                material.dosage?.isNotEmpty == true ? material.dosage! : '—',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  color: txt3,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: _StatusPill(status: material.status),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MovementButton(onTap: onMovement, isLight: isLight),
                    const SizedBox(width: 6),
                    _DeactivateButton(onTap: onDeactivate, isLight: isLight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر إلغاء تفعيل المادة (حذف ناعم — المادة تختفي من القائمة النشطة).
class _DeactivateButton extends StatelessWidget {
  const _DeactivateButton({required this.onTap, required this.isLight});
  final VoidCallback onTap;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.whMaterialDeactivate,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Semantics(
          button: true,
          label: context.l10n.whMaterialDeactivate,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.darkBg1,
                border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: const Icon(Icons.block_rounded,
                  size: 15, color: AppColors.alertRed),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر فتح مودال حركة المخزون (إدخال/إخراج).
class _MovementButton extends StatelessWidget {
  const _MovementButton({required this.onTap, required this.isLight});
  final VoidCallback onTap;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.whMovementTitle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Semantics(
          button: true,
          label: context.l10n.whMovementTitle,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : AppColors.darkBg1,
                border: Border.all(
                    color:
                        isLight ? AppColors.lightBorder : AppColors.darkBorder),
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert_rounded,
                      size: 15, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.whMovementColumn,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryDot extends StatelessWidget {
  const _CategoryDot({required this.category});
  final MaterialCategory category;

  Color get _color => category.accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            category.label(context),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ),
      ],
    );
  }
}

class _StockCell extends StatelessWidget {
  const _StockCell({required this.material});
  final WarehouseMaterial material;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final pct = material.minStock > 0
        ? (material.quantity / (material.minStock * 2)).clamp(0.0, 1.0)
        : 1.0;
    final color = material.status.accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${material.quantity} ${material.unit}',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor:
                (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final MaterialStatus status;

  @override
  Widget build(BuildContext context) {
    final c = status.accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label(context),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
