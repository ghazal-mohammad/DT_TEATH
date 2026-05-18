// ════════════════════════════════════════════════════════════════════════════
// auth_background_painter.dart
//
// أدوات الرسم لصفحات Auth:
//   - AuthWhiteClipper: يقطع الجانب الأبيض (شكل شبه منحرف مائل)
//   - AuthDiagonalGlowPainter: يرسم خط التوهج على الحد القطري
//   - AuthBackgroundPainter: للـ mobile (خلفية + خط قطري)
//
// الألوان المستخدمة من الباليت الرسمي فقط:
//   - #1A1C4E (primary)
//   - #BED8FA (tableHeader — Table Header/BGtext fields)
//   - #FFFFFF (white)
// لا تركواز / لا accent #9EFBEC
// ════════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════
//   قاطع الجانب الأبيض (diagonal clip للجانب الأيمن)
// ══════════════════════════════════════════════════════════════════════════

/// يقطع شبه منحرف يغطي الجانب الأيمن من الشاشة.
/// الحد القطري: من (62%, top) إلى (48%, bottom).
class AuthWhiteClipper extends CustomClipper<Path> {
  const AuthWhiteClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.62, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.48, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ══════════════════════════════════════════════════════════════════════════
//   رسم خط التوهج على الحد القطري
// ══════════════════════════════════════════════════════════════════════════

/// يرسم خط توهج على الحد القطري بين الجانبين.
/// اللون: #BED8FA (Table Header من الباليت).
class AuthDiagonalGlowPainter extends CustomPainter {
  const AuthDiagonalGlowPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset lineStart = Offset(size.width * 0.62, 0);
    final Offset lineEnd = Offset(size.width * 0.48, size.height);

    // طبقة 1: outer glow عريضة
    canvas.drawLine(
      lineStart,
      lineEnd,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32
        ..color = AppColors.tableHeader.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // طبقة 2: mid glow
    canvas.drawLine(
      lineStart,
      lineEnd,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = AppColors.tableHeader.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // طبقة 3: خط أساسي مع نبضة خفيفة
    final double pulse = 0.60 + 0.28 * math.sin(phase * 0.5);
    canvas.drawLine(
      lineStart,
      lineEnd,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = AppColors.tableHeader.withValues(alpha: pulse),
    );
  }

  @override
  bool shouldRepaint(covariant AuthDiagonalGlowPainter old) =>
      old.phase != phase;
}

// ══════════════════════════════════════════════════════════════════════════
//   للـ mobile / legacy — خلفية + خط قطري (بدون تركواز)
// ══════════════════════════════════════════════════════════════════════════

/// رسام الخلفية للـ mobile login (خلفية primary + نبضة خط قطري بـ BED8FA).
class AuthBackgroundPainter extends CustomPainter {
  const AuthBackgroundPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    // خلفية primary صلبة
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.primary,
    );

    // مثلث خفيف للعمق
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = AppColors.tableHeader.withValues(alpha: 0.04),
    );

    // خط قطري neon (BED8FA)
    final Offset start = Offset(size.width, 0);
    final Offset end = Offset(0, size.height);

    canvas.drawLine(
      start,
      end,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = AppColors.tableHeader.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawLine(
      start,
      end,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.tableHeader.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    final double pulse = 0.60 + 0.22 * math.sin(phase * 0.6);
    canvas.drawLine(
      start,
      end,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = AppColors.tableHeader.withValues(alpha: pulse),
    );
  }

  @override
  bool shouldRepaint(covariant AuthBackgroundPainter old) =>
      old.phase != phase;
}
