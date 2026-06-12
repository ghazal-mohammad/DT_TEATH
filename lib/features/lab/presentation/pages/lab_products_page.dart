// ════════════════════════════════════════════════════════════════════════════
// lab_products_page.dart  — إدارة منتجات المخبر (Lab Products Catalog)
//
// الفجوة #2 من تدقيق التقرير:
//   متطلب رئيس المخبر — "عرض وتعديل المنتجات التي يصنعها المخبر".
//   - عرض كتالوج المنتجات (تلبيسات/جسور/أطقم...) مع السعر ومدة التصنيع.
//   - إضافة منتج / تعديل منتج.
//   ملاحظة: لا توجد "حالة" للمنتج (قرار الفريق 2026-06-12) — الكتالوج ثابت.
//
// ملاحظة: بيانات mock حالياً — تُستبدل بـ API لاحقاً
//          (GET/POST/PUT /api/lab/products).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/data/app_data_table.dart';
import '../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MODEL + MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

/// أنواع التعويضات التي يصنّعها المخبر (قيم عربية ثابتة كباقي النظام).
const List<String> kProductTypes = ['تلبيسة', 'جسر', 'طقم', 'وجه (فينير)', 'زرعة'];

/// المواد المتاحة للتصنيع.
const List<String> kProductMaterials = [
  'Zirconia',
  'PFM',
  'E-max',
  'Metal',
  'Acrylic',
];

class LabProduct {
  LabProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.material,
    required this.price,
    required this.productionDays,
  });

  String name;
  String type;
  String material;
  int price;
  int productionDays;
  final String id;
}

List<LabProduct> _seedProducts() => [
      LabProduct(
        id: 'P-01',
        name: 'تلبيسة زيركون كاملة',
        type: 'تلبيسة',
        material: 'Zirconia',
        price: 120000,
        productionDays: 3,
      ),
      LabProduct(
        id: 'P-02',
        name: 'تلبيسة بورسلان على معدن',
        type: 'تلبيسة',
        material: 'PFM',
        price: 75000,
        productionDays: 4,
      ),
      LabProduct(
        id: 'P-03',
        name: 'جسر 3 وحدات زيركون',
        type: 'جسر',
        material: 'Zirconia',
        price: 330000,
        productionDays: 5,
      ),
      LabProduct(
        id: 'P-04',
        name: 'وجه إيماكس تجميلي',
        type: 'وجه (فينير)',
        material: 'E-max',
        price: 95000,
        productionDays: 4,
      ),
      LabProduct(
        id: 'P-05',
        name: 'طقم أكريل كامل',
        type: 'طقم',
        material: 'Acrylic',
        price: 250000,
        productionDays: 7,
      ),
      LabProduct(
        id: 'P-06',
        name: 'تلبيسة معدنية',
        type: 'تلبيسة',
        material: 'Metal',
        price: 45000,
        productionDays: 2,
      ),
    ];

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabProductsPage extends StatefulWidget {
  const LabProductsPage({super.key});

  @override
  State<LabProductsPage> createState() => _LabProductsPageState();
}

class _LabProductsPageState extends State<LabProductsPage> {
  late List<LabProduct> _products;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _products = _seedProducts();
  }

  List<LabProduct> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return _products;
    return _products
        .where((p) => p.name.contains(q) || p.type.contains(q))
        .toList();
  }

  Future<void> _onAdd() async {
    final result = await LabProductFormDialog.show(context, null);
    if (result == null) return;
    setState(() {
      _products.add(LabProduct(
        id: 'P-${DateTime.now().millisecondsSinceEpoch % 100000}',
        name: result.name,
        type: result.type,
        material: result.material,
        price: result.price,
        productionDays: result.productionDays,
      ));
    });
  }

  Future<void> _onEdit(LabProduct p) async {
    final result = await LabProductFormDialog.show(context, p);
    if (result == null) return;
    setState(() {
      p.name = result.name;
      p.type = result.type;
      p.material = result.material;
      p.price = result.price;
      p.productionDays = result.productionDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labProducts,
      sections: LabSidebarSections.build(context),
      pageTitle: l10n.labProducts,
      pageSubtitle: l10n.labTopbarSubtitle,
      searchPlaceholder: l10n.labProductsSearchHint,
      onSearchChanged: (v) => setState(() => _query = v),
      userName: MockUserData.labUserName,
      userRole: l10n.roleLabManager,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatsRow(total: _products.length),
            const SizedBox(height: AppSizes.spaceLG),
            AppPageActionBar(
              filter: const SizedBox.shrink(),
              actions: [
                AppButton.primary(
                  label: '+ ${l10n.labProdAdd}',
                  onPressed: _onAdd,
                  size: AppButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceMD),
            _ProductsTable(
              products: _filtered,
              onEdit: _onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STATS ROW
// ══════════════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StatCard(
      accent: AppColors.statusProgress,
      icon: Icons.category_outlined,
      value: '$total',
      label: l10n.labProdTotal,
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
                          color: isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1,
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
//  PRODUCTS TABLE
// ══════════════════════════════════════════════════════════════════════════

class _ProductsTable extends StatelessWidget {
  const _ProductsTable({
    required this.products,
    required this.onEdit,
  });

  final List<LabProduct> products;
  final void Function(LabProduct) onEdit;

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
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: AppDataTable<LabProduct>(
          data: products,
          headerBackground: isLight ? AppColors.tableHeader : AppColors.darkBg2,
          emptyMessage: l10n.labProdEmpty,
          emptyIcon: Icons.category_outlined,
          columns: [
            AppDataColumn<LabProduct>(
              label: l10n.labProdFieldName,
              flex: 3,
              cellBuilder: (p) => Text(
                p.name,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.labProdColType,
              flex: 2,
              cellBuilder: (p) =>
                  Text(p.type, style: AppTextStyles.bodyMedium),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.colMaterial,
              flex: 2,
              cellBuilder: (p) =>
                  Text(p.material, style: AppTextStyles.bodyMedium),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.labProdColPrice,
              flex: 2,
              cellBuilder: (p) => Text(
                _formatPrice(p.price),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
            ),
            AppDataColumn<LabProduct>(
              label: l10n.labProdColDuration,
              flex: 2,
              cellBuilder: (p) => Text(
                '${p.productionDays} ${l10n.labProdDaysUnit}',
                style: AppTextStyles.bodySmall,
              ),
            ),
            AppDataColumn<LabProduct>(
              label: '',
              flex: 2,
              cellBuilder: (p) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: _IconAction(
                  icon: Icons.edit_outlined,
                  tooltip: l10n.labProdEditTitle,
                  onTap: () => onEdit(p),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 32,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLight ? Colors.white : AppColors.darkBg1,
              border: Border.all(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Icon(
              icon,
              size: 17,
              color: color ??
                  (isLight ? AppColors.lightText2 : AppColors.darkText2),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  PRODUCT FORM DIALOG (add / edit)
// ══════════════════════════════════════════════════════════════════════════

class LabProductFormResult {
  LabProductFormResult({
    required this.name,
    required this.type,
    required this.material,
    required this.price,
    required this.productionDays,
  });

  final String name;
  final String type;
  final String material;
  final int price;
  final int productionDays;
}

class LabProductFormDialog extends StatefulWidget {
  const LabProductFormDialog({super.key, this.existing});
  final LabProduct? existing;

  static Future<LabProductFormResult?> show(
    BuildContext context,
    LabProduct? existing,
  ) {
    return showDialog<LabProductFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabProductFormDialog(existing: existing),
    );
  }

  @override
  State<LabProductFormDialog> createState() => _LabProductFormDialogState();
}

class _LabProductFormDialogState extends State<LabProductFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _days;
  late String _type;
  late String _material;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _days = TextEditingController(text: e?.productionDays.toString() ?? '');
    _type = e?.type ?? kProductTypes.first;
    _material = e?.material ?? kProductMaterials.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _days.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = l10n.labProdNameRequired);
      return;
    }
    Navigator.of(context).pop(LabProductFormResult(
      name: _name.text.trim(),
      type: _type,
      material: _material,
      price: int.tryParse(_price.text.trim()) ?? 0,
      productionDays: int.tryParse(_days.text.trim()) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? l10n.labProdAddTitle
                    : l10n.labProdEditTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _label(l10n.labProdFieldName, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                autofocus: true,
                decoration: _decoration(errorText: _nameError),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldType, isLight),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _type,
                          items: kProductTypes,
                          onChanged: (v) => setState(() => _type = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldMaterial, isLight),
                        const SizedBox(height: 6),
                        _dropdown(
                          value: _material,
                          items: kProductMaterials,
                          onChanged: (v) => setState(() => _material = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldPrice, isLight),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _price,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _decoration(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labProdFieldDuration, isLight),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _days,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _decoration(),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _label(String text, bool isLight) => Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.lightText1 : AppColors.darkText1,
        ),
      );

  InputDecoration _decoration({String? errorText}) => InputDecoration(
        errorText: errorText,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      );

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isLight =
        Theme.of(context).brightness == Brightness.light;
    return AppDropdownMenuTheme(
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: _decoration(),
        dropdownColor: isLight ? Colors.white : AppColors.darkBg1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
