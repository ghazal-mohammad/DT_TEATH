import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/core/theme/app_colors.dart';

void main() {
  test('auth accent palette is navy/purple — no turquoise remnants', () {
    expect(AppColors.authBorderBlue, const Color(0xFF141455));
    expect(AppColors.authGlowBlue, const Color(0xFF5959B3));
    expect(AppColors.authPulsePeak, const Color(0xFF5959B3));
    expect(AppColors.authHoverFillStart, const Color(0xFF1A1A2E));
  });
}
