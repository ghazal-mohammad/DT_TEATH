// ════════════════════════════════════════════════════════════════════════════
// email_suggestion_engine.dart
//
// منطق اقتراحات نطاقات البريد — مستقلّ عن الواجهة، قابل للاختبار بمعزل.
// نفس المنطق المستخدم سابقاً داخل email_form_field.dart، مستخرَج ليُستخدَم
// من AuthUnderlineField (ولأي حقل بريد مستقبلي) بلا تكرار.
// ════════════════════════════════════════════════════════════════════════════

/// نطاقات النظام الداخلي للموظفين (لا بريد عام مثل gmail — الدخول لموظفي
/// العيادة/المخبر فقط، وبريدهم على نطاق العيادة).
const List<String> kDefaultAuthEmailDomains = ['clinic.com', 'dtteeth.com'];

class EmailSuggestionEngine {
  const EmailSuggestionEngine({this.domains = kDefaultAuthEmailDomains});

  final List<String> domains;

  /// يُرجع قائمة اقتراحات `local@domain` بناءً على النص الحالي.
  List<String> suggestionsFor(String text) {
    if (text.isEmpty) return const [];

    final int atIndex = text.indexOf('@');

    if (atIndex == -1) {
      final String prefix = text.trim();
      if (prefix.isEmpty || !_isValidLocalPart(prefix)) return const [];
      return domains.map((d) => '$prefix@$d').toList();
    }

    final String localPart = text.substring(0, atIndex);
    final String domainPart = text.substring(atIndex + 1).toLowerCase();

    if (localPart.isEmpty) return const [];
    if (domainPart.isEmpty) {
      return domains.map((d) => '$localPart@$d').toList();
    }
    return domains
        .where((d) => d.startsWith(domainPart))
        .map((d) => '$localPart@$d')
        .toList();
  }

  bool _isValidLocalPart(String text) =>
      RegExp(r'^[a-zA-Z0-9._%+-]+$').hasMatch(text);
}
