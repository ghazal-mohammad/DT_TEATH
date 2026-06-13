// ════════════════════════════════════════════════════════════════════════════
// lab_notification_card.dart
//
// بطاقة إشعار المخبر (شريط ملوّن + أيقونة + عنوان + شارة + وصف + meta + إجراء)
// — مُستخرَجة من lab_notifications_page.dart ضمن تقسيم الصفحات.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'lab_notification_data.dart';

/// بطاقة إشعار واحدة في قائمة الإشعارات.
class LabNotificationCard extends StatefulWidget {
  const LabNotificationCard({super.key, required this.item});
  final NotificationItem item;

  @override
  State<LabNotificationCard> createState() => _LabNotificationCardState();
}

class _LabNotificationCardState extends State<LabNotificationCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.item;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final s = notificationStyleOf(n.kind, isLight);
    final radius = BorderRadius.circular(AppSizes.radiusLG);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: isLight
              ? (n.isRead ? AppColors.surfaceFaint : Colors.white)
              : (n.isRead ? AppColors.darkBg2 : AppColors.darkBg1),
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
                child: Container(width: 4, color: s.fg),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 18, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // icon round على اليمين (start في RTL) — يطابق المحاكاة
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: s.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(n.icon, size: 20, color: s.fg),
                    ),
                    const SizedBox(width: 12),
                    // body content (وسط)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // العنوان أولاً (يمين بـ RTL) ثم الـ Pill على يساره
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  n.title,
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
                              _Pill(
                                  label: notificationKindLabel(context, n.kind),
                                  color: s.fg,
                                  bg: s.bg),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n.description,
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
                                n.category,
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
                                n.timeLabel,
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
                    // action button على اليسار (end في RTL) — يطابق المحاكاة
                    if (n.action != null) ...[
                      const SizedBox(width: 16),
                      _ActionBtn(
                        label: n.action!,
                        color: s.fg,
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

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, required this.bg});
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
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

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
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
