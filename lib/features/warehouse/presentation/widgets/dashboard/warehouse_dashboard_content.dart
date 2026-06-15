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
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/layout/app_welcome_hero.dart';
import '../../../../../shared/widgets/primitives/app_segmented_tabs.dart';

part 'warehouse_dashboard_stats.dart';
part 'warehouse_dashboard_expiring.dart';
part 'warehouse_dashboard_orders.dart';

class WarehouseDashboardContent extends StatelessWidget {
  const WarehouseDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWelcomeHero(context),
        const SizedBox(height: 16),
        _StatCardsRow(isLight: isLight),
        const SizedBox(height: 16),
        _ExpiringWarningStrip(isLight: isLight),
        const SizedBox(height: 16),
        _TodayOrdersSection(isLight: isLight),
      ],
    );
  }

  /// hero الترحيب — الويدجت الموحّد المشترك مع المخبر.
  Widget _buildWelcomeHero(BuildContext context) {
    final l10n = context.l10n;
    return AppWelcomeHero(
      emoji: '📦',
      greeting: l10n.whGreeting('أحمد'),
      statusText: l10n.whSystemsNormal,
      metas: [
        AppHeroMeta(l10n.whLastUpdateLabel, faded: true),
        const AppHeroMeta('منذ 5 دقيقة', bold: true, dotBefore: false),
        const AppHeroMeta('الجمعة، ٢٢ مايو', faded: true),
      ],
      stats: [
        AppHeroMiniStat(
          icon: Icons.inventory_2_outlined,
          value: '247',
          label: l10n.whTotalMaterials,
          accent: AppColors.dashVioletDeep,
        ),
        AppHeroMiniStat(
          icon: Icons.assignment_outlined,
          value: '9',
          label: l10n.whMiniOrdersToday,
          accent: AppColors.dashMagenta,
        ),
        AppHeroMiniStat(
          icon: Icons.verified_outlined,
          value: '94%',
          label: l10n.whSupplyRate,
          accent: AppColors.statusSuccess,
          checkmark: true,
        ),
      ],
    );
  }
}
