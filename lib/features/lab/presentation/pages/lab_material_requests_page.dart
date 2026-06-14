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
//
// النموذج والبيانات في widgets/material_requests/lab_mat_request_data.dart،
// والبطاقة والمودال والحالة الفارغة في widgets/material_requests/ (تقسيم الصفحات).
//
// المرجع: DT_Teeth_Technical_Decision_Guide_v5.md — القرار 30 (Reference Integrity)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/material_requests/lab_mat_request_card.dart';
import '../widgets/material_requests/lab_mat_request_data.dart';
import '../widgets/material_requests/lab_mat_request_dialog.dart';
import '../widgets/material_requests/lab_mat_requests_empty.dart';

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
  final List<MatRequest> _requests = [...kLabMatRequestsSeed];

  List<MatRequest> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _requests
            .where((r) => r.status == MatRequestStatus.newRequest)
            .toList();
      case 2:
        return _requests
            .where((r) => r.status == MatRequestStatus.delivered)
            .toList();
      case 3:
        return _requests
            .where((r) => r.status == MatRequestStatus.unavailable)
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
        MatRequest(
          id: 'MR-${(_requests.length + 1).toString().padLeft(3, '0')}',
          material: r.material,
          quantity: r.quantity,
          unit: r.unit,
          requestedBy: MockUserData.labUserName,
          date: DateTime.now().toIso8601String().substring(0, 10),
          status: MatRequestStatus.newRequest,
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
  final List<MatRequest> requests;
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
            const LabMatRequestsEmpty()
          else
            for (final req in requests) ...[
              LabMatRequestCard(request: req),
              const SizedBox(height: AppSizes.spaceMD),
            ],
        ],
      ),
    );
  }
}
