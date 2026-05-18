// ════════════════════════════════════════════════════════════════════════════
// validators.dart
//
// دوال التحقق من صحة المدخلات (Email, Password, OTP).
// مُستخدمة في:
//   - Email Entry screen (Phase 3.3)
//   - Set Password screen (Phase 3.5)
//   - OTP input (Phase 3.4)
//
// فلسفة التصميم:
//   - كل validator يرجع `String?` — null = valid، string = رسالة خطأ
//   - الرسائل بالإنجليزية (الترجمة من .arb files عبر context.l10n)
//   - validators **pure functions** — لا state، لا side effects
//
// الاستخدام مع TextFormField:
//   TextFormField(
//     validator: (value) => Validators.email(value, context.l10n),
//   )
//
// المرجع:
//   - RFC 5322 (Email format): https://datatracker.ietf.org/doc/html/rfc5322
//   - OWASP Password Guidelines: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
// ════════════════════════════════════════════════════════════════════════════

import '../l10n/generated/app_localizations.dart';

/// نتيجة التحقق من كلمة المرور — تحدد قوتها لعرض meter.
enum PasswordStrength {
  /// أقل من 8 أحرف أو نمط بسيط.
  weak,

  /// 8+ أحرف مع تنوع معقول.
  medium,

  /// 12+ أحرف مع تنوع قوي (أحرف + أرقام + رموز).
  strong,
}

/// Extension يعطي قيمة تقدمية (0.0 - 1.0) لعرض progress bar.
extension PasswordStrengthX on PasswordStrength {
  /// قيمة من 0.0 إلى 1.0 لعرض المستوى بصرياً.
  double get value {
    switch (this) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}

/// مجموعة validators ثابتة.
class Validators {
  Validators._();

  // ────────────────────────────────────────────────────────────────────
  //                         EMAIL VALIDATION
  // ────────────────────────────────────────────────────────────────────

  /// Regex مبسّط لصيغة الإيميل — يغطي 99% من الحالات العملية.
  ///
  /// لا نستخدم RFC 5322 الكامل (معقد جداً وبطيء). هذا النمط كافٍ لـ:
  /// - التحقق أن الإيميل فيه @ ومطوّل منطقي
  /// - رفض الإيميلات الواضحة الخطأ (`abc`, `@x`, `x@`)
  ///
  /// الـ backend سيتحقق فعلياً من الإيميل (Phase 3.3).
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// يتحقق من صحة الإيميل.
  ///
  /// يرجع:
  /// - `null` إذا الإيميل صحيح
  /// - رسالة خطأ (من [l10n]) إذا غير صحيح
  static String? email(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return l10n.emailInvalid;
    }
    // حدّ أقصى منطقي (254 من RFC 5321)
    if (trimmed.length > 254) {
      return l10n.emailInvalid;
    }
    return null;
  }

  /// يتحقق من صحة الإيميل بدون i18n — للاستخدام الداخلي (تحديد حالة الزر).
  ///
  /// يرجع `true` إذا الإيميل صحيح.
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();
    return _emailRegex.hasMatch(trimmed) && trimmed.length <= 254;
  }

  // ────────────────────────────────────────────────────────────────────
  //                       PASSWORD VALIDATION
  // ────────────────────────────────────────────────────────────────────

  /// الحد الأدنى لطول كلمة المرور (OWASP recommendation).
  static const int minPasswordLength = 8;

  /// يتحقق من صحة كلمة المرور.
  ///
  /// الشروط:
  /// - 8 أحرف على الأقل
  /// - ليست فارغة
  ///
  /// لا نفرض تعقيد عالي (أحرف كبيرة/رموز) لأنه:
  /// - OWASP الحديث يركّز على الطول، ليس التعقيد
  /// - المستخدمون يكتبون passwords ضعيفة لو أجبرناهم على رموز غريبة
  /// - عندنا 2FA (OTP) في flow الأول — أمان إضافي
  static String? password(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.passwordHint;
    }
    if (value.length < minPasswordLength) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  /// يتحقق من مطابقة كلمتي المرور.
  static String? passwordConfirmation(
    String? confirmation,
    String? original,
    AppLocalizations l10n,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return l10n.passwordHint;
    }
    if (confirmation != original) {
      return l10n.passwordMismatch;
    }
    return null;
  }

  /// يحسب قوة كلمة المرور.
  ///
  /// المعيار:
  /// - طول ≥ 12 + تنوع (أحرف + أرقام + رموز) → strong
  /// - طول ≥ 8 مع عنصر واحد على الأقل من التنوع → medium
  /// - أقل من ذلك → weak
  static PasswordStrength passwordStrength(String password) {
    if (password.length < minPasswordLength) {
      return PasswordStrength.weak;
    }

    // نحسب عدد "العائلات" الموجودة
    final bool hasLower = password.contains(RegExp(r'[a-z]'));
    final bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    final bool hasDigit = password.contains(RegExp(r'[0-9]'));
    final bool hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\]'));

    final int familyCount =
        [hasLower, hasUpper, hasDigit, hasSymbol].where((x) => x).length;

    if (password.length >= 12 && familyCount >= 3) {
      return PasswordStrength.strong;
    }
    if (password.length >= minPasswordLength && familyCount >= 2) {
      return PasswordStrength.medium;
    }
    return PasswordStrength.weak;
  }

  // ────────────────────────────────────────────────────────────────────
  //                         OTP VALIDATION
  // ────────────────────────────────────────────────────────────────────

  /// طول كود OTP القياسي (6 خانات، من الـ API contract).
  static const int otpLength = 6;

  /// يتحقق أن الكود مكوّن من 6 أرقام.
  static bool isValidOtp(String? value) {
    if (value == null) return false;
    if (value.length != otpLength) return false;
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }
}
