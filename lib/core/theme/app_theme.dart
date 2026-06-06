// ════════════════════════════════════════════════════════════════════════════
// app_theme.dart
//
// ThemeData كامل للوضع الداكن والفاتح.
// القرار 15: دعم Dark/Light Mode (موجودان في HTML الأصلي).
//
// الاستخدام في MaterialApp:
//   themeMode: ThemeMode.dark,  // أو ThemeMode.light أو ThemeMode.system
//   theme: AppTheme.lightTheme,
//   darkTheme: AppTheme.darkTheme,
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════════════
  //                              الوضع الداكن
  // ══════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.brand, // إندِغو — اللون التفاعلي/المملوء بالغامق
      onPrimary: Colors.white,
      secondary: AppColors.secondary, // الوردي
      onSecondary: AppColors.darkText1,
      tertiary: AppColors.success,
      onTertiary: AppColors.darkText1,
      error: AppColors.error,
      onError: AppColors.darkText1,
      surface: AppColors.darkBg1, // #262838 — سطح الكروت
      onSurface: AppColors.darkText1, // #E6E7F0 — نص أساسي
      surfaceContainerHighest: AppColors.darkBg2, // #20222F — تعبئة خفيفة
      outline: AppColors.darkBorder, // #3A3D52
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      canvasColor: AppColors.darkBg,
      dividerColor: AppColors.darkBorder,

      // ── Typography ─────────────────────────────────────────────────────
      textTheme: _buildTextTheme(AppColors.darkText1, AppColors.darkText2),
      primaryTextTheme:
          _buildTextTheme(AppColors.darkText1, AppColors.darkText2),

      // ── Buttons ────────────────────────────────────────────────────────
      elevatedButtonTheme: _elevatedButtonTheme(isDark: true),
      outlinedButtonTheme: _outlinedButtonTheme(isDark: true),
      textButtonTheme: _textButtonTheme(isDark: true),

      // ── Inputs ─────────────────────────────────────────────────────────
      inputDecorationTheme: _inputDecorationTheme(isDark: true),

      // ── Cards & Dialogs ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkBg1,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
      ),

      // ── Scrollbar ──────────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor:
            WidgetStateProperty.all(AppColors.brand.withValues(alpha: 0.4)),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),

      // ── System UI ──────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg1,
        foregroundColor: AppColors.darkText1,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkBg2,
        contentTextStyle:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.darkText1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
      ),

      // ── Icons ──────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.darkText2,
        size: AppSizes.iconMD,
      ),

      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //                              الوضع الفاتح
  //
  // مُحاذى مع Design System Contract (2026-05-05):
  //   - خلفية الصفحة: bgGeneral (#E9ECFB @ 68%)
  //   - الكروت/الـ surfaces: baseComponent (#FFFFFF نقي)
  //   - النص الأساسي/العناوين: primary (#1A1C4E)
  //   - النص الثانوي: guideSecondaryText (#353535)
  //   - الكروت بدون border — الظل بكفي (راجع AppCard widget).
  // ══════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.baseComponent,
      secondary: AppColors.secondary,
      onSecondary: AppColors.primary,
      tertiary: AppColors.success,
      onTertiary: AppColors.baseComponent,
      error: AppColors.alertRed,
      onError: AppColors.baseComponent,
      surface: AppColors.baseComponent,
      onSurface: AppColors.primary,
      surfaceContainerHighest: AppColors.bgGeneral,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgGeneral,
      canvasColor: AppColors.bgGeneral,
      dividerColor: AppColors.lightBorder,

      // النصوص: العناوين/النص الأساسي بـ primary، الثانوي بـ #353535.
      textTheme:
          _buildTextTheme(AppColors.primary, AppColors.guideSecondaryText),
      primaryTextTheme:
          _buildTextTheme(AppColors.primary, AppColors.guideSecondaryText),

      elevatedButtonTheme: _elevatedButtonTheme(isDark: false),
      outlinedButtonTheme: _outlinedButtonTheme(isDark: false),
      textButtonTheme: _textButtonTheme(isDark: false),

      inputDecorationTheme: _inputDecorationTheme(isDark: false),

      // الكروت: خلفية بيضا نقية، بدون border (الظل عبر AppCard widget).
      cardTheme: CardThemeData(
        color: AppColors.baseComponent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.baseComponent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor:
            WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.3)),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.baseComponent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.baseComponent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: AppSizes.iconMD,
      ),

      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //                          Helpers (مشتركة)
  // ══════════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: primary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: primary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: primary),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: primary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: primary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: secondary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondary),
      labelLarge: AppTextStyles.buttonText.copyWith(color: primary),
      labelMedium: AppTextStyles.sidebarItem.copyWith(color: primary),
      labelSmall: AppTextStyles.badge.copyWith(color: secondary),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({required bool isDark}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppColors.brand : AppColors.primary,
        // أبيض فوق الأزرار المملوءة في الوضعين (baseComponent = #FFFFFF).
        foregroundColor: isDark ? Colors.white : AppColors.baseComponent,
        textStyle: AppTextStyles.buttonText,
        elevation: 0,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceLG,
          vertical: AppSizes.spaceSM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.darkText1 : AppColors.primary,
        textStyle: AppTextStyles.buttonText,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceLG,
          vertical: AppSizes.spaceSM,
        ),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: AppSizes.borderThin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme({required bool isDark}) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark ? AppColors.brand : AppColors.primary,
        textStyle: AppTextStyles.buttonText,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceMD,
          vertical: AppSizes.spaceSM,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) {
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    // Light: حقل أبيض نقي (baseComponent). Dark: surface الشفافة.
    final fillColor = isDark ? AppColors.darkSurface : AppColors.baseComponent;
    final hintColor =
        isDark ? AppColors.darkText4 : AppColors.guideSecondaryText;
    // التركيز: brand (إندِغو) للـ dark، primary (كحلي) للـ light.
    final focusColor = isDark ? AppColors.brand : AppColors.primary;
    // الخطأ: error للـ dark (وردي)، alertRed للـ light (#EF4444).
    final errorColor = isDark ? AppColors.error : AppColors.alertRed;

    OutlineInputBorder border(Color color, {double width = 1.0}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceMD,
        vertical: AppSizes.spaceSM,
      ),
      hintStyle: AppTextStyles.bodyLarge.copyWith(color: hintColor),
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(focusColor, width: AppSizes.borderMedium),
      errorBorder: border(errorColor),
      focusedErrorBorder: border(errorColor, width: AppSizes.borderMedium),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: errorColor),
    );
  }
}
