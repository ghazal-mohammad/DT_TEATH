// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_hero.dart
//
// Hero section في الجزء العلوي من Dashboard المستودع.
//
// المرجع: DT_Teeth_Warehouse_v6_Enhanced.html — السطور 2128–2140 + 1924–1982
//
// CSS الأصلي:
//   .dash-hero {
//     background: linear-gradient(135deg, rgba(190,216,250,0.08), rgba(241,218,254,0.05));
//     border: 1px solid rgba(190,216,250,0.15);
//     border-radius: 20px;
//     padding: 24px 28px;
//     margin-bottom: 18px;
//     display: flex;
//     align-items: center;
//     justify-content: space-between;
//   }
//   .dh-text h2 { font-size:22px; font-weight:900; }
//   .dh-text p  { font-size:14px; color:var(--t3); }
//   .dh-stat-val { font-size:26px; font-weight:900; color:var(--cyan-b); }
//   .dh-stat-lbl { font-size:11px; color:var(--t3); margin-top:4px; }
//   .dh-divider  { width:1px; height:40px; background:rgba(190,216,250,0.2); }
//
// Pseudo-elements:
//   ::before — خط فاصل أعلى الـ hero (gradient)
//   ::after  — دائرة مضيئة في الزاوية اليمنى السفلى (radial gradient)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';

/// Hero card يعرض رسالة ترحيب + 3 إحصائيات سريعة في رأس Dashboard.
///
/// التصميم:
/// ```
/// ┌──────────────────────────────────────────────────────────────┐
/// │  مرحباً بك في نظام المستودع 📦              247  │  3  │  8 │
/// │  آخر تحديث: اليوم — جميع الأنظمة تعمل بشكل   مادة │معلق│ نشط│
/// │  طبيعي ✅                                  مسجلة│    │    │
/// └──────────────────────────────────────────────────────────────┘
/// ```
class WarehouseDashboardHero extends StatelessWidget {
  const WarehouseDashboardHero({
    super.key,
    required this.registeredCount,
    required this.pendingOrdersCount,
    required this.activeAlertsCount,
  });

  /// عدد المواد المسجّلة في النظام.
  final int registeredCount;

  /// عدد الطلبيات المعلّقة.
  final int pendingOrdersCount;

  /// عدد التنبيهات النشطة.
  final int activeAlertsCount;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        // من CSS: linear-gradient(135deg, rgba(190,216,250,0.08), rgba(241,218,254,0.05))
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tableHeader.withValues(alpha: 0.08),
            AppColors.secondaryComponent.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: AppColors.tableHeader.withValues(alpha: 0.15),
          width: AppSizes.borderThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL), // r20
      ),
      child: Stack(
        children: [
          // ── Pseudo-element ::after — دائرة مضيئة في الزاوية ──────────
          PositionedDirectional(
            bottom: -40,
            end: -20, // CSS: right:-20 (في RTL، end = right بصرياً)
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.tableHeader.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Pseudo-element ::before — خط gradient في الأعلى ──────────
          // ملاحظة RTL: full-width line — left:0 + right:0 متماثل، آمن للـ RTL.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.tableHeader.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── المحتوى الرئيسي ───────────────────────────────────────────
          // على شاشات ضيقة (< 720px) نتحوّل لـ Column لتجنّب overflow.
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildText(context, isLight),
                    const SizedBox(height: 16),
                    _buildStats(context, isLight),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // النص الترحيبي
                  Flexible(child: _buildText(context, isLight)),

                  // فجوة عرضية
                  const SizedBox(width: 20),

                  // الإحصائيات
                  _buildStats(context, isLight),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// بناء النص الترحيبي (h2 + p).
  Widget _buildText(BuildContext context, bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.welcomeWarehouse,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.2,
            letterSpacing: 0.3,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.whDashboardHeroSubtitle,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: AppSizes.fontMD,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// بناء صف الإحصائيات الثلاث مع الـ dividers.
  Widget _buildStats(BuildContext context, bool isLight) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildStat(
          context,
          value: registeredCount,
          label: context.l10n.whHeroStatRegisteredMaterials,
          isLight: isLight,
        ),
        _buildDivider(),
        _buildStat(
          context,
          value: pendingOrdersCount,
          label: context.l10n.whHeroStatPendingOrders,
          isLight: isLight,
        ),
        _buildDivider(),
        _buildStat(
          context,
          value: activeAlertsCount,
          label: context.l10n.whHeroStatActiveAlerts,
          isLight: isLight,
        ),
      ],
    );
  }

  /// بناء إحصائية واحدة (رقم + label).
  Widget _buildStat(
    BuildContext context, {
    required int value,
    required String label,
    required bool isLight,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.0,
            color: AppColors.dashCyan,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.2,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// بناء divider عمودي بين الإحصائيات.
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.tableHeader.withValues(alpha: 0.2),
    );
  }
}
