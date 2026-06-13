// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_page.dart  — Phase 5.7 ✅
//
// صفحة طلبات المواد من المستودع — من منظور المخبر.
// المخبر يرسل طلبات للمستودع عند نقص المواد في المخبر.
//
// الهيكل:
//   - 4 filter chips (الكل / جديد / تم التسليم / غير متوفر)
//   - قائمة طلبات مع: رقم الطلب / المادة / الكمية / تاريخ الطلب / الحالة / إجراء
//   - زر "طلب مادة جديدة" → فورم (اسم / كمية+وحدة / اسم الشركة / السبب)
//     قرار الفريق 2026-06-12: المادة غير الموجودة بالمستودع تُطلب بهذا الفورم
//     وتظهر عند المستودع كمادة معلّقة بانتظار الإضافة.
//
// المرجع: DT_Teeth_Technical_Decision_Guide_v5.md — القرار 30 (Reference Integrity)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/forms/app_form_select.dart';
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
    this.company,
    this.reason,
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

  /// اسم الشركة المصنّعة (للمواد الجديدة غير الموجودة بالمستودع).
  final String? company;

  /// سبب الطلب — يُعرض للمستودع ليعرف ليش المخبر طالب المادة.
  final String? reason;
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

  // القائمة محلية ليُضاف عليها الطلب الجديد فوراً — تُستبدل بـ API لاحقاً.
  final List<_MatRequest> _requests = [..._kRequests];

  List<_MatRequest> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _requests
            .where((r) => r.status == _MatRequestStatus.newRequest)
            .toList();
      case 2:
        return _requests
            .where((r) => r.status == _MatRequestStatus.delivered)
            .toList();
      case 3:
        return _requests
            .where((r) => r.status == _MatRequestStatus.unavailable)
            .toList();
      default:
        return _requests;
    }
  }

  /// فتح فورم "طلب مادة جديدة" وإدراج النتيجة بأعلى القائمة.
  Future<void> _onNewRequest() async {
    final r = await LabMaterialRequestDialog.show(context);
    if (r == null || !mounted) return;
    setState(() {
      _requests.insert(
        0,
        _MatRequest(
          id: 'MR-${(_requests.length + 1).toString().padLeft(3, '0')}',
          material: r.material,
          quantity: r.quantity,
          unit: r.unit,
          requestedBy: MockUserData.labUserName,
          date: DateTime.now().toIso8601String().substring(0, 10),
          status: _MatRequestStatus.newRequest,
          company: r.company,
          reason: r.reason,
        ),
      );
      _filterIndex = 0; // ليظهر الطلب الجديد مباشرة
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.labReqSentSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShellLayout(
      system: AppSystemType.lab,
      currentRoute: RouteNames.labMaterialRequests,
      sections: LabSidebarSections.build(context),
      pageTitle: context.l10n.materialRequests,
      pageSubtitle: context.l10n.labTopbarSubtitle,
      userRole: context.l10n.roleLabManager,
      body: _MaterialRequestsBody(
        filterIndex: _filterIndex,
        onFilterChanged: (i) => setState(() => _filterIndex = i),
        requests: _filtered,
        onNewRequest: _onNewRequest,
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
    required this.onNewRequest,
  });

  final int filterIndex;
  final ValueChanged<int> onFilterChanged;
  final List<_MatRequest> requests;
  final VoidCallback onNewRequest;

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
              options: [
                l10n.labOrdersFilterAll,
                l10n.statusNew,
                l10n.statusDelivered,
                l10n.labReqStatusUnavailable,
              ],
              selectedIndex: filterIndex,
              onChanged: onFilterChanged,
            ),
            actions: [
              AppButton.primary(
                label: '+ ${l10n.labReqNewRequest}',
                onPressed: onNewRequest,
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
        return context.l10n.statusNew;
      case _MatRequestStatus.delivered:
        return context.l10n.statusDelivered;
      case _MatRequestStatus.unavailable:
        return context.l10n.labReqStatusUnavailable;
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
                  _cell(context, icon: AppIcons.box, label: context.l10n.colQuantity, value: '${r.quantity} ${r.unit}'),
                  const SizedBox(width: AppSizes.spaceXL),
                  _cell(context, icon: AppIcons.profile, label: context.l10n.labReqRequestedBy, value: r.requestedBy, valueColor: AppColors.secondary),
                  const SizedBox(width: AppSizes.spaceXL),
                  _cell(context, icon: AppIcons.calendar, label: context.l10n.ordersDate, value: r.date),
                  if (r.company != null && r.company!.isNotEmpty) ...[
                    const SizedBox(width: AppSizes.spaceXL),
                    _cell(context, icon: AppIcons.box, label: context.l10n.labReqFieldCompany, value: r.company!),
                  ],
                  if (r.labOrderId != null) ...[
                    const SizedBox(width: AppSizes.spaceXL),
                    _cell(context, icon: AppIcons.labOrders, label: context.l10n.labReqLabOrder, value: r.labOrderId!, valueColor: AppColors.accent),
                  ],
                  const Spacer(),
                  if (r.status == _MatRequestStatus.newRequest)
                    AppButton.secondary(
                      label: context.l10n.labActionTrack,
                      icon: AppIcons.eye,
                      onPressed: () {},
                      size: AppButtonSize.small,
                    ),
                ],
              ),
              // سبب الطلب (للمواد الجديدة) — صندوق معلوماتي محايد.
              if (r.reason != null && r.reason!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceSM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceMD,
                    vertical: AppSizes.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusInfo.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(
                        color: AppColors.statusInfo.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 12, color: AppColors.statusInfo),
                      const SizedBox(width: AppSizes.spaceXS),
                      Expanded(
                        child: Text(
                          '${context.l10n.labReqFieldReason}: ${r.reason!}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.statusInfo),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          Icon(
            AppIcons.emptyInbox,
            size: 48,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightText4
                : AppColors.darkText4,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          Text(context.l10n.labReqEmptyCategory, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  NEW MATERIAL REQUEST DIALOG — اسم / كمية+وحدة / اسم الشركة / السبب
//  قرار الفريق 2026-06-12: المادة غير الموجودة بالمستودع تُطلب بهذا الفورم
//  وتظهر عند المستودع كمادة معلّقة بانتظار الإضافة.
// ══════════════════════════════════════════════════════════════════════════

/// وحدات القياس المتاحة لطلب المواد (نفس وحدات مخزون المخبر).
const List<String> kMatRequestUnits = [
  'علبة',
  'بلوك',
  'كيلو',
  'غرام',
  'قطعة',
  'أنبوب',
  'زجاجة',
];

class LabMaterialRequestResult {
  const LabMaterialRequestResult({
    required this.material,
    required this.quantity,
    required this.unit,
    this.company,
    this.reason,
  });

  final String material;
  final String quantity;
  final String unit;
  final String? company;
  final String? reason;
}

class LabMaterialRequestDialog extends StatefulWidget {
  const LabMaterialRequestDialog({super.key});

  static Future<LabMaterialRequestResult?> show(BuildContext context) {
    return showDialog<LabMaterialRequestResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LabMaterialRequestDialog(),
    );
  }

  @override
  State<LabMaterialRequestDialog> createState() =>
      _LabMaterialRequestDialogState();
}

class _LabMaterialRequestDialogState extends State<LabMaterialRequestDialog> {
  final TextEditingController _material = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _company = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  String _unit = kMatRequestUnits.first;
  String? _materialError;
  String? _quantityError;

  @override
  void dispose() {
    _material.dispose();
    _quantity.dispose();
    _company.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = context.l10n;
    final name = _material.text.trim();
    final qty = int.tryParse(_quantity.text.trim()) ?? 0;
    setState(() {
      _materialError = name.isEmpty ? l10n.labReqMaterialRequired : null;
      _quantityError = qty <= 0 ? l10n.labReqQuantityRequired : null;
    });
    if (_materialError != null || _quantityError != null) return;
    final company = _company.text.trim();
    final reason = _reason.text.trim();
    Navigator.of(context).pop(LabMaterialRequestResult(
      material: name,
      quantity: '$qty',
      unit: _unit,
      company: company.isEmpty ? null : company,
      reason: reason.isEmpty ? null : reason,
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
                l10n.labReqNewRequest,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _label(l10n.labReqFieldMaterial, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _material,
                autofocus: true,
                decoration: _decoration(errorText: _materialError),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.colQuantity, isLight),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _quantity,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _decoration(errorText: _quantityError),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label(l10n.labReqFieldUnit, isLight),
                        const SizedBox(height: 6),
                        AppDropdownMenuTheme(
                          child: DropdownButtonFormField<String>(
                            initialValue: _unit,
                            isExpanded: true,
                            decoration: _decoration(),
                            dropdownColor:
                                isLight ? Colors.white : AppColors.darkBg1,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusLG),
                            items: [
                              for (final u in kMatRequestUnits)
                                DropdownMenuItem(value: u, child: Text(u)),
                            ],
                            onChanged: (v) =>
                                setState(() => _unit = v ?? _unit),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spaceMD),
              _label(l10n.labReqFieldCompany, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _company,
                decoration: _decoration(),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              _label(l10n.labReqFieldReason, isLight),
              const SizedBox(height: 6),
              TextField(
                controller: _reason,
                maxLines: 2,
                decoration: _decoration(hintText: l10n.labReqReasonHint),
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
                    label: l10n.labReqSubmit,
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

  InputDecoration _decoration({String? errorText, String? hintText}) =>
      InputDecoration(
        errorText: errorText,
        hintText: hintText,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
      );
}
