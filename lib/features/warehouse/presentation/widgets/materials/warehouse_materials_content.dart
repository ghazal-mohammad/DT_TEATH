// ════════════════════════════════════════════════════════════════════════════
// warehouse_materials_content.dart
//
// محتوى صفحة المواد — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   1. صف 4 بطاقات إحصائية (نفدت / ينفد / متوفر / إجمالي)
//   2. شريط فلاتر الفئات (الكل / مواد طبية / مستهلكات / أدوية / معادن)
//   3. قسم الجدول: عنوان + tabs الحالة (الكل/ينفد/نفد/متوفر) + زر إضافة
//   4. الجدول: الكود | الاسم | الفئة | المخزون | الحد الأدنى | الصلاحية | المورد | الحالة
//
// المنطق:
//   - cubit يدير CRUD على المواد + الـ category filter.
//   - الـ status filter يُدار محلياً (لا يحتاج backend).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/feedback/app_empty_state.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/material_category.dart';
import '../../../domain/entities/material_status.dart';
import '../../../domain/entities/warehouse_material.dart';
import '../../bloc/materials_cubit.dart';
import '../../bloc/materials_state.dart';
import 'warehouse_material_form_dialog.dart';
import 'warehouse_material_movement_dialog.dart';

// ══════════════════════════════════════════════════════════════════════════
//                             LOCAL FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _CategoryFilter { all, medical, consumables, medicines, metals }

extension on _CategoryFilter {
  String label(AppLocalizations l10n) => switch (this) {
        _CategoryFilter.all => l10n.whFilterAll,
        _CategoryFilter.medical => l10n.whCategoryMedical,
        _CategoryFilter.consumables => l10n.whCategoryConsumables,
        _CategoryFilter.medicines => l10n.whCategoryMedicines,
        _CategoryFilter.metals => l10n.whCategoryEquipment,
      };

  bool matches(WarehouseMaterial m) {
    switch (this) {
      case _CategoryFilter.all:
        return true;
      case _CategoryFilter.medical:
        return m.category == MaterialCategory.medical;
      case _CategoryFilter.consumables:
        return m.category == MaterialCategory.consumables;
      case _CategoryFilter.medicines:
        return m.category == MaterialCategory.medicines;
      case _CategoryFilter.metals:
        return m.category == MaterialCategory.equipment;
    }
  }
}

enum _StatusFilter { all, low, out, available }

extension on _StatusFilter {
  String label(AppLocalizations l10n) => switch (this) {
        _StatusFilter.all => l10n.whFilterAll,
        _StatusFilter.low => l10n.whStatusLow,
        _StatusFilter.out => l10n.whStatusOut,
        _StatusFilter.available => l10n.whStatusAvailable,
      };

  bool matches(WarehouseMaterial m) {
    final s = m.status;
    return switch (this) {
      _StatusFilter.all => true,
      _StatusFilter.low => s == MaterialStatus.low,
      _StatusFilter.out =>
        s == MaterialStatus.outOfStock || s == MaterialStatus.expired,
      _StatusFilter.available =>
        s == MaterialStatus.available || s == MaterialStatus.expiringSoon,
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                            MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseMaterialsContent extends StatefulWidget {
  const WarehouseMaterialsContent({super.key});

  @override
  State<WarehouseMaterialsContent> createState() =>
      _WarehouseMaterialsContentState();
}

class _WarehouseMaterialsContentState extends State<WarehouseMaterialsContent> {
  _CategoryFilter _category = _CategoryFilter.all;
  _StatusFilter _status = _StatusFilter.all;

  List<WarehouseMaterial> _applyFilters(List<WarehouseMaterial> all) {
    return all.where(_category.matches).where(_status.matches).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BlocBuilder<MaterialsCubit, MaterialsState>(
      builder: (context, state) {
        final all = state.materials;
        final filtered = _applyFilters(all);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatsRow(materials: all, isLight: isLight),
            const SizedBox(height: 14),
            _CategoryFilterBar(
              active: _category,
              onChange: (c) => setState(() => _category = c),
              total: all.length,
              afterFilter: all.where(_category.matches).length,
              isLight: isLight,
            ),
            const SizedBox(height: 14),
            _TableSection(
              total: all.length,
              all: all,
              filtered: filtered,
              status: _status,
              onStatusChange: (s) => setState(() => _status = s),
              isLight: isLight,
              onAddTap: () => _openForm(context),
              onRowTap: (m) => _openForm(context, initial: m),
              onMovement: (m) => _openMovement(context, m),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openForm(BuildContext context,
      {WarehouseMaterial? initial}) async {
    final cubit = context.read<MaterialsCubit>();
    final result =
        await WarehouseMaterialFormDialog.show(context, initialMaterial: initial);
    if (result == null) return;
    if (initial == null) {
      await cubit.create(result);
    } else {
      await cubit.update(result);
    }
  }

  /// تسجيل حركة مخزون (إدخال/إخراج) على مادة — UC81.
  Future<void> _openMovement(BuildContext context,
      WarehouseMaterial material) async {
    final cubit = context.read<MaterialsCubit>();
    final delta = await WarehouseMaterialMovementDialog.show(context, material);
    if (delta == null) return;
    final newQty = (material.quantity + delta).clamp(0, 1 << 30);
    await cubit.update(material.copyWith(quantity: newQty));
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          1) STATS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.materials, required this.isLight});
  final List<WarehouseMaterial> materials;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final outCount = materials
        .where((m) =>
            m.status == MaterialStatus.outOfStock ||
            m.status == MaterialStatus.expired)
        .length;
    final lowCount =
        materials.where((m) => m.status == MaterialStatus.low).length;
    final availCount = materials
        .where((m) =>
            m.status == MaterialStatus.available ||
            m.status == MaterialStatus.expiringSoon)
        .length;
    final total = materials.length;

    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 980
          ? 4
          : c.maxWidth >= 600
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: switch (cols) { 4 => 1.7, 2 => 2.3, _ => 3.0 },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _StatBox(
            isLight: isLight,
            badge: context.l10n.profileBadgeAlert,
            badgeColor: const Color(0xFF7A4FCF),
            value: '$outCount',
            label: context.l10n.whStatOutMaterials,
            icon: Icons.access_time_rounded,
            accent: const Color(0xFF7A4FCF),
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.profileBadgeAlert,
            badgeColor: const Color(0xFFE17B2C),
            value: '$lowCount',
            label: context.l10n.whStatLowMaterials,
            icon: Icons.warning_amber_rounded,
            accent: const Color(0xFFE17B2C),
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.whStatusAvailable,
            badgeColor: const Color(0xFF1F9B6E),
            value: '$availCount',
            label: context.l10n.whStatAvailMaterials,
            icon: Icons.check_rounded,
            accent: const Color(0xFF1F9B6E),
          ),
          _StatBox(
            isLight: isLight,
            badge: context.l10n.whBadgeTotal,
            badgeColor: const Color(0xFF2C7FDB),
            value: '$total',
            label: context.l10n.whStatTotalMaterials,
            icon: Icons.inventory_2_outlined,
            accent: const Color(0xFF2C7FDB),
          ),
        ],
      );
    });
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.isLight,
    required this.badge,
    required this.badgeColor,
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
  });

  final bool isLight;
  final String badge;
  final Color badgeColor;
  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border:
            Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 15, color: accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 4, color: accent),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          2) CATEGORY FILTER BAR
// ══════════════════════════════════════════════════════════════════════════

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.active,
    required this.onChange,
    required this.total,
    required this.afterFilter,
    required this.isLight,
  });

  final _CategoryFilter active;
  final ValueChanged<_CategoryFilter> onChange;
  final int total;
  final int afterFilter;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _CategoryFilter.values
                .map((f) => _PillChip(
                      label: f.label(context.l10n),
                      selected: f == active,
                      onTap: () => onChange(f),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          context.l10n.whMaterialsCount(afterFilter, total),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
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

        final tabs = _StatusSegmentedTabs(
          values: _StatusFilter.values,
          counts: {
            for (final s in _StatusFilter.values) s: _statusCount(s),
          },
          selected: status,
          onChanged: onStatusChange,
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
              Row(children: [title, const Spacer(), addBtn]),
              const SizedBox(height: 10),
              tabs,
            ],
          );
        }
        return Row(
          children: [title, const Spacer(), tabs, const SizedBox(width: 10), addBtn],
        );
      }),
    );
  }
}

// ── Segmented tabs (شريط أزرق فاتح + النشط أبيض داخله) ─────────────────
class _StatusSegmentedTabs extends StatelessWidget {
  const _StatusSegmentedTabs({
    required this.values,
    required this.counts,
    required this.selected,
    required this.onChanged,
  });

  final List<_StatusFilter> values;
  final Map<_StatusFilter, int> counts;
  final _StatusFilter selected;
  final ValueChanged<_StatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE5F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: values.map((v) {
          final isActive = v == selected;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      v.label(context.l10n),
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w600,
                        color: AppColors.lightText1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${counts[v]}',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightText3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
        color: const Color(0xFFEFE3FA),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7A4FCF),
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
  });
  final List<WarehouseMaterial> rows;
  final bool isLight;
  final ValueChanged<WarehouseMaterial> onRowTap;
  final ValueChanged<WarehouseMaterial> onMovement;

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
          Expanded(flex: 2, child: _HCell(context.l10n.whColMinStock)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColExpiry)),
          Expanded(flex: 2, child: _HCell(context.l10n.whColSupplier)),
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
  });
  final WarehouseMaterial material;
  final bool isLight;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onMovement;

  String get _code => 'MAT-${material.id.padLeft(3, '0').substring(material.id.length > 3 ? material.id.length - 3 : 0)}';

  String get _expiryStr {
    final d = material.expiryDate;
    if (d == null) return '—';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
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
                  fontSize: 12.5,
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
                  fontSize: 13.5,
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
                '${material.minStock} ${material.unit}',
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
                _expiryStr,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.5,
                  color: txt3,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                material.supplier ?? '—',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.5,
                  color: txt1,
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
                child: _MovementButton(onTap: onMovement, isLight: isLight),
              ),
            ),
          ],
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
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.darkBg1,
              border: Border.all(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_vert_rounded,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  context.l10n.whMovementColumn,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
              ],
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

  Color get _color => switch (category) {
        MaterialCategory.medical => const Color(0xFF7A4FCF),
        MaterialCategory.consumables => const Color(0xFF2C7FDB),
        MaterialCategory.medicines => const Color(0xFFB44286),
        MaterialCategory.equipment => const Color(0xFF6B7280),
      };

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
              fontSize: 12.5,
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
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
