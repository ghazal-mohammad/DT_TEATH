// ════════════════════════════════════════════════════════════════════════════
// lab_inventory_page.dart  — مخزون المخبر (Lab Internal Inventory)
//
// الفجوة #1 من تدقيق التقرير (UC72 / UC73 / UC75):
//   - عرض المواد المتبقّية داخل المخبر (مخزون داخلي مستقل عن المستودع).
//   - فلترة حسب الفئة + بحث محلي.
//   - "تسجيل استهلاك" (إنقاص كمية مادة) — يطابق UC75.
//
// ملاحظة: بيانات mock حالياً — تُستبدل بـ API في مرحلة الربط
//          (GET /api/lab/inventory · POST /api/lab/inventory/{id}/consume).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/data/app_data_table.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../data/lab_inventory_store.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  CATEGORY LABEL — البيانات نفسها في LabInventoryStore (مصدر مشترك)
// ══════════════════════════════════════════════════════════════════════════

extension LabCatLabel on LabMaterialCategory {
  String label(AppLocalizations l10n) => switch (this) {
        LabMaterialCategory.medical => l10n.whCategoryMedical,
        LabMaterialCategory.consumables => l10n.whCategoryConsumables,
        LabMaterialCategory.medicines => l10n.whCategoryMedicines,
        LabMaterialCategory.metals => l10n.whCategoryEquipment,
      };
}

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabInventoryPage extends StatefulWidget {
  const LabInventoryPage({super.key});

  @override
  State<LabInventoryPage> createState() => _LabInventoryPageState();
}

class _LabInventoryPageState extends State<LabInventoryPage> {
  final LabInventoryStore _store = LabInventoryStore.instance;
  int _catIndex = 0; // 0 = الكل، ثم حسب ترتيب LabMaterialCategory
  String _query = '';

  List<LabMaterial> get _filtered {
    Iterable<LabMaterial> list = _store.items;
    if (_catIndex > 0) {
      final cat = LabMaterialCategory.values[_catIndex - 1];
      list = list.where((m) => m.category == cat);
    }
    final q = _query.trim();
    if (q.isNotEmpty) {
      list = list.where((m) => m.name.contains(q));
    }
    return list.toList();
  }

  Future<void> _onConsume(LabMaterial m) async {
    final amount = await _ConsumeDialog.show(context, m);
    if (amount == null) return;
    _store.consume(m.id, amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labInventory,
      sections: LabSidebarSections.build(context),
      pageTitle: l10n.labInventory,
      pageSubtitle: l10n.labTopbarSubtitle,
      searchPlaceholder: l10n.labInvSearchHint,
      onSearchChanged: (v) => setState(() => _query = v),
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
      // يعيد البناء تلقائياً عند نقص المخزون من أي مكان (مثل إنجاز طلبية).
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final low =
              _store.items.where((m) => m.status == LabStockStatus.low).length;
          final out =
              _store.items.where((m) => m.status == LabStockStatus.out).length;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatsRow(total: _store.items.length, low: low, out: out),
                const SizedBox(height: AppSizes.spaceLG),
                _InventoryCard(
                  catIndex: _catIndex,
                  onCatChanged: (i) => setState(() => _catIndex = i),
                  materials: _filtered,
                  onConsume: _onConsume,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STAT CARDS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.total, required this.low, required this.out});

  final int total;
  final int low;
  final int out;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = [
      _StatCard(
        accent: const Color(0xFF3B82F6),
        icon: Icons.inventory_2_outlined,
        value: '$total',
        label: l10n.labInvTotal,
      ),
      _StatCard(
        accent: const Color(0xFFF59E0B),
        icon: Icons.trending_down_rounded,
        value: '$low',
        label: l10n.labInvLow,
      ),
      _StatCard(
        accent: const Color(0xFFEF4444),
        icon: Icons.error_outline_rounded,
        value: '$out',
        label: l10n.labInvOut,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 800) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.spaceMD),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (final card in cards) ...[
              card,
              const SizedBox(height: AppSizes.spaceMD),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.accent,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color accent;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final radius = BorderRadius.circular(AppSizes.radiusLG);
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: radius,
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4, color: accent),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color:
                              isLight ? AppColors.lightText1 : AppColors.darkText1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isLight
                              ? AppColors.lightText3
                              : AppColors.darkText3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  INVENTORY CARD (filter chips + table)
// ══════════════════════════════════════════════════════════════════════════

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.catIndex,
    required this.onCatChanged,
    required this.materials,
    required this.onConsume,
  });

  final int catIndex;
  final ValueChanged<int> onCatChanged;
  final List<LabMaterial> materials;
  final void Function(LabMaterial) onConsume;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: عنوان + chips الفئات
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
              AppSizes.spaceMD,
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 20,
                    color: isLight ? AppColors.primary : AppColors.darkText1),
                const SizedBox(width: 8),
                Text(
                  l10n.labInventory,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: AppFilterChipRow(
                    options: [
                      l10n.labOrdersFilterAll,
                      l10n.whCategoryMedical,
                      l10n.whCategoryConsumables,
                      l10n.whCategoryMedicines,
                      l10n.whCategoryEquipment,
                    ],
                    selectedIndex: catIndex,
                    onChanged: onCatChanged,
                  ),
                ),
              ],
            ),
          ),
          // Table
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG,
              0,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
            ),
            child: AppDataTable<LabMaterial>(
              data: materials,
              headerBackground:
                  isLight ? AppColors.tableHeader : AppColors.darkBg2,
              emptyMessage: l10n.labInvEmpty,
              emptyIcon: Icons.inventory_2_outlined,
              columns: [
                AppDataColumn<LabMaterial>(
                  label: l10n.colMaterial,
                  flex: 3,
                  cellBuilder: (m) => Text(
                    m.name,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1,
                    ),
                  ),
                ),
                AppDataColumn<LabMaterial>(
                  label: l10n.labInvColCategory,
                  flex: 2,
                  cellBuilder: (m) => Text(
                    m.category.label(l10n),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                AppDataColumn<LabMaterial>(
                  label: l10n.whColStock,
                  flex: 2,
                  cellBuilder: (m) => Text(
                    '${m.quantity} ${m.unit}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          isLight ? AppColors.lightText1 : AppColors.darkText1,
                    ),
                  ),
                ),
                AppDataColumn<LabMaterial>(
                  label: l10n.whColMinStock,
                  flex: 2,
                  cellBuilder: (m) => Text(
                    '${m.minStock} ${m.unit}',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                AppDataColumn<LabMaterial>(
                  label: l10n.colStatus,
                  flex: 2,
                  cellBuilder: (m) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _statusBadge(context, m.status),
                  ),
                ),
                AppDataColumn<LabMaterial>(
                  label: '',
                  flex: 2,
                  cellBuilder: (m) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppButton.secondary(
                      label: l10n.labInvConsume,
                      icon: Icons.remove_circle_outline_rounded,
                      onPressed: m.quantity <= 0 ? null : () => onConsume(m),
                      size: AppButtonSize.small,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, LabStockStatus s) {
    final l10n = context.l10n;
    switch (s) {
      case LabStockStatus.available:
        return AppBadge(text: l10n.whStatusAvailable, variant: AppBadgeVariant.green);
      case LabStockStatus.low:
        return AppBadge(text: l10n.whStatusLow, variant: AppBadgeVariant.gold);
      case LabStockStatus.out:
        return AppBadge(
            text: l10n.whStatusOut, variant: AppBadgeVariant.redAnimated);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CONSUME DIALOG — تسجيل استهلاك (إنقاص كمية)
// ══════════════════════════════════════════════════════════════════════════

class _ConsumeDialog extends StatefulWidget {
  const _ConsumeDialog({required this.material});
  final LabMaterial material;

  static Future<int?> show(BuildContext context, LabMaterial material) {
    return showDialog<int>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => _ConsumeDialog(material: material),
    );
  }

  @override
  State<_ConsumeDialog> createState() => _ConsumeDialogState();
}

class _ConsumeDialogState extends State<_ConsumeDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final raw = _controller.text.trim();
    final value = int.tryParse(raw);
    if (value == null || value <= 0) {
      setState(() => _error = l10n.labInvConsumeInvalid);
      return;
    }
    if (value > widget.material.quantity) {
      setState(() => _error = l10n.labInvConsumeExceeds);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final m = widget.material;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labInvConsumeTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${m.name} — ${l10n.labInvCurrentQty}: ${m.quantity} ${m.unit}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Text(
                l10n.labInvConsumeAmount,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: l10n.labInvConsumeHint,
                  errorText: _error,
                  suffixText: m.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton.primary(
                    label: l10n.save,
                    onPressed: _submit,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
