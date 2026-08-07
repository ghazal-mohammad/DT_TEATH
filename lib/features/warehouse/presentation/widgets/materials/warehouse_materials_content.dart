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
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';
import '../../../domain/entities/material_category.dart';
import '../../../domain/entities/material_status.dart';
import '../../../domain/entities/warehouse_material.dart';
import '../../bloc/materials_cubit.dart';
import '../../bloc/materials_state.dart';
import 'warehouse_material_form_dialog.dart';
import 'warehouse_material_stock_dialog.dart';

part 'warehouse_materials_stats.dart';
part 'warehouse_materials_filters.dart';
part 'warehouse_materials_table.dart';

// ══════════════════════════════════════════════════════════════════════════
//                             LOCAL FILTERS
// ══════════════════════════════════════════════════════════════════════════

enum _CategoryFilter { all, clinic, lab, both }

extension on _CategoryFilter {
  String label(AppLocalizations l10n) => switch (this) {
        _CategoryFilter.all => l10n.whFilterAll,
        _CategoryFilter.clinic => l10n.whCategoryClinic,
        _CategoryFilter.lab => l10n.whCategoryLab,
        _CategoryFilter.both => l10n.whCategoryBoth,
      };

  bool matches(WarehouseMaterial m) {
    switch (this) {
      case _CategoryFilter.all:
        return true;
      case _CategoryFilter.clinic:
        return m.category == MaterialCategory.clinic;
      case _CategoryFilter.lab:
        return m.category == MaterialCategory.lab;
      case _CategoryFilter.both:
        return m.category == MaterialCategory.both;
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

  /// إدارة مخزون المادة عبر الدفعات (إضافة دفعة / تعديل كمية) — مربوط بالباك.
  /// عند حدوث تغيير نُعيد تحميل قائمة المواد ليعكس الإجمالي الجديد.
  Future<void> _openMovement(BuildContext context,
      WarehouseMaterial material) async {
    final cubit = context.read<MaterialsCubit>();
    final changed =
        await WarehouseMaterialStockDialog.show(context, material);
    if (changed) await cubit.load();
  }
}
