// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_content.dart
//
// محتوى صفحة تقارير المستودع — مطابق لـ mockup التصميم.
//
// 🎯 البنية:
//   1. شريط التصدير + اختيار الفترة (يومي/أسبوعي/شهري/سنوي)
//   2. ترويسة التقرير: شهر + تاريخ الإنشاء
//   3. صف 4 بطاقات إحصائية (مدة التوريد، نسبة التوريد، استهلاك، إجمالي)
//   4. صفّ بطاقتين: donut توزع الاستهلاك + شبكة الأيام
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';

part 'warehouse_reports_performance.dart';
part 'warehouse_reports_toolbar_stats.dart';
part 'warehouse_reports_charts.dart';

// ══════════════════════════════════════════════════════════════════════════
//                             VIEW RANGE
// ══════════════════════════════════════════════════════════════════════════

enum _ReportRange { daily, weekly, monthly, yearly }

extension on _ReportRange {
  String label(AppLocalizations l10n) => switch (this) {
        _ReportRange.daily => l10n.reportRangeDaily,
        _ReportRange.weekly => l10n.reportRangeWeekly,
        _ReportRange.monthly => l10n.reportRangeMonthly,
        _ReportRange.yearly => l10n.reportRangeYearly,
      };
}

// ══════════════════════════════════════════════════════════════════════════
//                            MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseReportsContent extends StatefulWidget {
  const WarehouseReportsContent({super.key});

  @override
  State<WarehouseReportsContent> createState() =>
      _WarehouseReportsContentState();
}

class _WarehouseReportsContentState extends State<WarehouseReportsContent> {
  _ReportRange _range = _ReportRange.monthly;

  // الفترة الحالية (mock — مطابق للـ design).
  static const _periodLabel = 'مارس 2026';
  static const _generatedAt = '22 مايو 2026';
  static const _daysInMonth = 31;

  // الأيام ذات النشاط (highlighted) — مطابق للـ mockup.
  static const _highlightedDays = {9, 11, 17, 24, 26};

  // توزّع الاستهلاك حسب الفئة — مطابق للـ mockup.
  static const _categoryShares = <_CategoryShare>[
    _CategoryShare(label: 'مستهلكات', percent: 42, color: AppColors.primary),
    _CategoryShare(label: 'مواد طبية', percent: 28, color: AppColors.statusProgress),
    _CategoryShare(label: 'أدوية', percent: 18, color: AppColors.statusInfo),
    _CategoryShare(label: 'معادن', percent: 12, color: AppColors.statusSuccess),
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(
          range: _range,
          onRangeChange: (r) => setState(() => _range = r),
          isLight: isLight,
        ),
        const SizedBox(height: 16),
        _ReportHeader(
          period: _periodLabel,
          generatedAt: _generatedAt,
          isLight: isLight,
        ),
        const SizedBox(height: 14),
        _StatsRow(isLight: isLight),
        const SizedBox(height: 14),
        _BottomRow(
          isLight: isLight,
          shares: _categoryShares,
          daysInMonth: _daysInMonth,
          highlighted: _highlightedDays,
        ),
        const SizedBox(height: 14),
        _PerformanceRow(isLight: isLight),
      ],
    );
  }
}

