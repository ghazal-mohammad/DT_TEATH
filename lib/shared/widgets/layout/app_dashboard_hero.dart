// ════════════════════════════════════════════════════════════════════════════
// app_dashboard_hero.dart
//
// Hero banner للداشبورد — `.dash-hero`, `.dh-text`, `.dh-stats`, `.dh-stat`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 1547–1605
//
// القواعد الأصلية:
//   .dash-hero {
//     background:linear-gradient(135deg,rgba(158,251,236,0.08),
//                                       rgba(237,139,250,0.05));
//     border:1px solid rgba(158,251,236,0.15);
//     border-radius:20px; padding:24px 28px; margin-bottom:18px;
//     position:relative; overflow:hidden;
//     display:flex; align-items:center; justify-content:space-between;
//   }
//   .dash-hero::before {
//     content:''; position:absolute; top:0; left:0; right:0; height:1px;
//     background:linear-gradient(90deg,transparent,
//                                      rgba(158,251,236,0.5),transparent);
//   }
//   .dash-hero::after {
//     content:''; position:absolute; bottom:-40px; right:-20px;
//     width:180px; height:180px; border-radius:50%;
//     background:radial-gradient(circle,rgba(158,251,236,0.08),transparent);
//   }
//   .dh-text h2  { font-size:22px; font-weight:900; color:var(--t1);
//                  margin-bottom:4px; letter-spacing:0.3px }
//   .dh-text p   { font-size:14px; color:var(--t3); font-weight:500 }
//   .dh-stats    { display:flex; gap:24px; align-items:center }
//   .dh-stat-val { font-size:26px; font-weight:900; color:var(--cyan-b) }
//   .dh-stat-lbl { font-size:11px; color:var(--t3); margin-top:4px;
//                  font-weight:600 }
//   .dh-divider  { width:1px; height:40px; background:rgba(158,251,236,0.2) }
//
// يُستخدم في الصفحة الرئيسية لعرض ترحيب + إحصاءات سريعة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';

/// إحصاء مختصر داخل Hero (عدد + تسمية).
class AppDashboardHeroStat {
  const AppDashboardHeroStat({required this.value, required this.label});
  final String value;
  final String label;
}

/// Hero banner لصفحة الداشبورد الرئيسية.
///
/// مثال:
/// ```dart
/// AppDashboardHero(
///   title: 'مرحباً، د.خالد',
///   subtitle: 'يوم جميل! لديك 12 طلب قيد التنفيذ',
///   stats: [
///     AppDashboardHeroStat(value: '247', label: 'طلب هذا الشهر'),
///     AppDashboardHeroStat(value: '98%', label: 'معدل الإنجاز'),
///     AppDashboardHeroStat(value: '12', label: 'قيد التنفيذ'),
///   ],
/// )
/// ```
class AppDashboardHero extends StatelessWidget {
  const AppDashboardHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.stats = const [],
    this.leadingAction,
  });

  final String title;
  final String subtitle;
  final List<AppDashboardHeroStat> stats;

  /// widget اختياري يُعرض بعد الإحصاءات (مثلاً زر CTA).
  final Widget? leadingAction;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18), // margin-bottom:18px
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // الجسم الرئيسي
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 24,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight, // 135deg
                  colors: [
                    Color(0x149EFBEC), // rgba(158,251,236,0.08)
                    Color(0x0DED8BFA), // rgba(237,139,250,0.05)
                  ],
                ),
                border: Border.all(
                  color: const Color(0x269EFBEC), // 0.15
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildContent(context, isLight),
            ),

            // ::before — خط علوي
            // ملاحظة RTL: full-width line — left:0 + right:0 متماثل، آمن للـ RTL.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0x809EFBEC), // 0.5
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ::after — دائرة زخرفية متوهّجة في الزاوية
            // ملاحظة RTL: نستخدم PositionedDirectional لأن الموقع غير متماثل.
            // end: -20 → في RTL يعني يسار-20، في LTR يعني يمين-20.
            // النتيجة البصرية: الدائرة دائماً في "الزاوية البعيدة عن البداية".
            PositionedDirectional(
              bottom: -40,
              end: -20,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x149EFBEC), // 0.08
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isLight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // responsive: تحت 700px → نضع الإحصاءات تحت النص
        final bool isCompact = constraints.maxWidth < 700;

        final Widget textBlock = _buildTextBlock(isLight);
        final Widget statsBlock = stats.isEmpty
            ? const SizedBox.shrink()
            : _buildStatsBlock(isLight);

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textBlock,
              if (stats.isNotEmpty) ...[
                const SizedBox(height: 20),
                statsBlock,
              ],
              if (leadingAction != null) ...[
                const SizedBox(height: 16),
                leadingAction!,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: textBlock),
            if (stats.isNotEmpty) ...[
              const SizedBox(width: 24),
              statsBlock,
            ],
            if (leadingAction != null) ...[
              const SizedBox(width: 16),
              leadingAction!,
            ],
          ],
        );
      },
    );
  }

  Widget _buildTextBlock(bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            letterSpacing: 0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBlock(bool isLight) {
    final List<Widget> children = [];
    for (int i = 0; i < stats.length; i++) {
      children.add(_buildStatItem(stats[i], isLight));
      if (i < stats.length - 1) {
        children.add(const SizedBox(width: 24)); // gap:24px
        children.add(_buildDivider());
        children.add(const SizedBox(width: 24));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildStatItem(AppDashboardHeroStat stat, bool isLight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat.value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isLight ? const Color(0xFF1A1C4E) : AppColors.brand,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0x339EFBEC), // rgba(158,251,236,0.2)
    );
  }
}
