// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_page.dart  — Phase 5.7 ✅
//
// صفحة طلبات المواد من المستودع — من منظور المخبر.
// المخبر يرسل طلبات للمستودع عند نقص المواد في المخبر.
//
// الهيكل:
//   - 4 filter chips (الكل / جديد / تم التسليم / غير متوفر)
//   - قائمة طلبات مع: رقم الطلب / المادة / الكمية / تاريخ الطلب / الحالة / إجراء
//   - زر "طلب مادة جديدة"
//
// المرجع: DT_Teeth_Technical_Decision_Guide_v5.md — القرار 30 (Reference Integrity)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_badge.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../navigation/lab_sidebar_sections.dart';

// ══════════════════════════════════════════════════════════════════════════
//  MOCK DATA
// ══════════════════════════════════════════════════════════════════════════

enum _MatRequestStatus { newRequest, delivered, unavailable }

class _MatRequest {
  const _MatRequest({
    required this.id,
    required this.material,
    required this.quantity,
    required this.unit,
    required this.requestedBy,
    required this.date,
    required this.status,
    this.labOrderId,
    this.note,
  });
  final String id;
  final String material;
  final String quantity;
  final String unit;
  final String requestedBy;
  final String date;
  final _MatRequestStatus status;
  final String? labOrderId;
  final String? note;
}

const _kRequests = [
  _MatRequest(
    id: 'MR-001',
    material: 'زركون بلوك A3',
    quantity: '3',
    unit: 'بلوك',
    requestedBy: 'هشام علي',
    date: '2026-05-10',
    status: _MatRequestStatus.newRequest,
    labOrderId: 'LAB-143',
  ),
  _MatRequest(
    id: 'MR-002',
    material: 'غراء طبي أبيض',
    quantity: '2',
    unit: 'أنبوب',
    requestedBy: 'سامر شماع',
    date: '2026-05-09',
    status: _MatRequestStatus.delivered,
    labOrderId: 'LAB-129',
  ),
  _MatRequest(
    id: 'MR-003',
    material: 'سيليكون طبع A-Type',
    quantity: '1',
    unit: 'كيلو',
    requestedBy: 'أيار كريم',
    date: '2026-05-09',
    status: _MatRequestStatus.unavailable,
    note: 'المادة غير موجودة — طُلبت من المورد',
  ),
  _MatRequest(
    id: 'MR-004',
    material: 'أسلاك ربط أورثو',
    quantity: '10',
    unit: 'قطعة',
    requestedBy: 'هشام علي',
    date: '2026-05-08',
    status: _MatRequestStatus.delivered,
    labOrderId: 'LAB-182',
  ),
  _MatRequest(
    id: 'MR-005',
    material: 'ورنيش PFM',
    quantity: '1',
    unit: 'زجاجة',
    requestedBy: 'سامر شماع',
    date: '2026-05-07',
    status: _MatRequestStatus.newRequest,
    labOrderId: 'LAB-168',
  ),
];

// ══════════════════════════════════════════════════════════════════════════
//  PAGE
// ══════════════════════════════════════════════════════════════════════════

class LabMaterialRequestsPage extends StatefulWidget {
  const LabMaterialRequestsPage({super.key});

  @override
  State<LabMaterialRequestsPage> createState() =>
      _LabMaterialRequestsPageState();
}

class _LabMaterialRequestsPageState extends State<LabMaterialRequestsPage> {
  int _filterIndex = 0; // 0=الكل 1=جديد 2=تم التسليم 3=غير متوفر

  List<_MatRequest> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _kRequests
            .where((r) => r.status == _MatRequestStatus.newRequest)
            .toList();
      case 2:
        return _kRequests
            .where((r) => r.status == _MatRequestStatus.delivered)
            .toList();
      case 3:
        return _kRequests
            .where((r) => r.status == _MatRequestStatus.unavailable)
            .toList();
      default:
        return _kRequests;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labMaterialRequests,
      sections: LabSidebarSections.build(context),
      pageTitle: context.l10n.materialRequests,
      pageSubtitle: context.l10n.labTopbarSubtitle,
      userName: MockUserData.labUserName,
      userRole: context.l10n.roleLabManager,
      body: _MaterialRequestsBody(
        filterIndex: _filterIndex,
        onFilterChanged: (i) => setState(() => _filterIndex = i),
        requests: _filtered,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BODY
// ══════════════════════════════════════════════════════════════════════════

class _MaterialRequestsBody extends StatelessWidget {
  const _MaterialRequestsBody({
    required this.filterIndex,
    required this.onFilterChanged,
    required this.requests,
  });

  final int filterIndex;
  final ValueChanged<int> onFilterChanged;
  final List<_MatRequest> requests;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Filter Bar + Action ────────────────────────────────────
          AppPageActionBar(
            filter: AppFilterChipRow(
              options: const ['الكل', 'جديد', 'تم التسليم', 'غير متوفر'],
              selectedIndex: filterIndex,
              onChanged: onFilterChanged,
            ),
            actions: [
              AppButton.primary(
                label: '+ طلب مادة جديدة',
                onPressed: () => _showNewRequestDialog(context, l10n),
                size: AppButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLG),

          // ── Requests List ──────────────────────────────────────────
          if (requests.isEmpty)
            _EmptyRequests()
          else
            for (final req in requests) ...[
              _MatRequestCard(request: req),
              const SizedBox(height: AppSizes.spaceMD),
            ],
        ],
      ),
    );
  }

  void _showNewRequestDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightSurface
            : AppColors.darkSurface,
        title: Text(
          'طلب مادة جديدة',
          style: AppTextStyles.headlineSmall,
        ),
        content: const SizedBox(
          width: 400,
          child: Text(
            'سيتم إضافة نموذج طلب المواد هنا في الإصدار القادم.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  REQUEST CARD
// ══════════════════════════════════════════════════════════════════════════

class _MatRequestCard extends StatefulWidget {
  const _MatRequestCard({required this.request});
  final _MatRequest request;

  @override
  State<_MatRequestCard> createState() => _MatRequestCardState();
}

class _MatRequestCardState extends State<_MatRequestCard> {
  bool _hovered = false;

  Color get _accentColor {
    switch (widget.request.status) {
      case _MatRequestStatus.newRequest:
        return AppColors.accent;
      case _MatRequestStatus.delivered:
        return AppColors.success;
      case _MatRequestStatus.unavailable:
        return AppColors.error;
    }
  }

  AppBadgeVariant get _badgeVariant {
    switch (widget.request.status) {
      case _MatRequestStatus.newRequest:
        return AppBadgeVariant.cyan;
      case _MatRequestStatus.delivered:
        return AppBadgeVariant.green;
      case _MatRequestStatus.unavailable:
        return AppBadgeVariant.redAnimated;
    }
  }

  String _badgeText(BuildContext context) {
    switch (widget.request.status) {
      case _MatRequestStatus.newRequest:
        return 'جديد';
      case _MatRequestStatus.delivered:
        return 'تم التسليم';
      case _MatRequestStatus.unavailable:
        return 'غير متوفر';
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          // الشريط الملوّن على الحافة اليسرى البصرية (مطابق لباقي بطاقات النظام).
          border: Border(
            left: BorderSide(color: _accentColor, width: 3),
            top: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            bottom: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            right: BorderSide(
              color: _hovered
                  ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                  : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _accentColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: معرف الطلب + المادة + الحالة
              Row(
                children: [
                  Text(
                    r.id,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSM),
                  Expanded(
                    child: Text(
                      r.material,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppBadge(text: _badgeText(context), variant: _badgeVariant),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMD),
              const Divider(height: 1, color: AppColors.darkBorder),
              const SizedBox(height: AppSizes.spaceMD),
              // Row 2: التفاصيل
              Row(
                children: [
                  _cell(context, icon: AppIcons.box, label: 'الكمية', value: '${r.quantity} ${r.unit}'),
                  const SizedBox(width: AppSizes.spaceXL),
                  _cell(context, icon: AppIcons.profile, label: 'طلب بواسطة', value: r.requestedBy, valueColor: AppColors.secondary),
                  const SizedBox(width: AppSizes.spaceXL),
                  _cell(context, icon: AppIcons.calendar, label: 'التاريخ', value: r.date),
                  if (r.labOrderId != null) ...[
                    const SizedBox(width: AppSizes.spaceXL),
                    _cell(context, icon: AppIcons.labOrders, label: 'طلبية المخبر', value: r.labOrderId!, valueColor: AppColors.accent),
                  ],
                  const Spacer(),
                  if (r.status == _MatRequestStatus.newRequest)
                    AppButton.secondary(
                      label: 'تتبع',
                      icon: AppIcons.eye,
                      onPressed: () {},
                      size: AppButtonSize.small,
                    ),
                ],
              ),
              // Note if unavailable
              if (r.note != null) ...[
                const SizedBox(height: AppSizes.spaceSM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceMD,
                    vertical: AppSizes.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(AppIcons.warning, size: 12, color: AppColors.error),
                      const SizedBox(width: AppSizes.spaceXS),
                      Text(
                        r.note!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: isLight ? AppColors.lightText4 : AppColors.darkText4),
            const SizedBox(width: 3),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isLight ? AppColors.lightText4 : AppColors.darkText4,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? (isLight ? AppColors.lightText1 : AppColors.darkText1),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════

class _EmptyRequests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(AppIcons.emptyInbox, size: 48, color: AppColors.darkText4),
          const SizedBox(height: AppSizes.spaceMD),
          Text('لا توجد طلبيات مواد في هذه الفئة', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
