// ════════════════════════════════════════════════════════════════════════════
// warehouse_dashboard_expiring.dart
//
// شريط تنبيه انتهاء الصلاحية — part of warehouse_dashboard_content.dart (تقسيم الصفحات العملاقة).
// تشارك نفس الاستيرادات المعرّفة في الملف الرئيسي.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_dashboard_content.dart';

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
    const accent = AppColors.statusWarn;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warnTintLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.warnBorderLight),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.whExpiringTitle,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lightText1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _CountBadge(count: 3),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.whExpiringSubtitle,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
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
        color: AppColors.statusWarn,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
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
        border: Border.all(color: AppColors.amberBorderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.qty,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.lightText1,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '— ${data.name}',
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
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
                fontSize: 11,
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
