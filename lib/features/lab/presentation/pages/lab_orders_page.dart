// ════════════════════════════════════════════════════════════════════════════
// lab_orders_page.dart  — Lab Orders (طلبات الأطباء)
//
// شبكة بطاقات طلبيات الأطباء (فلاتر + بطاقات + مودالات تفاصيل/معالجة).
//
// المعمارية (يطابق نظام المستودع): UI → LabOrdersCubit → LabOrdersRepository.
//   - الكيان في domain/entities/lab_order.dart
//   - العقد في domain/repositories/lab_orders_repository.dart
//   - التنفيذ الحقيقي في data/repositories/remote_lab_orders_repository.dart
//
// شريط الفلاتر والبطاقة والحالة الفارغة في widgets/orders/.
// ملاحظة: استهلاك المخزون عند المعالجة side-effect هنا، عبر LabStockRepository
// الحقيقي (لا مخزون وهمي).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/entities/lab_stock.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import '../../domain/repositories/lab_repository.dart';
import '../../domain/repositories/lab_stock_repository.dart';
import '../bloc/lab_orders_cubit.dart';
import '../bloc/lab_orders_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/lab_order_details_dialog.dart';
import '../widgets/lab_order_process_dialog.dart';
import '../widgets/orders/lab_order_card.dart';
import '../widgets/orders/lab_orders_empty_state.dart';
import '../widgets/orders/lab_orders_filter_bar.dart';

/// صفحة طلبات الأطباء — تُنشئ [LabOrdersCubit] محلياً وتزوّده للـ subtree.
class LabOrdersPage extends StatelessWidget {
  const LabOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LabOrdersCubit(repository: sl<LabOrdersRepository>())..load(),
      child: BlocBuilder<LabOrdersCubit, LabOrdersState>(
        builder: (context, state) {
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labOrders,
            sections: LabSidebarSections.buildWithBadges(
              context,
              newOrdersCount: state.newCount,
              // لا مصدر إشعارات حقيقي متاح لهذه الصفحة بعد — 0 بدل رقم ثابت.
              unreadNotifsCount: 0,
            ),
            pageTitle: context.l10n.doctorOrders,
            pageSubtitle: null,
            searchPlaceholder: context.l10n.labOrdersSearchHint,
            onSearchChanged: (q) =>
                context.read<LabOrdersCubit>().setSearchQuery(q),
            userRole: currentUserRoleLabel(context, fallback: context.l10n.roleLabManager),
            notificationCount: 0,
            body: _OrdersBody(state: state),
          );
        },
      ),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({required this.state});

  final LabOrdersState state;

  @override
  Widget build(BuildContext context) {
    // أثناء التحميل الأولي نعرض هيكلاً عظمياً بدل وميض "لا توجد طلبات".
    if (state.status == LabOrdersStatus.loading && state.orders.isEmpty) {
      return const _OrdersLoading();
    }
    if (state.status == LabOrdersStatus.error && state.orders.isEmpty) {
      return _OrdersError(
        message: state.errorMessage ?? context.l10n.error,
        onRetry: () => context.read<LabOrdersCubit>().load(),
      );
    }
    final filtered = state.filtered;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Today toggle ───────────────────────────────────────────
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _TodayToggle(
              active: state.todayOnly,
              onTap: () => _toggleToday(context, !state.todayOnly),
            ),
          ),
          const SizedBox(height: AppSizes.spaceMD),
          // ── Filter bar ─────────────────────────────────────────────
          LabOrdersFilterBar(
            total: state.total,
            shown: filtered.length,
            newCount: state.newCount,
            mfgCount: state.mfgCount,
            readyCount: state.readyCount,
            current: state.filter,
            onChange: (v) => context.read<LabOrdersCubit>().setFilter(v),
          ),
          const SizedBox(height: AppSizes.spaceLG),
          // ── Grid ───────────────────────────────────────────────────
          if (filtered.isEmpty)
            const LabOrdersEmptyState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int cols = width > 1200
                    ? 3
                    : width > 760
                        ? 2
                        : 1;
                const double spacing = 16;
                final double cardW = (width - spacing * (cols - 1)) / cols;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final o in filtered)
                      SizedBox(
                        width: cardW,
                        child: LabOrderCard(
                          order: o,
                          onView: () => LabOrderDetailsDialog.show(context, o),
                          onProcess: () => _process(context, o),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _process(BuildContext context, LabOrderFull order) async {
    final cubit = context.read<LabOrdersCubit>();
    // نجلب الفنّيين الحقيقيين لقائمة التعيين، وإلا يفشل التعيين بـ"الفنّي غير موجود".
    final names = await _technicianNames();
    final stock = await _labStock();
    if (!context.mounted) return;
    final choice = await LabOrderProcessDialog.show(
      context,
      order,
      technicianNames: names,
      stock: stock,
    );
    if (choice == null) return;
    // تحديث الطلب عبر الـ Cubit/Repository. الباك يرفض بعض الانتقالات (مثلاً
    // "جاهز" على طلب لم يبدأ تصنيعه) — لازم نُظهر السبب، لا فشل صامت.
    // المواد المستهلكة (حالة "جاهز" فقط) تُرسل ضمن نفس طلب الإكمال — الباك
    // يخصم المخزون ويسجّل LabOrderMaterial (سجلّ ربط بالطلبية) ذرّياً بمعاملة
    // واحدة، بدل استدعاء خصم منفصل بعد الإكمال (كان يفقد سجلّ الربط بالطلبية).
    final ok = await cubit.processOrder(
      id: order.id,
      status: choice.status,
      technician: choice.technician,
      materials: _resolveMaterials(choice.consumption, stock),
    );
    if (!context.mounted) return;
    if (!ok) {
      GlassToast.show(context, message: cubit.state.errorMessage ?? context.l10n.error);
    }
  }

  /// يحوّل أسطر الاستهلاك (معرّف سجل مخزون) إلى {material_id, quantity} يلي
  /// يتوقّعه الباك — بالبحث عن materialId الحقيقي لكل سجل مخزون بالقائمة.
  List<({int materialId, double quantity})>? _resolveMaterials(
    List<LabConsumptionLine> lines,
    List<LabStock> stock,
  ) {
    if (lines.isEmpty) return null;
    final out = <({int materialId, double quantity})>[];
    for (final line in lines) {
      final match = stock.where((s) => s.id == line.stockId).firstOrNull;
      if (match != null) {
        out.add((materialId: match.materialId, quantity: line.quantity.toDouble()));
      }
    }
    return out.isEmpty ? null : out;
  }

  /// مخزون المخبر الحقيقي لقائمة اختيار المواد المستهلكة (فارغة عند الفشل).
  Future<List<LabStock>> _labStock() async {
    try {
      final repo = sl<LabStockRepository>();
      return repo.cached ?? await repo.getAll();
    } catch (_) {
      return const [];
    }
  }

  /// أسماء الفنّيين الحقيقيين من الباك (قائمة فارغة عند الفشل — المودال يعمل بلا تعيين).
  Future<List<String>> _technicianNames() async {
    try {
      final techs = await sl<LabRepository>().getTechnicians();
      return techs.map((t) => t.name).toList();
    } catch (_) {
      return const [];
    }
  }

  /// تبديل وضع "طلبات اليوم"؛ يُشعِر عند فشل جلب طلبات اليوم من الباك.
  Future<void> _toggleToday(BuildContext context, bool value) async {
    final cubit = context.read<LabOrdersCubit>();
    final errText = context.l10n.error;
    final ok = await cubit.setTodayOnly(value);
    if (!ok && context.mounted) {
      GlassToast.show(
        context,
        message: errText,
        icon: Icons.error_outline_rounded,
      );
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  TODAY TOGGLE — تبديل عرض "طلبات اليوم" (يحترم الثيمين)
// ══════════════════════════════════════════════════════════════════════════

class _TodayToggle extends StatelessWidget {
  const _TodayToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          button: true,
          toggled: active,
          label: context.l10n.labOrdersToday,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? accent
                  : (isLight ? Colors.white : AppColors.darkBg1),
              borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
              border: Border.all(
                color: active
                    ? accent
                    : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.today_rounded,
                    size: 15, color: active ? Colors.white : accent),
                const SizedBox(width: 6),
                Text(
                  context.l10n.labOrdersToday,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: active
                        ? Colors.white
                        : (isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1),
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

// ══════════════════════════════════════════════════════════════════════════
//  LOADING / ERROR
// ══════════════════════════════════════════════════════════════════════════

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          final int cols = width > 1200 ? 3 : (width > 760 ? 2 : 1);
          const double spacing = 16;
          final double cardW = (width - spacing * (cols - 1)) / cols;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (int i = 0; i < 6; i++)
                SizedBox(width: cardW, child: const AppShimmerCard()),
            ],
          );
        },
      ),
    );
  }
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 42,
              color: isLight ? AppColors.lightText3 : AppColors.darkText3),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText2 : AppColors.darkText2,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
