// ════════════════════════════════════════════════════════════════════════════
// lab_products_page.dart  — إدارة منتجات المخبر (Lab Products Catalog)
//
// الفجوة #2 من تدقيق التقرير:
//   متطلب رئيس المخبر — "عرض وتعديل المنتجات التي يصنعها المخبر".
//   - عرض كتالوج المنتجات (تلبيسات/جسور/أطقم...) مع السعر ومدة التصنيع.
//   - إضافة منتج / تعديل منتج.
//   ملاحظة: لا توجد "حالة" للمنتج (قرار الفريق 2026-06-12) — الكتالوج ثابت.
//
// النموذج والبيانات في widgets/products/lab_product_data.dart، وبطاقة الإحصاء
// والجدول والمودال في widgets/products/ (تقسيم الصفحات العملاقة).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/products/lab_product_data.dart';
import '../widgets/products/lab_product_form_dialog.dart';
import '../widgets/products/lab_products_stats.dart';
import '../widgets/products/lab_products_table.dart';

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
    _products = labProductsSeed();
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
      userRole: l10n.roleLabManager,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabProductsStatsRow(total: _products.length),
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
            LabProductsTable(
              products: _filtered,
              onEdit: _onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
