// ════════════════════════════════════════════════════════════════════════════
// reports_view.dart
//
// عرض تقارير موحّد مشترك بين المخبر والمستودع — نفس التصميم بالضبط (بالثيمين).
// يأخذ نموذجًا عامًّا (KPIs + حسب النوع + حسب اليوم + أداء اختياري)، فيستهلكه أيّ
// نظام ببياناته. أداء الفريق اختياري ([teamPerformance] = null ⇒ يختفي القسم،
// كحال المستودع الذي لا تقييم أداء فيه).
//
// المنطق (جلب/فترة) يبقى في كيوبت كل نظام — هذا العرض بلا حالة.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../feedback/glass_toast.dart';
import '../primitives/app_button.dart';
import '../primitives/app_filter_chip.dart';
import 'report_export.dart';

enum ReportsViewStatus { loading, loaded, error }

/// بطاقة KPI واحدة (أيقونة emoji + قيمة + عنوان + لون تمييز).
class ReportKpi {
  const ReportKpi({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });
  final String icon;
  final String value;
  final String label;
  final Color accent;
}

/// شريحة في مخطط النِّسب (نوع + نسبة + عدد + لون).
class ReportSegment {
  const ReportSegment({
    required this.label,
    required this.percentage,
    required this.count,
    required this.color,
  });
  final String label;
  final int percentage;
  final int count;
  final Color color;
}

/// عمود يوم في المخطّط الأسبوعي.
class ReportDay {
  const ReportDay({required this.label, required this.count});
  final String label;
  final int count;
}

/// صفّ أداء (اسم + قيمة جانبية + كسر التقدّم 0–1 + لون).
class ReportTeamRow {
  const ReportTeamRow({
    required this.name,
    required this.trailing,
    required this.fraction,
    required this.color,
  });
  final String name;
  final String trailing;
  final double fraction;
  final Color color;
}

/// ألوان تُوزَّع على الشرائح/الأداء (ثابتة، تحترم هوية النظام).
const List<Color> kReportPalette = [
  AppColors.dashCyan,
  AppColors.secondary,
  AppColors.dashOrange,
  AppColors.success,
  AppColors.brand,
  AppColors.statusInfo,
];

class ReportsView extends StatelessWidget {
  const ReportsView({
    super.key,
    required this.status,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onRetry,
    required this.periodLabel,
    required this.kpis,
    required this.ordersByType,
    required this.ordersByDay,
    required this.exportTitle,
    this.teamPerformance,
    this.errorMessage,
    this.byTypeTitle,
    this.byTypeUnit,
    this.byDayTitle,
    this.onPrevious,
    this.onNext,
    this.onResetToday,
    this.isAtToday = true,
  });

  final ReportsViewStatus status;
  final int selectedPeriod; // 0=شهري 1=أسبوعي 2=يومي 3=سنوي
  final ValueChanged<int> onPeriodChanged;
  final VoidCallback onRetry;

  final String periodLabel;

  /// عنوان التقرير المُستخدَم بملفات التصدير (PDF/Excel/البريد) — مستقلّ عن
  /// [periodLabel] لأنّه بمخبر بيكون نطاق تاريخ، وبالمستودع بيكون عنوان التقرير.
  final String exportTitle;
  final List<ReportKpi> kpis;
  final List<ReportSegment> ordersByType;
  final List<ReportDay> ordersByDay;

  /// أداء الفريق — null يُخفي القسم (المستودع).
  final List<ReportTeamRow>? teamPerformance;

  final String? errorMessage;

  /// عنوان مخطّط النِّسب ووحدة المركز (افتراضي: حسب النوع / قطعة).
  final String? byTypeTitle;
  final String? byTypeUnit;

  /// عنوان مخطّط الأيام (افتراضي: الطلبات حسب اليوم).
  final String? byDayTitle;

  /// تنقّل زمني بين فترات سابقة/تالية (اختياري — null يخفي أزرار التنقّل
  /// بالكامل، الوضع الافتراضي للمستودع الذي لا يستخدمه حالياً).
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// رجوع فوري للفترة الحالية (اليوم) — يظهر فقط لو [isAtToday] false.
  final VoidCallback? onResetToday;

  /// هل الفترة المعروضة هي الحالية (اليوم)؟ true افتراضياً (لا زر "اليوم").
  final bool isAtToday;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _controls(context, isLight),
          const SizedBox(height: AppSizes.spaceMD),
          if (status == ReportsViewStatus.loading)
            _loading()
          else if (status == ReportsViewStatus.error)
            _error(context)
          else ...[
            _periodLabelRow(context, isLight),
            const SizedBox(height: AppSizes.spaceMD),
            _kpiRow(isLight),
            const SizedBox(height: AppSizes.spaceLG),
            _dayCard(context, isLight),
            const SizedBox(height: AppSizes.spaceLG),
            _bottomRow(context, isLight),
          ],
        ],
      ),
    );
  }

  /// يبني حزمة بيانات التصدير من نفس النماذج المعروضة بالشاشة.
  ReportExportData _exportData() => ReportExportData(
    title: exportTitle,
    periodLabel: periodLabel,
    kpis: kpis,
    segments: ordersByType,
    days: ordersByDay,
    team: teamPerformance ?? const [],
    segmentsTitle: byTypeTitle,
    daysTitle: byDayTitle,
  );

  /// نطاق التاريخ الحالي + تنقّل سابق/تالي/اليوم (يظهر بس لو [onPrevious]
  /// مُمرَّر — المستودع ما بيمرّره حالياً فيضل بلا تنقّل، بلا أي تغيير بسلوكه).
  Widget _periodLabelRow(BuildContext context, bool isLight) {
    final label = Text(
      periodLabel,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isLight ? AppColors.lightText3 : AppColors.darkText3,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
    if (onPrevious == null) return label;
    final l10n = context.l10n;
    return Row(
      children: [
        label,
        const Spacer(),
        if (!isAtToday && onResetToday != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: AppButton.secondary(
              label: l10n.reportsBackToToday,
              onPressed: onResetToday,
              size: AppButtonSize.small,
            ),
          ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: l10n.reportsPreviousPeriod,
          onPressed: onPrevious,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: l10n.reportsNextPeriod,
          onPressed: isAtToday ? null : onNext,
        ),
      ],
    );
  }

  // ── الأدوات: فترة + تصدير ────────────────────────────────────────────────
  Widget _controls(BuildContext context, bool isLight) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth > 650;
        final chips = AppFilterChipRow(
          options: [
            l10n.labReportFilterMonthly,
            l10n.labReportFilterWeekly,
            l10n.labReportFilterDaily,
            l10n.labReportFilterYearly,
          ],
          selectedIndex: selectedPeriod,
          onChanged: onPeriodChanged,
        );
        final exports = _ExportButtonsRow(data: _exportData());
        if (isWide) {
          return Row(children: [chips, const Spacer(), exports]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            chips,
            const SizedBox(height: AppSizes.spaceSM),
            exports,
          ],
        );
      },
    );
  }

  // ── حالات التحميل/الخطأ ─────────────────────────────────────────────────
  Widget _loading() => const Column(
    children: [
      Row(
        children: [
          Expanded(child: _Skeleton(height: 96)),
          SizedBox(width: AppSizes.spaceMD),
          Expanded(child: _Skeleton(height: 96)),
          SizedBox(width: AppSizes.spaceMD),
          Expanded(child: _Skeleton(height: 96)),
          SizedBox(width: AppSizes.spaceMD),
          Expanded(child: _Skeleton(height: 96)),
        ],
      ),
      SizedBox(height: AppSizes.spaceLG),
      _Skeleton(height: 180),
      SizedBox(height: AppSizes.spaceLG),
      _Skeleton(height: 220),
    ],
  );

  Widget _error(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSizes.space2XL),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          Text(
            errorMessage ?? l10n.error,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          AppButton.secondary(
            label: l10n.retry,
            onPressed: onRetry,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  // ── بطاقات KPI ───────────────────────────────────────────────────────────
  Widget _kpiRow(bool isLight) {
    final cards = [for (final k in kpis) _KpiCard(kpi: k, isLight: isLight)];
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 700) {
          return Row(
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSizes.spaceMD),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        // شبكة 2×n للضيّق.
        return Column(
          children: [
            for (int i = 0; i < cards.length; i += 2) ...[
              if (i > 0) const SizedBox(height: AppSizes.spaceMD),
              Row(
                children: [
                  Expanded(child: cards[i]),
                  const SizedBox(width: AppSizes.spaceMD),
                  Expanded(
                    child: i + 1 < cards.length
                        ? cards[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  // ── حسب اليوم (أعمدة) ─────────────────────────────────────────────────────
  Widget _dayCard(BuildContext context, bool isLight) {
    final maxCount = ordersByDay.isEmpty
        ? 0
        : ordersByDay.map((d) => d.count).reduce((a, b) => a > b ? a : b);
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            byDayTitle ?? context.l10n.labReportOrdersByDay,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceLG),
          if (ordersByDay.isEmpty)
            _noData(context, isLight)
          else
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final d in ordersByDay)
                    Expanded(
                      child: _DayBar(
                        label: d.label,
                        count: d.count,
                        maxCount: maxCount,
                        isLight: isLight,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── الصفّ السفلي: Donut + (أداء اختياري) ──────────────────────────────────
  Widget _bottomRow(BuildContext context, bool isLight) {
    final chart = _chartCard(context, isLight);
    final team = teamPerformance == null ? null : _teamCard(context, isLight);
    if (team == null) return chart;
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: chart),
              const SizedBox(width: AppSizes.spaceLG),
              Expanded(child: team),
            ],
          );
        }
        return Column(
          children: [
            chart,
            const SizedBox(height: AppSizes.spaceLG),
            team,
          ],
        );
      },
    );
  }

  Widget _chartCard(BuildContext context, bool isLight) {
    final total = ordersByType.fold<int>(0, (s, seg) => s + seg.count);
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            byTypeTitle ?? context.l10n.labReportOrdersByType,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          if (ordersByType.isEmpty)
            _noData(context, isLight)
          else
            Row(
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CustomPaint(
                    painter: _DonutPainter(segments: ordersByType),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$total',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isLight
                                  ? AppColors.lightText1
                                  : AppColors.darkText1,
                            ),
                          ),
                          Text(
                            byTypeUnit ?? context.l10n.piecesUnit,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isLight
                                  ? AppColors.lightText4
                                  : AppColors.darkText4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spaceLG),
                Expanded(
                  child: Column(
                    children: [
                      for (final seg in ordersByType)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: seg.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  seg.label,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                              Text(
                                '${seg.percentage}%',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isLight
                                      ? AppColors.lightText3
                                      : AppColors.darkText3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${seg.count}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isLight
                                      ? AppColors.lightText1
                                      : AppColors.darkText1,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _teamCard(BuildContext context, bool isLight) {
    final team = teamPerformance!;
    return _Card(
      isLight: isLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.labReportTeamPerf,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSizes.spaceMD),
          if (team.isEmpty)
            _noData(context, isLight)
          else
            for (final t in team)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t.name, style: AppTextStyles.bodyMedium),
                        Text(
                          t.trailing,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: t.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            color: isLight
                                ? AppColors.dividerNeutral
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                          FractionallySizedBox(
                            widthFactor: t.fraction.clamp(0.0, 1.0),
                            child: Container(height: 8, color: t.color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _noData(BuildContext context, bool isLight) => Text(
    context.l10n.labReportNoData,
    style: AppTextStyles.bodySmall.copyWith(
      color: isLight ? AppColors.lightText4 : AppColors.darkText4,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════
//  أجزاء داخلية
// ══════════════════════════════════════════════════════════════════════════

/// أزرار التصدير الثلاثة (PDF/Excel/بريد) — تُدير حالة "جارٍ التصدير" لكل
/// زر مستقلّة، وتُظهر خطأ عبر GlassToast لو فشل التصدير (ملف محظور، لا عميل
/// بريد مُعرَّف، إلخ) بدل فشل صامت.
class _ExportButtonsRow extends StatefulWidget {
  const _ExportButtonsRow({required this.data});
  final ReportExportData data;

  @override
  State<_ExportButtonsRow> createState() => _ExportButtonsRowState();
}

enum _ExportKind { pdf, excel, email }

class _ExportButtonsRowState extends State<_ExportButtonsRow> {
  _ExportKind? _busy;

  Future<void> _run(_ExportKind kind, Future<void> Function() action) async {
    if (_busy != null) return;
    setState(() => _busy = kind);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        GlassToast.show(
          context,
          message: context.l10n.reportExportError,
          icon: Icons.error_outline_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppButton.primary(
          label: l10n.labReportExportPdf,
          isLoading: _busy == _ExportKind.pdf,
          onPressed: () => _run(
            _ExportKind.pdf,
            () => ReportExporter.exportPdf(widget.data),
          ),
          size: AppButtonSize.small,
        ),
        const SizedBox(width: AppSizes.spaceSM),
        AppButton.secondary(
          label: l10n.labReportExportExcel,
          isLoading: _busy == _ExportKind.excel,
          onPressed: () => _run(
            _ExportKind.excel,
            () => ReportExporter.exportExcel(widget.data),
          ),
          size: AppButtonSize.small,
        ),
        const SizedBox(width: AppSizes.spaceSM),
        AppButton.secondary(
          label: l10n.labReportSendEmail,
          isLoading: _busy == _ExportKind.email,
          onPressed: () => _run(
            _ExportKind.email,
            () => ReportExporter.emailReport(widget.data),
          ),
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.isLight});
  final Widget child;
  final bool isLight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.spaceLG),
    decoration: BoxDecoration(
      color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      border: Border.all(
        color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
      ),
    ),
    child: child,
  );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi, required this.isLight});
  final ReportKpi kpi;
  final bool isLight;

  @override
  Widget build(BuildContext context) => ClipRRect(
    // ── لماذا ClipRRect + Stack بدل Border رباعي الألوان: Flutter يرمي
    //    استثناء عند الرسم لو Border له borderRadius وألوان أضلاع مختلفة
    //    ("A borderRadius can only be given on borders with uniform
    //    colors") — كان يفشل الرسم بصمت بكل تحميل (صندوق فاضٍ فعلياً).
    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
    child: Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(width: 3, color: kpi.accent),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kpi.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: AppSizes.spaceSM),
                Text(
                  kpi.value,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kpi.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isLight ? AppColors.lightText4 : AppColors.darkText3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.isLight,
  });
  final String label;
  final int count;
  final int maxCount;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final double factor = maxCount == 0 ? 0 : count / maxCount;
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w800,
              color: isLight ? AppColors.lightText1 : AppColors.darkText1,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: FractionallySizedBox(
              heightFactor: factor.clamp(0.02, 1.0),
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: count == 0 ? 0.15 : 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.segments});
  final List<ReportSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 8.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweep = 2 * math.pi * (seg.percentage / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep - 0.1,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.segments != segments;
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: (isLight ? AppColors.lightBorder : AppColors.darkBorder)
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
    );
  }
}
