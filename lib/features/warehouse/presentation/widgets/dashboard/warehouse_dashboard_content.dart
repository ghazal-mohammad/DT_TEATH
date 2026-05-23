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

import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_filter_chip.dart';

class WarehouseDashboardContent extends StatelessWidget {
  const WarehouseDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WelcomeHero(isLight: isLight),
        const SizedBox(height: 16),
        _StatCardsRow(isLight: isLight),
        const SizedBox(height: 16),
        _ExpiringWarningStrip(isLight: isLight),
        const SizedBox(height: 16),
        _TodayOrdersSection(isLight: isLight),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  1) WELCOME HERO
// ══════════════════════════════════════════════════════════════════════════

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFE5FB), Color(0xFFFFE5F0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: const Color(0xFFE3D7F4)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 760;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildMiniStats(),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildHeader()),
              const SizedBox(width: 12),
              _buildMiniStats(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('📦', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text(
              'مرحباً، أحمد',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusPill(
              text: 'جميع الأنظمة تعمل بشكل طبيعي',
              color: Color(0xFF1F9B6E),
            ),
            _DotSep(),
            _MetaText('آخر تحديث: ', faded: true),
            _MetaText('منذ 5 دقيقة', bold: true),
            _DotSep(),
            _MetaText('الجمعة، ٢٢ مايو', faded: true),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStats() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniStat(
          icon: Icons.inventory_2_outlined,
          value: '247',
          label: 'إجمالي المواد',
          accent: Color(0xFF6E59B6),
        ),
        SizedBox(width: 10),
        _MiniStat(
          icon: Icons.assignment_outlined,
          value: '9',
          label: 'طلب اليوم',
          accent: Color(0xFFB44286),
        ),
        SizedBox(width: 10),
        _MiniStat(
          icon: Icons.verified_outlined,
          value: '94%',
          label: 'نسبة التوريد',
          accent: Color(0xFF1F9B6E),
          checkmark: true,
        ),
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
              fontSize: 11.5,
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
        child: Text('·',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: AppColors.lightText4,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            )),
      );
}

class _MetaText extends StatelessWidget {
  const _MetaText(this.text, {this.bold = false, this.faded = false});
  final String text;
  final bool bold;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 11.5,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: faded ? AppColors.lightText3 : AppColors.lightText1,
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
  final bool checkmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (checkmark)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: accent,
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
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 14, color: accent),
            ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightText3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  2) STAT CARDS ROW
// ══════════════════════════════════════════════════════════════════════════

enum _StatVariant { green, purple, orange, blue }

extension on _StatVariant {
  Color get accent => switch (this) {
        _StatVariant.green => const Color(0xFF1F9B6E),
        _StatVariant.purple => const Color(0xFF7A4FCF),
        _StatVariant.orange => const Color(0xFFE17B2C),
        _StatVariant.blue => const Color(0xFF2C7FDB),
      };

  Color get tint => accent.withValues(alpha: 0.12);
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({required this.isLight});
  final bool isLight;

  static const _items = <_StatData>[
    _StatData(
      variant: _StatVariant.green,
      badge: 'هذا الشهر',
      value: '2.8M',
      label: 'مشتريات الشهر (ل.س)',
      trend: '+12% من الشهر الماضي',
      trendUp: true,
      icon: Icons.assignment_outlined,
    ),
    _StatData(
      variant: _StatVariant.purple,
      badge: 'جديد',
      value: '9',
      label: 'طلبات بانتظار التوريد',
      trend: '3+ اليوم',
      trendUp: true,
      icon: Icons.assignment_outlined,
    ),
    _StatData(
      variant: _StatVariant.orange,
      badge: 'تنبيه',
      value: '8',
      label: 'مواد بالحد الأدنى',
      trend: 'يحتاج توريد',
      trendUp: false,
      icon: Icons.error_outline,
    ),
    _StatData(
      variant: _StatVariant.blue,
      badge: '4+',
      value: '247',
      label: 'إجمالي المواد',
      trend: '4+ هذا الأسبوع',
      trendUp: true,
      icon: Icons.inventory_2_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final int cols = c.maxWidth >= 1100
          ? 4
          : c.maxWidth >= 720
              ? 2
              : 1;
      return GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: switch (cols) { 4 => 1.55, 2 => 2.2, _ => 3.2 },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _items
            .map((d) => _StatCard(isLight: isLight, data: d))
            .toList(growable: false),
      );
    });
  }
}

class _StatData {
  const _StatData({
    required this.variant,
    required this.badge,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
    required this.icon,
  });

  final _StatVariant variant;
  final String badge;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.isLight, required this.data});
  final bool isLight;
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final accent = data.variant.accent;
    final tint = data.variant.tint;

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.baseComponent : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // الشريط الجانبي الملوّن (يسار البطاقة بصرياً في RTL = end)
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatBadge(text: data.badge, accent: accent, tint: tint),
                        const Spacer(),
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: tint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(data.icon, size: 18, color: accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.value,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        color: isLight
                            ? AppColors.lightText1
                            : AppColors.darkText1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.label,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isLight
                            ? AppColors.lightText3
                            : AppColors.darkText3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          data.trendUp
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: accent,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            data.trend,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge(
      {required this.text, required this.accent, required this.tint});
  final String text;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  3) EXPIRING WARNING STRIP
// ══════════════════════════════════════════════════════════════════════════

class _ExpiringWarningStrip extends StatelessWidget {
  const _ExpiringWarningStrip({required this.isLight});
  final bool isLight;

  static const _items = <_ExpiringChip>[
    _ExpiringChip(qty: '20 علبة', name: 'مادة تشكيل', days: '7ي'),
    _ExpiringChip(qty: '12 قطعة', name: 'سيراميك زيركون', days: '14ي'),
    _ExpiringChip(qty: '8 كيلو', name: 'سيليكون طبع', days: '28ي'),
  ];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE17B2C);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF5EC),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: const Color(0xFFF6D8B7)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isNarrow = c.maxWidth < 700;
          final left = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.timer_outlined,
                    size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'مواد ستنتهي صلاحيتها قريباً',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightText1,
                        ),
                      ),
                      SizedBox(width: 8),
                      _CountBadge(count: 3),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'يجب التصرف بهذه المواد قبل انتهاء صلاحيتها',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11.5,
                      color: AppColors.lightText3,
                    ),
                  ),
                ],
              ),
            ],
          );
          final right = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _items
                .map((c) => _ExpiringChipView(data: c, accent: accent))
                .toList(growable: false),
          );
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [left, const SizedBox(height: 10), right],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [left, const Spacer(), right],
          );
        },
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE17B2C),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ExpiringChip {
  const _ExpiringChip({
    required this.qty,
    required this.name,
    required this.days,
  });
  final String qty;
  final String name;
  final String days;
}

class _ExpiringChipView extends StatelessWidget {
  const _ExpiringChipView({required this.data, required this.accent});
  final _ExpiringChip data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: const Color(0xFFF1CFA8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.qty,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.lightText1,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '— ${data.name}',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.lightText3,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              data.days,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  4) TODAY ORDERS SECTION
// ══════════════════════════════════════════════════════════════════════════

enum _OrderTab { all, isNew, partial, fulfilled }

extension on _OrderTab {
  String get label => switch (this) {
        _OrderTab.all => 'الكل',
        _OrderTab.isNew => 'جديد',
        _OrderTab.partial => 'جزئي',
        _OrderTab.fulfilled => 'تم التوريد',
      };
}

enum _OrderRowStatus { isNew, partial, fulfilled }

extension on _OrderRowStatus {
  String get label => switch (this) {
        _OrderRowStatus.isNew => 'جديد',
        _OrderRowStatus.partial => 'جزئي',
        _OrderRowStatus.fulfilled => 'تم التوريد',
      };

  Color get color => switch (this) {
        _OrderRowStatus.isNew => const Color(0xFF2C7FDB),
        _OrderRowStatus.partial => const Color(0xFF7A4FCF),
        _OrderRowStatus.fulfilled => const Color(0xFF1F9B6E),
      };
}

class _OrderRow {
  const _OrderRow({
    required this.id,
    required this.requesterInitial,
    required this.requester,
    required this.material,
    required this.quantity,
    required this.date,
    required this.status,
  });
  final String id;
  final String requesterInitial;
  final String requester;
  final String material;
  final String quantity;
  final String date;
  final _OrderRowStatus status;
}

const _todayOrders = <_OrderRow>[
  _OrderRow(
    id: 'REQ-1024',
    requesterInitial: 'م',
    requester: 'مخبر التعويضات',
    material: 'سيراميك زيركون',
    quantity: '10 قطعة',
    date: '27-03-2026',
    status: _OrderRowStatus.isNew,
  ),
  _OrderRow(
    id: 'REQ-1023',
    requesterInitial: 'ع',
    requester: 'عيادة د. سارة',
    material: 'قفازات لاتكس',
    quantity: '5 صناديق',
    date: '27-03-2026',
    status: _OrderRowStatus.partial,
  ),
  _OrderRow(
    id: 'REQ-1022',
    requesterInitial: 'م',
    requester: 'مخبر التعويضات',
    material: 'PFM Alloy',
    quantity: '15 قطعة',
    date: '26-03-2026',
    status: _OrderRowStatus.fulfilled,
  ),
  _OrderRow(
    id: 'REQ-1021',
    requesterInitial: 'ع',
    requester: 'عيادة د. خالد',
    material: 'حقن بنج موضعي',
    quantity: '20 حقنة',
    date: '26-03-2026',
    status: _OrderRowStatus.isNew,
  ),
  _OrderRow(
    id: 'REQ-1020',
    requesterInitial: 'ا',
    requester: 'السكرتارية',
    material: 'أكواب بلاستيكية',
    quantity: '5 علب',
    date: '25-03-2026',
    status: _OrderRowStatus.fulfilled,
  ),
  _OrderRow(
    id: 'REQ-1019',
    requesterInitial: 'م',
    requester: 'مخبر التعويضات',
    material: 'E-max Press',
    quantity: '8 قطعة',
    date: '25-03-2026',
    status: _OrderRowStatus.partial,
  ),
];

int _countOrders(_OrderTab t) {
  switch (t) {
    case _OrderTab.all:
      return _todayOrders.length;
    case _OrderTab.isNew:
      return _todayOrders
          .where((o) => o.status == _OrderRowStatus.isNew)
          .length;
    case _OrderTab.partial:
      return _todayOrders
          .where((o) => o.status == _OrderRowStatus.partial)
          .length;
    case _OrderTab.fulfilled:
      return _todayOrders
          .where((o) => o.status == _OrderRowStatus.fulfilled)
          .length;
  }
}

class _TodayOrdersSection extends StatefulWidget {
  const _TodayOrdersSection({required this.isLight});
  final bool isLight;

  @override
  State<_TodayOrdersSection> createState() => _TodayOrdersSectionState();
}

class _TodayOrdersSectionState extends State<_TodayOrdersSection> {
  _OrderTab _tab = _OrderTab.all;

  List<_OrderRow> get _filtered {
    switch (_tab) {
      case _OrderTab.all:
        return _todayOrders;
      case _OrderTab.isNew:
        return _todayOrders
            .where((o) => o.status == _OrderRowStatus.isNew)
            .toList();
      case _OrderTab.partial:
        return _todayOrders
            .where((o) => o.status == _OrderRowStatus.partial)
            .toList();
      case _OrderTab.fulfilled:
        return _todayOrders
            .where((o) => o.status == _OrderRowStatus.fulfilled)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isLight
            ? AppColors.baseComponent
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: widget.isLight
              ? AppColors.lightBorder
              : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildTabsRow(),
          const _SectionDivider(),
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.assignment_outlined,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'طلبات اليوم',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: widget.isLight
                  ? AppColors.lightText1
                  : AppColors.darkText1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFE3FA),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: const Text(
              '6 طلب',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7A4FCF),
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.go(RouteNames.warehouseOrders),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'عرض الكل ←',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: AppFilterChipRow(
        options: _OrderTab.values
            .map((t) => '${t.label} ${_countOrders(t)}')
            .toList(),
        selectedIndex: _tab.index,
        onChanged: (i) => setState(() => _tab = _OrderTab.values[i]),
      ),
    );
  }

  Widget _buildTable() {
    final rows = _filtered;
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'لا يوجد طلبات بهذا الفلتر',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              color: AppColors.lightText3,
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        _OrdersTableHeader(isLight: widget.isLight),
        for (var i = 0; i < rows.length; i++)
          _OrdersTableRow(
            row: rows[i],
            isLight: widget.isLight,
            isLast: i == rows.length - 1,
          ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Divider(
      height: 1,
      thickness: 1,
      color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
    );
  }
}

// ── Orders Table ───────────────────────────────────────────────────────

class _OrdersTableHeader extends StatelessWidget {
  const _OrdersTableHeader({required this.isLight});
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final bg = isLight
        ? const Color(0xFFF4F1FB)
        : AppColors.darkSurface;
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: const Row(
        children: [
          Expanded(flex: 2, child: _Hcell('رقم الطلب')),
          Expanded(flex: 3, child: _Hcell('الجهة الطالبة')),
          Expanded(flex: 3, child: _Hcell('المادة')),
          Expanded(flex: 2, child: _Hcell('الكمية')),
          Expanded(flex: 3, child: _Hcell('تاريخ الطلب')),
          Expanded(flex: 2, child: _Hcell('الحالة')),
        ],
      ),
    );
  }
}

class _Hcell extends StatelessWidget {
  const _Hcell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText3,
      ),
    );
  }
}

class _OrdersTableRow extends StatelessWidget {
  const _OrdersTableRow({
    required this.row,
    required this.isLight,
    required this.isLast,
  });
  final _OrderRow row;
  final bool isLight;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLight
                ? (isLast ? Colors.transparent : AppColors.lightBorder)
                : (isLast ? Colors.transparent : AppColors.darkBorder),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.id,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight
                    ? AppColors.lightText1
                    : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _RequesterInitialChip(initial: row.requesterInitial),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    row.requester,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? AppColors.lightText1
                          : AppColors.darkText1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.material,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                color: isLight
                    ? AppColors.lightText1
                    : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.quantity,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight
                    ? AppColors.lightText1
                    : AppColors.darkText1,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.date,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.5,
                color: AppColors.lightText3,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _StatusPillSmall(status: row.status),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequesterInitialChip extends StatelessWidget {
  const _RequesterInitialChip({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatusPillSmall extends StatelessWidget {
  const _StatusPillSmall({required this.status});
  final _OrderRowStatus status;

  @override
  Widget build(BuildContext context) {
    final c = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
