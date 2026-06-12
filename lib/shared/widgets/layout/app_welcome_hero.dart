// ════════════════════════════════════════════════════════════════════════════
// app_welcome_hero.dart
//
// Hero الترحيب الموحّد للداشبورد — المصدر البصري: hero المستودع
// (warehouse_dashboard_content._WelcomeHero) المعتمد كمرجع لتوحيد النظامين.
//
// 🎯 الستايل (مطابق 100% للمستودع):
//   - حاوية: padding 24/22، تدرّج لافندر F3E9FB→E7DBF5، حدود E0D2F0،
//     زوايا AppSizes.radiusLG.
//   - العنوان: emoji + نص 22 w800 بلون primary.
//   - تحت العنوان: status pill + نصوص meta مفصولة بنقاط.
//   - يسار: mini stats بصناديق بيضاء شفافة (white @0.7).
//
// قاعدة التوحيد: ممنوع بناء hero ترحيبي محلياً داخل الصفحات —
// المخبر والمستودع يستخدمان هذا الـ widget حصراً.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

/// إحصاء مصغّر داخل الـ hero (صندوق أبيض شفاف).
class AppHeroMiniStat {
  const AppHeroMiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    this.checkmark = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  /// true → دائرة ملوّنة بداخلها ✓ بدل مربع الأيقونة.
  final bool checkmark;
}

/// نص meta بجانب الـ status pill.
class AppHeroMeta {
  const AppHeroMeta(
    this.text, {
    this.bold = false,
    this.faded = false,
    this.dotBefore = true,
  });

  final String text;
  final bool bold;
  final bool faded;

  /// هل تسبقه نقطة فاصلة (·)؟
  final bool dotBefore;
}

/// Hero الترحيب الموحّد بين المخبر والمستودع.
class AppWelcomeHero extends StatelessWidget {
  const AppWelcomeHero({
    super.key,
    required this.emoji,
    required this.greeting,
    required this.statusText,
    this.statusColor = AppColors.statusSuccess,
    this.metas = const [],
    this.stats = const [],
  });

  /// emoji بجانب الترحيب (📦 للمستودع، 🦷 للمخبر...).
  final String emoji;

  /// نص الترحيب الرئيسي.
  final String greeting;

  /// نص الـ status pill (مثل "الأنظمة تعمل بشكل طبيعي").
  final String statusText;

  /// لون الـ status pill.
  final Color statusColor;

  /// نصوص الـ meta بعد الـ pill (آخر تحديث، التاريخ...).
  final List<AppHeroMeta> metas;

  /// الإحصاءات المصغّرة على يسار الـ hero.
  final List<AppHeroMiniStat> stats;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        // الفاتح: تدرّج لافندر (المرجع: hero المستودع).
        // الغامق: navy → بنفسجي.
        gradient: isLight
            ? const LinearGradient(
                colors: [Color(0xFFF3E9FB), Color(0xFFE7DBF5)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF20223A),
                  Color(0xFF2A2B4A),
                  Color(0xFF332B57),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? const Color(0xFFE0D2F0) : AppColors.darkBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 760;
          final header = _buildHeader(isLight);
          final miniStats = _buildMiniStats(isLight);
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 14),
                miniStats,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: header),
              const SizedBox(width: 12),
              miniStats,
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isLight) {
    final Color titleColor =
        isLight ? AppColors.primary : AppColors.darkText1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                greeting,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusPill(text: statusText, color: statusColor),
            for (final m in metas) ...[
              if (m.dotBefore) const _DotSep(),
              _MetaText(m, isLight: isLight),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStats(bool isLight) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          _MiniStat(stat: stats[i], isLight: isLight),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotSep extends StatelessWidget {
  const _DotSep();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          '·',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            color: AppColors.lightText4,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.meta, {required this.isLight});
  final AppHeroMeta meta;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final Color faded = isLight ? AppColors.lightText3 : AppColors.darkText3;
    final Color normal = isLight ? AppColors.lightText1 : AppColors.darkText1;
    return Text(
      meta.text,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 12,
        fontWeight: meta.bold ? FontWeight.w700 : FontWeight.w500,
        color: meta.faded ? faded : normal,
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.stat, required this.isLight});
  final AppHeroMiniStat stat;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLight
            ? Colors.white.withValues(alpha: 0.7)
            : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: isLight
              ? Colors.white.withValues(alpha: 0.9)
              : AppColors.darkBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stat.checkmark)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: stat.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            )
          else
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: stat.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(stat.icon, size: 14, color: stat.accent),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stat.value,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: isLight ? AppColors.primary : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                stat.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isLight ? AppColors.lightText3 : AppColors.darkText3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
