// ════════════════════════════════════════════════════════════════════════════
// warehouse_material_card.dart
//
// Card تعرض بيانات مادة واحدة في شبكة Materials.
//
// 🎯 الهدف:
//   widget قائم بذاته يأخذ WarehouseMaterial ويعرض كل التفاصيل بصرياً
//   مع animations، hover effects، flag للحالة، actions buttons.
//
// 🔮 قابلية التوسيع:
//   - الـ actions تأتي من الخارج (List<MaterialCardAction>) → سهل إضافة/إزالة
//   - الـ flag يُحسب من الحالة → automatic
//   - الـ pulse animation يُفعّل تلقائياً للحالات الحرجة
//
// المرجع: HTML lines 965-1002 (.mc, .mc::before, .mc-tag, .mc-name…)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../domain/entities/material_status.dart';
import '../../../domain/entities/warehouse_material.dart';
import '../../../domain/entities/material_category.dart';

// ══════════════════════════════════════════════════════════════════════════
//                          ACTION DATA
// ══════════════════════════════════════════════════════════════════════════

/// Action واحد على البطاقة (زر سفلي).
class MaterialCardAction {
  const MaterialCardAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;
}

// ══════════════════════════════════════════════════════════════════════════
//                          MATERIAL CARD
// ══════════════════════════════════════════════════════════════════════════

/// بطاقة مادة في شبكة Materials.
///
/// مثال:
/// ```dart
/// WarehouseMaterialCard(
///   material: m,
///   onTap: () => showMaterialDetails(m),
///   actions: [
///     MaterialCardAction(label: 'تعديل', onTap: () => editMat(m)),
///     MaterialCardAction(label: 'استخدام', onTap: () => useMat(m)),
///   ],
/// )
/// ```
class WarehouseMaterialCard extends StatefulWidget {
  const WarehouseMaterialCard({
    super.key,
    required this.material,
    this.onTap,
    this.actions = const [],
  });

  /// المادة المعروضة.
  final WarehouseMaterial material;

  /// callback عند الضغط على البطاقة (غير أزرار actions).
  final VoidCallback? onTap;

  /// الـ actions السفلية (يُفضّل 0-3 لتجنّب الزحام).
  final List<MaterialCardAction> actions;

  @override
  State<WarehouseMaterialCard> createState() => _WarehouseMaterialCardState();
}

class _WarehouseMaterialCardState extends State<WarehouseMaterialCard>
    with TickerProviderStateMixin {
  bool _hovered = false;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    _setupPulseIfNeeded();
  }

  @override
  void didUpdateWidget(covariant WarehouseMaterialCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إذا تغيّرت الحالة من/إلى pulsing، نحدّث الـ controller.
    final shouldPulse = widget.material.status.shouldPulse;
    final isActive = _pulseController != null;
    if (shouldPulse && !isActive) {
      _setupPulseIfNeeded();
    } else if (!shouldPulse && isActive) {
      _pulseController?.dispose();
      _pulseController = null;
    }
  }

  void _setupPulseIfNeeded() {
    if (widget.material.status.shouldPulse) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final m = widget.material;
    final status = m.status;

    Widget card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _hovered ? -5.0 : 0.0, 0.0, 1.0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            // dark gradient في dark mode، sterile في light
            gradient: isLight
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.statCardDarkStart,
                      AppColors.statCardDarkEnd,
                    ],
                  ),
            color: isLight ? AppColors.baseComponent : null,
            border: Border.all(
              color: _resolveBorderColor(isLight, status),
              width: AppSizes.borderThin,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.dashCyan.withValues(alpha: 0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            child: Stack(
              children: [
                // ::before — gradient line يظهر عند hover
                _buildHoverLine(),

                // المحتوى الرئيسي
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCategoryTag(context),
                    const SizedBox(height: 7),
                    _buildName(isLight),
                    const SizedBox(height: 3),
                    _buildQuantity(isLight),
                    const SizedBox(height: 9),
                    _buildFooter(context, isLight),
                    if (widget.actions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildActions(isLight),
                    ],
                  ],
                ),

                // flag في الزاوية البعيدة (RTL-aware)
                if (status.showsFlag) _buildFlag(context, status),
              ],
            ),
          ),
        ),
      ),
    );

    // pulse للحالات الحرجة
    if (_pulseController != null) {
      card = FadeTransition(
        opacity:
            Tween<double>(begin: 1.0, end: 0.85).animate(_pulseController!),
        child: card,
      );
    }

    return card;
  }

  // ────────────────────────────────────────────────────────────────────────
  //                          BUILDERS
  // ────────────────────────────────────────────────────────────────────────

  /// لون البوردر يتغيّر حسب الحالة.
  Color _resolveBorderColor(bool isLight, MaterialStatus status) {
    if (status == MaterialStatus.outOfStock || status == MaterialStatus.low) {
      return AppColors.alertRed.withValues(alpha: 0.30);
    }
    if (status == MaterialStatus.expiringSoon) {
      return AppColors.dashOrange.withValues(alpha: 0.30);
    }
    return isLight ? AppColors.lightBorder : AppColors.darkBorder;
  }

  /// ::before — gradient line في الأعلى (يظهر عند hover).
  Widget _buildHoverLine() {
    // ملاحظة RTL: full-width line — left:0 + right:0 متماثل، آمن للـ RTL.
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _hovered ? 1.0 : 0.0,
        child: Container(
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.dashCyan, AppColors.dashViolet],
            ),
          ),
        ),
      ),
    );
  }

  /// الـ category tag في الأعلى.
  Widget _buildCategoryTag(BuildContext context) {
    final color = widget.material.category.accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: AppSizes.borderThin,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        widget.material.category.label(context),
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: color,
        ),
      ),
    );
  }

  /// اسم المادة.
  Widget _buildName(bool isLight) {
    return Text(
      widget.material.name,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: isLight ? AppColors.lightText1 : AppColors.darkText1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// الكمية (رقم كبير + الوحدة).
  Widget _buildQuantity(bool isLight) {
    final m = widget.material;
    final color = _quantityColor(m.status, isLight);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          m.quantity.toString(),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.0,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          m.unit,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: isLight ? AppColors.lightText3 : AppColors.darkText3,
          ),
        ),
      ],
    );
  }

  /// لون الـ quantity number — يتلوّن حسب severity.
  Color _quantityColor(MaterialStatus status, bool isLight) {
    if (status == MaterialStatus.outOfStock ||
        status == MaterialStatus.expired) {
      return AppColors.alertRed;
    }
    if (status == MaterialStatus.low) {
      return AppColors.dashOrange;
    }
    return isLight ? AppColors.lightText1 : AppColors.darkText1;
  }

  /// الـ footer — صف من معلومات إضافية (min, expiry).
  Widget _buildFooter(BuildContext context, bool isLight) {
    final m = widget.material;
    final borderColor = isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return Container(
      padding: const EdgeInsetsDirectional.only(top: 9),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: AppSizes.borderThin),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFooterItem(
              context,
              label: context.l10n.whMaterialMinStock,
              value: m.minStock.toString(),
              isLight: isLight,
            ),
          ),
          if (m.expiryDate != null)
            Expanded(
              child: _buildFooterItem(
                context,
                label: context.l10n.whMaterialExpiryDate,
                value: _formatDaysLeft(m.daysUntilExpiry ?? 0, context),
                valueColor: AppColors.expiryColorFor(m.daysUntilExpiry ?? 999),
                isLight: isLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    required bool isLight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: isLight ? AppColors.lightText4 : AppColors.darkText4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: valueColor ??
                (isLight ? AppColors.lightText1 : AppColors.darkText1),
          ),
        ),
      ],
    );
  }

  /// flag في الزاوية البعيدة (top-start في RTL = top-left بصرياً).
  Widget _buildFlag(BuildContext context, MaterialStatus status) {
    // ملاحظة RTL: flag في "الزاوية البعيدة عن البداية" — top:9, end:9.
    // في RTL → يظهر يسار، في LTR → يمين. هذا متّسق مع الـ HTML الأصلي
    // الذي استخدم top:9, left:9 (LTR) — في RTL يصبح يمين.
    return PositionedDirectional(
      top: 9,
      end: 9,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: status.accentColor.withValues(alpha: 0.15),
          border: Border.all(
            color: status.accentColor.withValues(alpha: 0.30),
            width: AppSizes.borderThin,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          status.label(context),
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: status.accentColor,
          ),
        ),
      ),
    );
  }

  /// أزرار actions السفلية.
  Widget _buildActions(bool isLight) {
    final children = <Widget>[];
    for (var i = 0; i < widget.actions.length; i++) {
      children.add(Expanded(
        child: _buildActionButton(widget.actions[i], isLight),
      ));
      if (i < widget.actions.length - 1) {
        children.add(const SizedBox(width: 4));
      }
    }
    return Row(children: children);
  }

  /// زر action واحد.
  Widget _buildActionButton(MaterialCardAction action, bool isLight) {
    return _ActionButton(
      label: action.label,
      onTap: action.onTap,
      isLight: isLight,
    );
  }

  /// تنسيق "الأيام المتبقية" بشكل قابل للقراءة.
  String _formatDaysLeft(int days, BuildContext context) {
    if (days < 0) return context.l10n.whStatusOut;
    return '$days';
  }
}

// ══════════════════════════════════════════════════════════════════════════
//                          ACTION BUTTON (داخلي)
// ══════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.isLight,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLight;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final defaultColor = widget.isLight
        ? AppColors.lightText2
        : AppColors.darkText2;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.dashCyan.withValues(alpha: 0.08)
                : AppColors.dashCyan.withValues(alpha: 0.04),
            border: Border.all(
              color: _hovered
                  ? AppColors.dashCyan
                  : (widget.isLight
                      ? AppColors.lightBorder
                      : AppColors.darkBorder),
              width: AppSizes.borderThin,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: _hovered ? AppColors.dashCyan : defaultColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
