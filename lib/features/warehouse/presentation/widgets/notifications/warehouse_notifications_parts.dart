// ════════════════════════════════════════════════════════════════════════════
// warehouse_notifications_parts.dart
//
// الأجزاء الداخلية الخاصّة لمحتوى إشعارات المستودع (عنوان اليوم + بطاقة الإشعار +
// شارة الفئة + زر الإجراء + شريط الفلاتر). part of warehouse_notifications_content.
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_notifications_content.dart';

// ══════════════════════════════════════════════════════════════════════════
//                              DAY HEADER
// ══════════════════════════════════════════════════════════════════════════

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.isLight});

  final String label;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 2),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.lightText3 : AppColors.darkText3,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                              NOTIFICATION CARD
// ══════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({
    required this.isLight,
    required this.notification,
    required this.onMarkRead,
  });

  final bool isLight;
  final WarehouseNotification notification;
  final VoidCallback onMarkRead;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _hover = false;

  bool get isLight => widget.isLight;
  WarehouseNotification get notification => widget.notification;
  VoidCallback get onMarkRead => widget.onMarkRead;

  bool get _isUrgent => _isUrgentN(notification);

  // الباليتة الدلالية الموحّدة (نفس إشعارات المخبر).
  Color get _accentColor {
    if (_isUrgent) return AppColors.statusUrgent;
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return AppColors.statusWarn;
      case NotificationCategory.order:
        return AppColors.statusInfo;
      case NotificationCategory.general:
        return AppColors.statusSuccess;
    }
  }

  Color get _accentBg {
    if (_isUrgent) {
      return isLight ? AppColors.statusUrgentBg : AppColors.darkChipRedBg;
    }
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return isLight ? AppColors.statusWarnBg : AppColors.darkChipOrangeBg;
      case NotificationCategory.order:
        return isLight ? AppColors.statusInfoBg : AppColors.darkChipBlueBg;
      case NotificationCategory.general:
        return isLight ? AppColors.statusSuccessBg : AppColors.darkChipGreenBg;
    }
  }

  IconData get _icon {
    switch (notification.category) {
      case NotificationCategory.low:
        return Icons.inventory_2_outlined;
      case NotificationCategory.expiry:
        return Icons.timer_outlined;
      case NotificationCategory.order:
        return Icons.shopping_bag_outlined;
      case NotificationCategory.general:
        return Icons.info_outline;
    }
  }

  String _badgeText(AppLocalizations l10n) {
    if (_isUrgent) return l10n.ordersUrgent;
    switch (notification.category) {
      case NotificationCategory.low:
      case NotificationCategory.expiry:
        return l10n.notifFilterMaterials;
      case NotificationCategory.order:
        return l10n.notifBadgeOrder;
      case NotificationCategory.general:
        return l10n.notifBadgeDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final radius = BorderRadius.circular(AppSizes.radiusLG);

    // التصميم الأبيض الموحّد — مطابق لبطاقة إشعارات المخبر بالحرف:
    // كرت أبيض + شريط جانبي ملوّن (end) + أيقونة دائرية + hover lift.
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: isLight
              ? (notification.isRead ? AppColors.surfaceFaint : Colors.white)
              : (notification.isRead ? AppColors.darkBg2 : AppColors.darkBg1),
          borderRadius: radius,
          border: Border.all(
              color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.05 : 0.02),
              blurRadius: _hover ? 14 : 8,
              offset: Offset(0, _hover ? 6 : 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // الشريط الجانبي الملوّن — حافة يسرى بصرياً (end في RTL)
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: _accentColor),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon دائري على اليمين (start في RTL)
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _accentBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_icon, size: 20, color: _accentColor),
                    ),
                    const SizedBox(width: 12),
                    // body content (وسط)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  notification.title,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isLight
                                        ? AppColors.lightText1
                                        : AppColors.darkText1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _CategoryBadge(
                                  text: _badgeText(l10n),
                                  color: _accentColor),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.body,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isLight
                                  ? AppColors.lightText2
                                  : AppColors.darkText2,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                _badgeText(l10n),
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isLight
                                      ? AppColors.lightText3
                                      : AppColors.darkText3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('·',
                                  style: TextStyle(
                                    color: isLight
                                        ? AppColors.lightText4
                                        : AppColors.darkText4,
                                  )),
                              const SizedBox(width: 6),
                              Text(
                                notification.time,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isLight
                                      ? AppColors.lightText3
                                      : AppColors.darkText3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // action button على اليسار (end في RTL)
                    if (notification.actionLabel != null) ...[
                      const SizedBox(width: 16),
                      _ActionBtn(
                        label: notification.actionLabel!,
                        color: _accentColor,
                        onTap: () {
                          if (!notification.isRead) onMarkRead();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isUrgentN(WarehouseNotification n) => _isUrgent(n);

// ── Pieces ──────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// زر الإجراء — نفس ستايل المخبر (أبيض بحدود ملوّنة).
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : AppColors.darkBg1,
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                  FILTER PILLS + MARK-ALL-READ BUTTON ROW
// ══════════════════════════════════════════════════════════════════════════

class _FilterAndActionRow extends StatelessWidget {
  const _FilterAndActionRow({
    required this.filter,
    required this.counts,
    required this.onChanged,
    required this.showMarkAll,
    required this.onMarkAll,
    required this.isLight,
  });

  final _NotifFilter filter;
  final Map<_NotifFilter, int> counts;
  final ValueChanged<_NotifFilter> onChanged;
  final bool showMarkAll;
  final VoidCallback onMarkAll;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final pills = AppSegmentedTabs<_NotifFilter>(
      values: _NotifFilter.values,
      selected: filter,
      labelOf: (f) => f.label(context.l10n),
      countOf: (f) => counts[f] ?? 0,
      onChanged: onChanged,
    );

    final markBtn = showMarkAll
        ? InkWell(
            onTap: onMarkAll,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isLight ? AppColors.surfaceTintCool2 : AppColors.darkBg2,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                border: Border.all(
                  color:
                      isLight ? AppColors.lightBorder : AppColors.darkBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded,
                      size: 16,
                      color: isLight
                          ? AppColors.lightText2
                          : AppColors.darkText2),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.notifMarkAllRead,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isLight
                          ? AppColors.lightText2
                          : AppColors.darkText2,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();

    // في RTL: أوّل child = يمين. لتثبيت pills يمين و markBtn يسار:
    // [pills, Spacer, markBtn].
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: pills),
        const SizedBox(width: 10),
        const Spacer(),
        markBtn,
      ],
    );
  }
}
