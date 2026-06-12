// ════════════════════════════════════════════════════════════════════════════
// app_stat_card.dart
//
// بطاقة الإحصاء (KPI Card) — `.sc` + variants: `.cc`, `.cg`, `.co`, `.cr`, `.cv`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 685–739
//
// المميّزات البصرية المطابقة:
//   - خلفية linear-gradient(145deg, rgba(15,30,66,0.8), rgba(10,20,44,0.7))
//   - backdrop-filter:blur(10px)
//   - شريط علوي ملوّن (::before) بارتفاع 2px بـ gradient حسب النوع
//   - hover: translateY(-5px) scale(1.02) + radial glow
//   - hover glow: box-shadow بلون مطابق للنوع
//   - القيمة (`.sc-val`): نص gradient 34px font-weight:900
//   - countUp animation عند الظهور الأول
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';

/// أنواع بطاقة الإحصاء الخمسة.
enum AppStatCardVariant {
  /// Cyan — سماوي/أزرق (`.cc`). للإحصاءات الافتراضية.
  cyan,

  /// Green — أخضر/تركوازي (`.cg`). للنجاحات والمكتملات.
  green,

  /// Gold — ذهبي/عنبري (`.co`). للتحذيرات المعتدلة.
  gold,

  /// Red — وردي/أحمر (`.cr`). للإحصاءات الحرجة (مع نبض).
  red,

  /// Violet — بنفسجي/وردي (`.cv`). للمخبر/الخاص.
  violet,
}

/// اتجاه chip التغيير (زيادة/نقصان).
enum AppStatTrend { up, down, warning, ok }

/// بطاقة إحصاء موحّدة — تعرض قيمة رقمية مع أيقونة وعنوان.
///
/// مثال:
/// ```dart
/// AppStatCard(
///   icon: Icons.inventory_2,
///   value: '247',
///   label: 'عدد المواد',
///   variant: AppStatCardVariant.cyan,
///   trend: AppStatTrend.up,
///   trendLabel: '+12',
/// )
/// ```
class AppStatCard extends StatefulWidget {
  const AppStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.variant = AppStatCardVariant.cyan,
    this.trend,
    this.trendLabel,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final AppStatCardVariant variant;
  final AppStatTrend? trend;
  final String? trendLabel;
  final VoidCallback? onTap;

  @override
  State<AppStatCard> createState() => _AppStatCardState();
}

class _AppStatCardState extends State<AppStatCard>
    with TickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _countUpController;
  late final Animation<double> _countUpAnim;

  AnimationController? _pulseController;
  

  @override
  void initState() {
    super.initState();
    // countUp 0.6s cubic-bezier(0.34,1.56,0.64,1)
    _countUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _countUpAnim = CurvedAnimation(
      parent: _countUpController,
      curve: const Cubic(0.34, 1.56, 0.64, 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _countUpController.forward();
    });

    // .cr hover: animation:alertPulse 2s infinite
    if (widget.variant == AppStatCardVariant.red) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void didUpdateWidget(covariant AppStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تشغيل/إيقاف النبض عند الـ hover للنوع الأحمر فقط
    if (widget.variant == AppStatCardVariant.red) {
      if (_isHovered && !_pulseController!.isAnimating) {
        _pulseController!.repeat();
      } else if (!_isHovered && _pulseController!.isAnimating) {
        _pulseController!.stop();
        _pulseController!.reset();
      }
    }
  }

  @override
  void dispose() {
    _countUpController.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _StatCardColors colors = _resolveColors(widget.variant);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        setState(() => _isHovered = true);
        if (widget.variant == AppStatCardVariant.red) {
          _pulseController?.repeat();
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _pulseController?.stop();
        _pulseController?.reset();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280), // 0.28s
          curve: const Cubic(0.34, 1.2, 0.64, 1),
          transform: _isHovered
              ? (Matrix4.identity()
                  ..translate(0.0, -5.0, 0.0) // translateY(-5px)
                  ..scale(1.02)) // scale(1.02)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight, // 145deg
              colors: [
                Color(0xCC0F1E42), // rgba(15,30,66,0.8)
                Color(0xB30A142C), // rgba(10,20,44,0.7)
              ],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            border: Border.all(color: AppColors.darkBorder),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: colors.glow,
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            child: Stack(
              children: [
                // ::before — الشريط العلوي الملوّن بارتفاع 2px
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors.barGradient,
                      ),
                    ),
                  ),
                ),
                // ::after — radial glow عند الـ hover
                if (_isHovered)
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.0,
                          colors: [
                            Color(0x0AFFFFFF), // 0.04
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTopRow(colors),
                      const SizedBox(height: 9),
                      _buildValue(colors),
                      const SizedBox(height: 2),
                      _buildLabel(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(_StatCardColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // .sc-ico — 40x40 مع خلفية مطابقة للنوع
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, size: 17, color: colors.iconFg),
        ),
        // .sc-chip — الـ chip الصغير (زيادة/نقصان)
        if (widget.trend != null && widget.trendLabel != null)
          _buildTrendChip(),
      ],
    );
  }

  Widget _buildTrendChip() {
    final Color bg;
    final Color fg;
    final IconData? trendIcon;
    switch (widget.trend!) {
      case AppStatTrend.up:
        bg = const Color(0x330DBD7F); // 0.20
        fg = const Color(0xFF86EFAC);
        trendIcon = Icons.arrow_upward;
        break;
      case AppStatTrend.down:
        bg = const Color(0x33ED8BFA);
        fg = const Color(0xFFC4B5FD);
        trendIcon = Icons.arrow_downward;
        break;
      case AppStatTrend.warning:
        bg = const Color(0x33EDFB9E);
        fg = const Color(0xFFECFB9E);
        trendIcon = Icons.warning_amber_rounded;
        break;
      case AppStatTrend.ok:
        bg = const Color(0x339EFBEC);
        fg = const Color(0xFF9EFBEC);
        trendIcon = Icons.check;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: 11, color: fg),
          const SizedBox(width: 2),
          Text(
            widget.trendLabel!,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValue(_StatCardColors colors) {
    // القيمة بنص gradient (34px, weight:900)
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(_countUpAnim),
      child: FadeTransition(
        opacity: _countUpAnim,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight, // 135deg
            colors: colors.valueGradient,
          ).createShader(bounds),
          child: Text(
            widget.value,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white, // base for shader
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.label,
      style: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 13,
        color: AppColors.darkText3,
        height: 1.3,
      ),
    );
  }

  _StatCardColors _resolveColors(AppStatCardVariant variant) {
    switch (variant) {
      case AppStatCardVariant.cyan:
        return const _StatCardColors(
          barGradient: [Color(0xFF9EFBEC), Color(0xFF3A5AB8)],
          iconBg: Color(0x299EFBEC), // 0.16
          iconFg: AppColors.accent,
          valueGradient: [Color(0xFF9EFBEC), Color(0xFF3A5AB8)],
          glow: Color(0x2E9EFBEC), // 0.18
        );
      case AppStatCardVariant.green:
        return const _StatCardColors(
          barGradient: [Color(0xFF0DBD7F), Color(0xFF14B8A6)],
          iconBg: Color(0x2E0DBD7F),
          iconFg: Color(0xFF0DBD7F),
          valueGradient: [Color(0xFF0DBD7F), Color(0xFF14B8A6)],
          glow: Color(0x2E0DBD7F),
        );
      case AppStatCardVariant.gold:
        return const _StatCardColors(
          barGradient: [Color(0xFFF97316), Color(0xFFFBBF24)],
          iconBg: Color(0x2EEDFB9E),
          iconFg: Color(0xFFECFB9E),
          valueGradient: [Color(0xFFF97316), Color(0xFFFBBF24)],
          glow: Color(0x2EEDFB9E),
        );
      case AppStatCardVariant.red:
        return const _StatCardColors(
          barGradient: [Color(0xFFEF4444), Color(0xFFED8BFA)],
          iconBg: Color(0x29ED8BFA),
          iconFg: Color(0xFFED8BFA),
          valueGradient: [Color(0xFFEF4444), Color(0xFFED8BFA)],
          glow: Color(0x2EED8BFA),
        );
      case AppStatCardVariant.violet:
        return const _StatCardColors(
          barGradient: [Color(0xFF7C3AED), Color(0xFFED8BFA)],
          iconBg: Color(0x29ED8BFA),
          iconFg: Color(0xFF7C3AED),
          valueGradient: [Color(0xFF7C3AED), Color(0xFFED8BFA)],
          glow: Color(0x2EED8BFA),
        );
    }
  }
}

class _StatCardColors {
  const _StatCardColors({
    required this.barGradient,
    required this.iconBg,
    required this.iconFg,
    required this.valueGradient,
    required this.glow,
  });

  final List<Color> barGradient;
  final Color iconBg;
  final Color iconFg;
  final List<Color> valueGradient;
  final Color glow;
}

/// شبكة 4-أعمدة تلقائية لـ StatCards — `.stat-g`.
///
/// تلتف في الشاشات الصغيرة (responsive).
class AppStatGrid extends StatelessWidget {
  const AppStatGrid({
    super.key,
    required this.children,
    this.columnsLarge = 4,
    this.columnsMedium = 2,
    this.columnsSmall = 1,
    this.breakpointLarge = 900,
    this.breakpointMedium = 600,
  });

  final List<Widget> children;
  final int columnsLarge;
  final int columnsMedium;
  final int columnsSmall;
  final double breakpointLarge;
  final double breakpointMedium;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= breakpointLarge
            ? columnsLarge
            : constraints.maxWidth >= breakpointMedium
            ? columnsMedium
            : columnsSmall;

        const double gap = 14; // CSS: gap:14px

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children.map((c) {
            final double width =
                (constraints.maxWidth - (gap * (columns - 1))) / columns;
            return SizedBox(width: width, child: c);
          }).toList(),
        );
      },
    );
  }
}
