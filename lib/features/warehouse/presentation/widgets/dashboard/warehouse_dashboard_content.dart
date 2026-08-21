// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_content.dart
//
// محتوى لوحة تحكم المستودع — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   1. Welcome Hero card     → ترحيب + status + last-update + 3 inline mini-stats
//   2. 4 colored stat cards  → كل بطاقة بشريط جانبي ملوّن + شارة + قيمة + اتجاه
//   3. Expiring warning strip → شريط برتقالي بإشعار صلاحيات قريبة + chips
//   4. Today orders section  → عنوان + filter chips + جدول
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/auth/current_user.dart';
import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/core/mock_user_data.dart';
import '../../../../../shared/widgets/layout/app_welcome_hero.dart';
import '../../../domain/entities/inventory_summary.dart';
import '../../../domain/entities/warehouse_request.dart';
import '../../bloc/inventory_cubit.dart';
import '../../bloc/warehouse_requests_cubit.dart';
import '../orders/warehouse_orders_content.dart' show requestStatusStyle;

part 'warehouse_dashboard_stats.dart';
part 'warehouse_dashboard_orders.dart';

class WarehouseDashboardContent extends StatelessWidget {
  const WarehouseDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, invState) {
        final summary = invState.summary;
        return BlocBuilder<WarehouseRequestsCubit, WarehouseRequestsState>(
          builder: (context, reqState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeHero(context, invState, summary, reqState),
                const SizedBox(height: 16),
                _InventorySectionsRow(
                  isLight: isLight,
                  summary: summary,
                  isError: invState.status == InventoryStatus.error,
                ),
                const SizedBox(height: 16),
                _TodayOrdersSection(
                  isLight: isLight,
                  requests: reqState.requests,
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// hero الترحيب — الويدجت الموحّد المشترك مع المخبر. كل القيم حقيقية:
  /// الاسم من CurrentUser، "آخر تحديث" من InventoryCubit.lastLoadedAt،
  /// طلبات اليوم من WarehouseRequestsCubit (حالة "جديد")، وقريبة الانتهاء من
  /// InventorySummary — لا نسبة توريد مزيّفة (لا مصدر حقيقي لها بالباك).
  Widget _buildWelcomeHero(
    BuildContext context,
    InventoryState invState,
    InventorySummary? summary,
    WarehouseRequestsState reqState,
  ) {
    final l10n = context.l10n;
    final lowStockCount =
        summary != null ? summary.lowStockCount.toString() : '—';
    final expiringCount =
        summary != null ? summary.expiringBatches.length.toString() : '—';
    final ordersToday =
        reqState.countOf(RequestsFilter.newReq).toString();
    return AppWelcomeHero(
      emoji: '📦',
      greeting: l10n.whGreeting(
          CurrentUser.instance.name ?? MockUserData.defaultUserName),
      metas: [
        AppHeroMeta(l10n.whLastUpdateLabel, faded: true, dotBefore: false),
        AppHeroMeta(_lastUpdatedLabel(l10n, invState.lastLoadedAt),
            bold: true, dotBefore: false),
        AppHeroMeta(_todayLabel(l10n), faded: true),
      ],
      stats: [
        AppHeroMiniStat(
          icon: Icons.error_outline_rounded,
          value: lowStockCount,
          label: l10n.whStatLowStockShort,
          accent: AppColors.dashVioletDeep,
        ),
        AppHeroMiniStat(
          icon: Icons.assignment_outlined,
          value: ordersToday,
          label: l10n.whMiniOrdersToday,
          accent: AppColors.dashMagenta,
        ),
        AppHeroMiniStat(
          icon: Icons.schedule_outlined,
          value: expiringCount,
          label: l10n.whMiniExpiringSoon,
          accent: AppColors.dashOrange,
        ),
      ],
    );
  }

  /// اسم اليوم + التاريخ الحقيقيان (بنفس اتفاقية LabDashboardPage).
  String _todayLabel(AppLocalizations l10n) {
    final names = [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday,
    ];
    final now = DateTime.now();
    final dayName = names[now.weekday - 1];
    final date = '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    return '$dayName، $date';
  }

  /// "آخر تحديث" حقيقي من وقت آخر تحميل ناجح فعلي، لا نص ثابت.
  String _lastUpdatedLabel(AppLocalizations l10n, DateTime? at) {
    if (at == null) return l10n.whLastUpdateJustNow;
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return l10n.whLastUpdateJustNow;
    if (diff.inMinutes < 60) return l10n.whLastUpdateMinutesAgo(diff.inMinutes);
    return l10n.whLastUpdateHoursAgo(diff.inHours);
  }
}
