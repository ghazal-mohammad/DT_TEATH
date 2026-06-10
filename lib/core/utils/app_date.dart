// ════════════════════════════════════════════════════════════════════════════
// app_date.dart
//
// تنسيق التواريخ الموحّد عبر كل الواجهات.
// الباك يرجّع كل التواريخ بصيغة ISO `yyyy-MM-dd` (أو ISO datetime مع وقت).
// نعرضها دائماً بصيغة موحّدة `dd/MM/yyyy`.
// ════════════════════════════════════════════════════════════════════════════

class AppDate {
  AppDate._();

  /// يحوّل تاريخ الباك (yyyy-MM-dd أو yyyy-MM-ddTHH:mm:ss) لصيغة عرض dd/MM/yyyy.
  /// - null/فارغ → [fallback].
  /// - صيغة غير متوقّعة → تُعرض كما هي (بدون كسر).
  static String display(String? iso, {String fallback = '—'}) {
    if (iso == null || iso.trim().isEmpty) return fallback;
    // إزالة جزء الوقت إن وُجد (مسافة أو T).
    final datePart = iso.trim().split(RegExp(r'[ T]')).first;
    final p = datePart.split('-');
    if (p.length != 3 || p[0].length != 4) return iso;
    final y = p[0];
    final m = p[1].padLeft(2, '0');
    final d = p[2].padLeft(2, '0');
    return '$d/$m/$y';
  }

  /// عكس [display]: من `dd/MM/yyyy` (أو dd-MM-yyyy) إلى `yyyy-MM-dd` للإرسال للباك.
  /// يرجّع null لو غير صالح (فلا يُرسل ويتفادى 422).
  static String? toApi(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final parts =
        input.split(RegExp(r'[^0-9]+')).where((e) => e.isNotEmpty).toList();
    if (parts.length != 3) return null;
    String y, m, d;
    if (parts[0].length == 4) {
      y = parts[0];
      m = parts[1];
      d = parts[2];
    } else if (parts[2].length == 4) {
      d = parts[0];
      m = parts[1];
      y = parts[2];
    } else {
      return null;
    }
    final yi = int.tryParse(y), mi = int.tryParse(m), di = int.tryParse(d);
    if (yi == null || mi == null || di == null) return null;
    if (mi < 1 || mi > 12 || di < 1 || di > 31) return null;
    return '$y-${m.padLeft(2, '0')}-${d.padLeft(2, '0')}';
  }
}
