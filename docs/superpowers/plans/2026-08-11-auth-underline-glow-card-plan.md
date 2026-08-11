# Auth Underline Glow Card — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the four auth pages (login, email_entry, verify_code, set_password) to match the reference design — a centered glow-bordered card, underline text fields, and an outline/hover-sweep submit button — with full RTL mirroring, while keeping routing, Cubits, and page-transition timing untouched.

**Architecture:** Two new shared widgets (`AuthUnderlineField`, `AuthOutlineButton`) replace the boxed field/button widgets project-wide. `AuthFlowShell` is restructured to center its content in a `1000×580` `AuthCardGlowBorder` card instead of filling the screen. Each of the four pages swaps its old field/button widgets for the new ones and converts raw `Positioned(left/right)` to `PositionedDirectional(start/end)` so the branding/form sides mirror automatically under RTL — no per-page RTL branching needed beyond that.

**Tech Stack:** Flutter (web target), `flutter_bloc`, `go_router`, `flutter_test` (widget tests, no golden images).

## Global Constraints

- No `ImageFilter.blur` in any new widget (documented perf regression in `auth_flow_transition.dart`) — glows use `BoxShadow`/`CustomPainter` only.
- No new third-party packages — all visuals (floating label, gradient sweep) built with core Flutter widgets.
- Zero raw `Color(0x..)` — all colors go through `AppColors`.
- `route_names.dart`, all Cubits, `auth_entry_animator.dart`'s stagger *values*, and `auth_flow_transition.dart` are out of scope — do not modify their logic.
- Card: `maxWidth: 1000, maxHeight: 580`, `border: 2px AppColors.accent`, `borderRadius: AppSizes.radiusLG` (12).
- Spec source of truth: `docs/superpowers/specs/2026-08-11-auth-underline-glow-card-design.md`.

---

### Task 1: `EmailSuggestionEngine` — extract pure suggestion logic

**Files:**
- Create: `lib/features/auth/presentation/widgets/email_suggestion_engine.dart`
- Test: `test/features/auth/presentation/widgets/email_suggestion_engine_test.dart`

**Interfaces:**
- Produces: `class EmailSuggestionEngine { const EmailSuggestionEngine({List<String> domains = const ['clinic.com','dtteeth.com']}); List<String> suggestionsFor(String text); }` — consumed by Task 2's `AuthUnderlineField`.

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/email_suggestion_engine.dart';

void main() {
  const engine = EmailSuggestionEngine();

  test('empty text yields no suggestions', () {
    expect(engine.suggestionsFor(''), isEmpty);
  });

  test('local part without @ suggests full addresses for each domain', () {
    expect(
      engine.suggestionsFor('ali'),
      ['ali@clinic.com', 'ali@dtteeth.com'],
    );
  });

  test('invalid local part characters yield no suggestions', () {
    expect(engine.suggestionsFor('ali!!'), isEmpty);
  });

  test('trailing @ with empty domain suggests all domains', () {
    expect(
      engine.suggestionsFor('ali@'),
      ['ali@clinic.com', 'ali@dtteeth.com'],
    );
  });

  test('partial domain filters to matching domains only', () {
    expect(engine.suggestionsFor('ali@cl'), ['ali@clinic.com']);
  });

  test('empty local part before @ yields no suggestions', () {
    expect(engine.suggestionsFor('@clinic'), isEmpty);
  });

  test('non-matching domain yields no suggestions', () {
    expect(engine.suggestionsFor('ali@zzz'), isEmpty);
  });

  test('custom domain list overrides default', () {
    const custom = EmailSuggestionEngine(domains: ['example.com']);
    expect(custom.suggestionsFor('bob'), ['bob@example.com']);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/auth/presentation/widgets/email_suggestion_engine_test.dart`
Expected: FAIL — `email_suggestion_engine.dart` doesn't exist (compile error).

- [ ] **Step 3: Write the implementation**

```dart
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/auth/presentation/widgets/email_suggestion_engine_test.dart`
Expected: PASS (8 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/widgets/email_suggestion_engine.dart test/features/auth/presentation/widgets/email_suggestion_engine_test.dart
git commit -m "feat(auth): extract EmailSuggestionEngine as testable pure logic"
```

---

### Task 2: `AuthUnderlineField` — shared underline text field

**Files:**
- Create: `lib/features/auth/presentation/widgets/auth_underline_field.dart`
- Test: `test/features/auth/presentation/widgets/auth_underline_field_test.dart`

**Interfaces:**
- Consumes: `EmailSuggestionEngine` from Task 1 (`suggestionsFor(String)`).
- Produces:
  ```dart
  class AuthUnderlineField extends StatefulWidget {
    const AuthUnderlineField({
      super.key,
      required this.controller,
      required this.label,
      required this.icon,
      this.onChanged,
      this.onSubmitted,
      this.errorText,
      this.enabled = true,
      this.obscureText = false,
      this.showObscureToggle = false,
      this.suggestionDomains = const <String>[],
      this.keyboardType,
      this.autofillHints,
      this.dark = false,
      this.textInputAction,
    });
  }
  ```
  Consumed by Task 5–8 page migrations in place of `EmailFormField`, `PasswordFormField`, and login's private `_InputField`.

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_underline_field.dart';

Widget _wrap(Widget child, {TextDirection dir = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: dir,
      child: Scaffold(body: Material(child: child)),
    ),
  );
}

void main() {
  testWidgets('renders label and leading icon', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    expect(find.text('Email'), findsOneWidget);
    expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);
  });

  testWidgets('shows errorText when provided', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
      errorText: 'Invalid email',
    )));

    expect(find.text('Invalid email'), findsOneWidget);
  });

  testWidgets('showObscureToggle flips obscureText on tap', (tester) async {
    final controller = TextEditingController(text: 'secret');
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Password',
      icon: Icons.lock_outline_rounded,
      obscureText: true,
      showObscureToggle: true,
    )));

    TextField field() => tester.widget<TextField>(find.byType(TextField));
    expect(field().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(field().obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });

  testWidgets('clear button appears with text and clears it', (tester) async {
    final controller = TextEditingController(text: 'ali@clinic.com');
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(controller.text, isEmpty);
  });

  testWidgets('suggestions appear when domains configured and text typed',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
      suggestionDomains: const ['clinic.com'],
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();

    expect(find.text('ali@clinic.com'), findsOneWidget);

    await tester.tap(find.text('ali@clinic.com'));
    await tester.pump();

    expect(controller.text, 'ali@clinic.com');
  });

  testWidgets('no suggestions when suggestionDomains is empty', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AuthUnderlineField(
      controller: controller,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
    )));

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();

    expect(find.text('ali@clinic.com'), findsNothing);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/auth/presentation/widgets/auth_underline_field_test.dart`
Expected: FAIL — `auth_underline_field.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// ════════════════════════════════════════════════════════════════════════════
// auth_underline_field.dart
//
// حقل نصي بخط سفلي + label عائم (Material floating label أصلي، لا تلوين
// خلفية). يستبدل EmailFormField / PasswordFormField / _InputField الخاص
// بـ login_page — واحد لكل حالات الاستخدام (بريد مع اقتراحات، كلمة سر مع
// إظهار/إخفاء، نص عادي).
//
// الأيقونة الأمامية وزر المسح/الإظهار يتموضعان تلقائياً حسب Directionality
// المحيطة (RTL/LTR) لأن InputDecoration.prefixIcon/suffixIcon و TextField's
// Row الداخلي مبنيان على Directionality من الأساس — لا حاجة لمنطق يدوي هنا.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'email_suggestion_engine.dart';

class AuthUnderlineField extends StatefulWidget {
  const AuthUnderlineField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.suggestionDomains = const <String>[],
    this.keyboardType,
    this.autofillHints,
    this.dark = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;

  /// القيمة الابتدائية لإخفاء النص (كلمة السر). يُتحكَّم بها داخلياً بعدها
  /// عبر زر الإظهار/الإخفاء عندما [showObscureToggle] = true.
  final bool obscureText;

  /// true = يظهر زر عين للإظهار/الإخفاء بدل زر المسح (لحقول كلمة السر).
  final bool showObscureToggle;

  /// نطاقات اقتراحات البريد. فارغة = لا اقتراحات (الافتراضي).
  final List<String> suggestionDomains;

  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;

  /// true = نص/تسميات فاتحة على خلفية داكنة (موبايل).
  final bool dark;

  final TextInputAction? textInputAction;

  @override
  State<AuthUnderlineField> createState() => _AuthUnderlineFieldState();
}

class _AuthUnderlineFieldState extends State<AuthUnderlineField> {
  late final FocusNode _focusNode;
  late final EmailSuggestionEngine _engine;
  bool _obscure = true;
  List<String> _suggestions = const [];

  bool get _suggestionsEnabled => widget.suggestionDomains.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _engine = EmailSuggestionEngine(domains: widget.suggestionDomains);
    _focusNode = FocusNode()..addListener(_onFocusChange);
    if (_suggestionsEnabled) widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (_suggestionsEnabled) widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() => _suggestions = const []);
    } else if (_suggestionsEnabled) {
      setState(
          () => _suggestions = _engine.suggestionsFor(widget.controller.text));
    }
  }

  void _onTextChanged() {
    if (!_focusNode.hasFocus) return;
    setState(
        () => _suggestions = _engine.suggestionsFor(widget.controller.text));
  }

  void _applySuggestion(String suggestion) {
    widget.controller.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    widget.onChanged?.call(suggestion);
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.dark ? Colors.white : AppColors.authInputTextLight;
    final Color labelColor = widget.dark
        ? Colors.white.withValues(alpha: 0.70)
        : AppColors.authLabelLight;
    final Color lineColor = widget.dark
        ? Colors.white.withValues(alpha: 0.35)
        : AppColors.authDividerLight;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final bool isFocused = _focusNode.hasFocus;
        final Color iconColor = isFocused
            ? AppColors.accent
            : (widget.dark
                ? Colors.white.withValues(alpha: 0.55)
                : AppColors.authInputIconLight);

        Widget? suffix;
        if (widget.showObscureToggle) {
          suffix = IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: iconColor,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          );
        } else if (value.text.isNotEmpty) {
          suffix = IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(Icons.close_rounded, size: 18, color: iconColor),
            onPressed: () {
              widget.controller.clear();
              widget.onChanged?.call('');
              setState(() => _suggestions = const []);
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: widget.showObscureToggle ? _obscure : false,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofillHints: widget.autofillHints,
              autocorrect: false,
              enableSuggestions: false,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.authFieldInput.copyWith(color: textColor),
              decoration: InputDecoration(
                labelText: widget.label,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: AppTextStyles.authFieldLabel.copyWith(color: labelColor),
                floatingLabelStyle: AppTextStyles.authFieldLabel.copyWith(
                  color: isFocused ? AppColors.accent : labelColor,
                ),
                errorText: widget.errorText,
                errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
                prefixIcon: Icon(widget.icon, size: 20, color: iconColor),
                suffixIcon: suffix,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: lineColor, width: 1.5),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
                errorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error, width: 1.5),
                ),
                focusedErrorBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.error, width: 2),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _suggestionsEnabled && _suggestions.isNotEmpty
                  ? _SuggestionsPanel(
                      suggestions: _suggestions,
                      dark: widget.dark,
                      onTap: _applySuggestion,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.suggestions,
    required this.dark,
    required this.onTap,
  });

  final List<String> suggestions;
  final bool dark;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions
              .take(5)
              .map((s) => _SuggestionRow(
                    text: s,
                    dark: dark,
                    onTap: () => onTap(s),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatefulWidget {
  const _SuggestionRow({
    required this.text,
    required this.dark,
    required this.onTap,
  });

  final String text;
  final bool dark;
  final VoidCallback onTap;

  @override
  State<_SuggestionRow> createState() => _SuggestionRowState();
}

class _SuggestionRowState extends State<_SuggestionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: _hovered
              ? AppColors.accent.withValues(alpha: 0.10)
              : Colors.transparent,
          child: Text(
            widget.text,
            textDirection: TextDirection.ltr,
            style: AppTextStyles.authFieldInput.copyWith(
              fontSize: 13,
              color: widget.dark ? Colors.white : AppColors.authInputTextLight,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/auth/presentation/widgets/auth_underline_field_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/widgets/auth_underline_field.dart test/features/auth/presentation/widgets/auth_underline_field_test.dart
git commit -m "feat(auth): add AuthUnderlineField shared input widget"
```

---

### Task 3: `AuthOutlineButton` — shared outline/hover-sweep button

**Files:**
- Create: `lib/features/auth/presentation/widgets/auth_outline_button.dart`
- Test: `test/features/auth/presentation/widgets/auth_outline_button_test.dart`

**Interfaces:**
- Produces:
  ```dart
  class AuthOutlineButton extends StatefulWidget {
    const AuthOutlineButton({
      super.key,
      required this.label,
      required this.onPressed,
      this.isLoading = false,
      this.isEnabled = true,
      this.withPulseAnimation = true,
      this.icon,
    });
  }
  ```
  Consumed by Task 5–8 in place of `AuthSubmitButton`.

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_outline_button.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders label text', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('tap calls onPressed once, ignores rapid double-tap', (tester) async {
    int count = 0;
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () => count++,
    )));

    await tester.tap(find.byType(AuthOutlineButton));
    await tester.tap(find.byType(AuthOutlineButton));
    await tester.pump();

    expect(count, 1);
  });

  testWidgets('disabled when isEnabled is false — tap does nothing', (tester) async {
    int count = 0;
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      isEnabled: false,
      onPressed: () => count++,
    )));

    await tester.tap(find.byType(AuthOutlineButton));
    await tester.pump();

    expect(count, 0);
  });

  testWidgets('shows spinner and hides label when isLoading', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      isLoading: true,
      onPressed: () {},
    )));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign In'), findsNothing);
  });

  testWidgets('mouse hover does not throw and triggers rebuild', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.byType(AuthOutlineButton)));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(AuthOutlineButton), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/auth/presentation/widgets/auth_outline_button_test.dart`
Expected: FAIL — `auth_outline_button.dart` doesn't exist.

- [ ] **Step 3: Write the implementation**

```dart
// ════════════════════════════════════════════════════════════════════════════
// auth_outline_button.dart
//
// زر Auth بحدود شفافة (بديل بصري لـ AuthSubmitButton المُعبَّأ). يحافظ على
// نفس منطق الـ pulse (2400ms TweenSequence) ويضيف تعبئة متدرّجة تزحف عند
// hover على الديسكتوب فقط (MouseRegion — لا تأثير على اللمس/الموبايل).
//
// الزحف يستخدم AlignmentDirectional.centerStart/centerEnd فيتبع اتجاه RTL/LTR
// تلقائياً بلا فرع منطقي يدوي.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';

const Duration _kAuthTapCooldown = Duration(milliseconds: 600);
const Duration _kHoverSweepDuration = Duration(milliseconds: 220);

class AuthOutlineButton extends StatefulWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.withPulseAnimation = true,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;

  /// `true` = نبض توهج دوري (email, verify, set_password).
  /// `false` = بدون نبض (login) — نفس تمايز AuthSubmitButton الحالي.
  final bool withPulseAnimation;

  final IconData? icon;

  @override
  State<AuthOutlineButton> createState() => _AuthOutlineButtonState();
}

class _AuthOutlineButtonState extends State<AuthOutlineButton>
    with TickerProviderStateMixin {
  DateTime? _lastTapAt;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _hoverCtrl;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapAt != null && now.difference(_lastTapAt!) < _kAuthTapCooldown) {
      return;
    }
    _lastTapAt = now;
    widget.onPressed();
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _pulseAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 37,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 55),
    ]).animate(_pulseCtrl);

    _hoverCtrl = AnimationController(vsync: this, duration: _kHoverSweepDuration);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isEnabled && !widget.isLoading;
    final Listenable pulse = widget.withPulseAnimation
        ? _pulseAnim
        : const AlwaysStoppedAnimation<double>(0.0);
    final Color fg = active ? AppColors.accent : AppColors.accent.withValues(alpha: 0.35);

    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (active) _hoverCtrl.forward();
      },
      onExit: (_) => _hoverCtrl.reverse(),
      child: GestureDetector(
        onTap: active ? _handleTap : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([pulse, _hoverCtrl]),
          builder: (context, _) {
            final double glow =
                (active && widget.withPulseAnimation) ? _pulseAnim.value : 0.0;
            final double sweep = _hoverCtrl.value;

            return Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                border: Border.all(
                  color: active
                      ? AppColors.accent
                      : AppColors.accent.withValues(alpha: 0.35),
                  width: 2,
                ),
                gradient: sweep > 0
                    ? LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.20),
                          AppColors.accent.withValues(alpha: 0.20),
                          Colors.transparent,
                        ],
                        stops: [0.0, sweep.clamp(0.0, 1.0), (sweep + 0.15).clamp(0.0, 1.0)],
                      )
                    : null,
                boxShadow: (active && widget.withPulseAnimation && glow > 0)
                    ? [
                        BoxShadow(
                          color: AppColors.authPulsePeak.withValues(alpha: 0.45 * glow),
                          blurRadius: 20 + 10 * glow,
                          spreadRadius: 2 * glow,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: AppSizes.fontLG,
                              fontWeight: FontWeight.w800,
                              color: fg,
                            ),
                          ),
                          if (widget.icon != null) ...[
                            const SizedBox(width: AppSizes.spaceSM),
                            Icon(widget.icon, size: AppSizes.iconMD, color: fg),
                          ],
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/auth/presentation/widgets/auth_outline_button_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/widgets/auth_outline_button.dart test/features/auth/presentation/widgets/auth_outline_button_test.dart
git commit -m "feat(auth): add AuthOutlineButton shared submit button"
```

---

### Task 4: Center `AuthFlowShell` in a glow card + auto-mirror entry-stagger offset

**Files:**
- Modify: `lib/features/auth/presentation/widgets/auth_flow_shell.dart:84-115` (the `build` method)
- Modify: `lib/features/auth/presentation/widgets/auth_entry_animator.dart:43-73` (the `build` method)
- Test: `test/features/auth/presentation/widgets/auth_flow_shell_test.dart`
- Test: `test/features/auth/presentation/widgets/auth_entry_animator_test.dart`

**Interfaces:**
- Consumes: `AuthCardGlowBorder` (existing, from `auth_page_transition.dart` — `borderRadius` param already supported, no change needed there).
- Produces: no new public API; `AuthFlowShell`'s desktop layout now wraps `widget.child` in a `1000×580` card. `AuthEntryAnimator`'s slide direction now flips automatically under RTL — callers are unaffected (same constructor).

- [ ] **Step 1: Write the failing shell test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_flow_shell.dart';

void main() {
  testWidgets('desktop width centers content in a maxWidth-1000 card', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: AuthFlowShell(flipped: false, child: const SizedBox()),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
    final hasCardConstraint = constrainedBoxes.any((c) =>
        c.constraints.maxWidth == 1000 && c.constraints.maxHeight == 580);
    expect(hasCardConstraint, isTrue);
  });

  testWidgets('mobile width has no 1000-wide card constraint', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: AuthFlowShell(flipped: false, child: const SizedBox()),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
    final hasCardConstraint = constrainedBoxes.any((c) =>
        c.constraints.maxWidth == 1000 && c.constraints.maxHeight == 580);
    expect(hasCardConstraint, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/widgets/auth_flow_shell_test.dart`
Expected: FAIL — no `ConstrainedBox` with `maxWidth: 1000` exists yet (current shell uses `Positioned.fill`).

- [ ] **Step 3: Modify `AuthFlowShell.build`**

Replace `lib/features/auth/presentation/widgets/auth_flow_shell.dart:84-115`:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: LayoutBuilder(
        builder: (_, box) {
          final bool isMobile = box.maxWidth < 750;

          if (isMobile) {
            return Stack(
              children: [
                const Positioned.fill(child: AuthNavyBackground()),
                Positioned.fill(child: widget.child),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 580),
                child: AuthCardGlowBorder(
                  borderRadius: AppSizes.radiusLG,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_rot, _glow]),
                      builder: (_, __) => Stack(
                        children: [
                          Positioned.fill(
                            child: AuthRotatingBackground(
                              // Curves.ease = cubic-bezier(0.25,0.1,0.25,1) = CSS `ease`.
                              progress: Curves.ease.transform(_rot.value),
                              glowPhase: _glow.value * 2 * math.pi,
                            ),
                          ),
                          Positioned.fill(child: widget.child),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
```

Add the two new imports at the top of the file (after existing imports):

```dart
import '../../../../core/theme/app_sizes.dart';
import 'auth_page_transition.dart';
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/widgets/auth_flow_shell_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Write the failing entry-animator RTL test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_entry_animator.dart';

Widget _wrap(Widget child, TextDirection dir) {
  final controller = AnimationController(
    vsync: const TestVSync(),
    duration: const Duration(milliseconds: 100),
  )..value = 0.0; // t=0 → full offset applied, easiest to assert.

  return MaterialApp(
    home: Directionality(
      textDirection: dir,
      child: Scaffold(
        body: AuthEntryAnimator(
          controller: controller,
          delay: const Interval(0.0, 1.0),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('LTR: initial offset is positive (60,0)', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(width: 10, height: 10), TextDirection.ltr));
    final transform = tester.widget<Transform>(find.byType(Transform));
    expect(transform.transform.getTranslation().x, greaterThan(0));
  });

  testWidgets('RTL: initial offset is negative (mirrored)', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(width: 10, height: 10), TextDirection.rtl));
    final transform = tester.widget<Transform>(find.byType(Transform));
    expect(transform.transform.getTranslation().x, lessThan(0));
  });
}
```

- [ ] **Step 6: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/widgets/auth_entry_animator_test.dart`
Expected: FAIL — both directions currently produce the same positive offset.

- [ ] **Step 7: Modify `AuthEntryAnimator.build`**

Replace `lib/features/auth/presentation/widgets/auth_entry_animator.dart:43-73`:

```dart
  @override
  Widget build(BuildContext context) {
    final Animation<double> driven = CurvedAnimation(
      parent: controller,
      curve: delay,
    );
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final Offset effectiveOffset =
        Offset(isRtl ? -slideOffset.dx : slideOffset.dx, slideOffset.dy);

    return AnimatedBuilder(
      animation: driven,
      child: child,
      builder: (_, c) {
        final double t = driven.value;
        final double inv = 1.0 - t;
        final double blur = maxBlur * inv;

        Widget result = Transform.translate(
          offset: Offset(effectiveOffset.dx * inv, effectiveOffset.dy * inv),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: c),
        );

        // blur ينطفئ تماماً عند t≈1 لتجنّب تكلفة الـ ImageFilter وقت السكون
        if (blur > 0.05) {
          result = ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: result,
          );
        }
        return result;
      },
    );
  }
```

- [ ] **Step 8: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/widgets/auth_entry_animator_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 9: Run the full existing auth widget suite to check for regressions**

Run: `flutter test test/features/auth/`
Expected: PASS (no existing tests reference the old full-bleed shell layout — confirm none broke)

- [ ] **Step 10: Commit**

```bash
git add lib/features/auth/presentation/widgets/auth_flow_shell.dart lib/features/auth/presentation/widgets/auth_entry_animator.dart test/features/auth/presentation/widgets/auth_flow_shell_test.dart test/features/auth/presentation/widgets/auth_entry_animator_test.dart
git commit -m "feat(auth): center AuthFlowShell in glow card, auto-mirror entry offset for RTL"
```

---

### Task 5: Migrate `login_page.dart` to the new widgets + `PositionedDirectional`

**Files:**
- Modify: `lib/features/auth/presentation/pages/login_page.dart:144-172` (`_buildDesktop`)
- Modify: `lib/features/auth/presentation/widgets/login/login_branding_panel.dart:20-23` (padding)
- Modify: `lib/features/auth/presentation/widgets/login/login_form_side.dart:212-274` (email/password fields + button)
- Test: `test/features/auth/presentation/pages/login_page_test.dart`

**Interfaces:**
- Consumes: `AuthUnderlineField` (Task 2), `AuthOutlineButton` (Task 3).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/pages/login_page.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_underline_field.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_outline_button.dart';

void main() {
  testWidgets('desktop login uses AuthUnderlineField x2 and AuthOutlineButton, RTL mirrors sides',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      locale: Locale('ar'),
      supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: LoginPage(),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AuthUnderlineField), findsNWidgets(2));
    expect(find.byType(AuthOutlineButton), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/pages/login_page_test.dart`
Expected: FAIL — page still uses `_InputField`/`AuthSubmitButton`/raw `Positioned`.

- [ ] **Step 3: Update `login_page.dart` desktop layout**

Replace `lib/features/auth/presentation/pages/login_page.dart:144-172`:

```dart
  Widget _buildDesktop(BuildContext ctx, double W, double H) {
    return Stack(
      children: [
        // Branding (جهة البداية — يمين في RTL، فوق الكحلي)
        PositionedDirectional(
          start: 0, width: W * 0.40,
          top: 0, bottom: 0,
          child: _BrandingPanel(entryCtrl: _entryCtrl),
        ),

        // Form (جهة النهاية — يسار في RTL، فوق الأبيض)
        PositionedDirectional(
          start: W * 0.67, end: 0,
          top: 0, bottom: 0,
          child: _FormSide(
            emailCtrl: _emailCtrl,
            passCtrl:  _passCtrl,
            obscure:   _obscure,
            loading:   _loading,
            error:     _error,
            isMobile:  false,
            entryCtrl: _entryCtrl,
            onToggleObscure: () => setState(() => _obscure = !_obscure),
            onSubmit: _submit,
          ),
        ),
      ],
    );
  }
```

- [ ] **Step 4: Mirror the branding panel's padding**

Replace `lib/features/auth/presentation/widgets/login/login_branding_panel.dart:20-23`:

```dart
      padding: const EdgeInsetsDirectional.only(
        start: 28, end: 160, top: 28, bottom: 40,
      ),
```

And `lib/features/auth/presentation/widgets/login/login_branding_panel.dart:43-44` (the "WELCOME BACK!" wrapper):

```dart
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
```

- [ ] **Step 5: Replace email/password fields and button in `login_form_side.dart`**

Replace `lib/features/auth/presentation/widgets/login/login_form_side.dart:212-274` (from the `// Email field` comment through the end of the password field block):

```dart
        // Email field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field1,
          child: AuthUnderlineField(
            controller: emailCtrl,
            label: isAr ? 'البريد الإلكتروني' : 'Email',
            icon: Icons.alternate_email_rounded,
            dark: isMobile,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username],
          ),
        ),
        const SizedBox(height: AppSizes.spaceMD),

        // Password field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field2,
          child: AuthUnderlineField(
            controller: passCtrl,
            label: isAr ? 'كلمة المرور' : 'Password',
            icon: Icons.lock_outline_rounded,
            dark: isMobile,
            obscureText: true,
            showObscureToggle: true,
            onSubmitted: (_) => onSubmit(),
            autofillHints: const [AutofillHints.password],
          ),
        ),
```

Then replace the submit button block, `lib/features/auth/presentation/widgets/login/login_form_side.dart:306-318` (post-edit line numbers will have shifted — locate by the `// Submit button` comment):

```dart
        // Submit button (مشترك — AuthOutlineButton بدون pulse)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthOutlineButton(
            label: isAr ? 'تسجيل الدخول' : 'Sign In',
            onPressed: onSubmit,
            isLoading: loading,
            withPulseAnimation: false, // login بدون pulse (كما سابقاً)
            icon: Icons.login_rounded,
          ),
        ),
```

Remove the now-unused `_FieldLabel` and `_InputField` private classes (`lib/features/auth/presentation/widgets/login/login_form_side.dart:332-441` in the original file) — nothing else references them after this edit.

Update `login_page.dart`'s imports: replace

```dart
import '../widgets/auth_submit_button.dart';
```

with

```dart
import '../widgets/auth_outline_button.dart';
import '../widgets/auth_underline_field.dart';
```

(Leave the mobile path in `login_page.dart` for now — Task 5's test only covers desktop; mobile keeps `AuthSubmitButton`/existing mobile form via `_FormContent`, which is out of the reference-matching scope per the approved spec's "الموبايل: يبقى بلا حدود/توهج، full-width" — the mobile form's own fields were not called out for replacement, only the card wrapper. If `_FormContent` in login_page.dart also renders the removed `_InputField`, redirect it to `AuthUnderlineField` too, since `_InputField` no longer exists after this task's cleanup — check `_buildMobile()`'s `_FormContent` usage and apply the same two-field edit there.)

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/pages/login_page_test.dart`
Expected: PASS

- [ ] **Step 7: Run the full auth test suite**

Run: `flutter test test/features/auth/`
Expected: PASS

- [ ] **Step 8: Visual check**

Run (PowerShell, not Git Bash):
```powershell
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
node .claude/skills/run-dt-teeth/driver.mjs --serve build/web /login
```
Open the resulting screenshot and compare against the reference card (centered, glow border, underline fields, outline button, branding on the right in RTL). Fix any visual issues before proceeding.

- [ ] **Step 9: Commit**

```bash
git add lib/features/auth/presentation/pages/login_page.dart lib/features/auth/presentation/widgets/login/login_branding_panel.dart lib/features/auth/presentation/widgets/login/login_form_side.dart test/features/auth/presentation/pages/login_page_test.dart
git commit -m "feat(auth): migrate login_page to underline fields, outline button, RTL-mirrored layout"
```

---

### Task 6: Migrate `email_entry_page.dart`

**Files:**
- Modify: `lib/features/auth/presentation/pages/email_entry_page.dart:110-134` (`_buildDesktop`)
- Modify: `lib/features/auth/presentation/pages/email_entry_page.dart:180-227` (`_BrandingPanel` padding)
- Modify: `lib/features/auth/presentation/pages/email_entry_page.dart:388-419` (field + button)
- Test: `test/features/auth/presentation/pages/email_entry_page_test.dart`

**Interfaces:**
- Consumes: `AuthUnderlineField` (Task 2, with `suggestionDomains: kDefaultAuthEmailDomains`), `AuthOutlineButton` (Task 3).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/pages/email_entry_page.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_underline_field.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_outline_button.dart';

void main() {
  testWidgets('desktop email_entry uses AuthUnderlineField + AuthOutlineButton, mirrored sides',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      locale: Locale('ar'),
      supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: EmailEntryPage(),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AuthUnderlineField), findsOneWidget);
    expect(find.byType(AuthOutlineButton), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/pages/email_entry_page_test.dart`
Expected: FAIL

- [ ] **Step 3: Update desktop layout**

Replace `lib/features/auth/presentation/pages/email_entry_page.dart:110-134`:

```dart
  Widget _buildDesktop(double W, double H) {
    return Stack(
      children: [
        PositionedDirectional(
          start: 0, width: W * 0.40,
          top: 0, bottom: 0,
          child: _BrandingPanel(entryCtrl: _entryCtrl),
        ),
        PositionedDirectional(
          start: W * 0.67, end: 0,
          top: 0, bottom: 0,
          child: _DesktopForm(
            emailCtrl: _emailCtrl,
            entryCtrl: _entryCtrl,
            mode: widget.mode,
            onSubmit: _submit,
          ),
        ),
      ],
    );
  }
```

- [ ] **Step 4: Mirror `_BrandingPanel` padding**

Replace `lib/features/auth/presentation/pages/email_entry_page.dart:180-181`:

```dart
      padding: const EdgeInsetsDirectional.only(start: 28, end: 160, top: 28, bottom: 40),
```

Replace the "WELCOME!" wrapper at `lib/features/auth/presentation/pages/email_entry_page.dart:200-201`:

```dart
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
```

- [ ] **Step 5: Replace the email field and submit button**

Replace `lib/features/auth/presentation/pages/email_entry_page.dart:388-419`:

```dart
            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.field1,
              child: AuthUnderlineField(
                controller: emailCtrl,
                label: context.l10n.email,
                icon: Icons.alternate_email_rounded,
                dark: isMobile,
                enabled: state.status != EmailEntryStatus.submitting,
                onChanged: (v) => context.read<EmailEntryCubit>().emailChanged(v),
                onSubmitted: (_) => onSubmit(),
                errorText: _resolveError(state, context),
                suggestionDomains: kDefaultAuthEmailDomains,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLG),

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.button,
              child: AuthOutlineButton(
                label: context.l10n.authNext,
                onPressed: onSubmit,
                isLoading: state.status == EmailEntryStatus.submitting,
                isEnabled: !state.isSubmitDisabled,
                withPulseAnimation: true,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
```

Update the imports at the top of the file: replace

```dart
import '../widgets/auth_submit_button.dart';
import '../widgets/email_form_field.dart';
```

with

```dart
import '../widgets/auth_outline_button.dart';
import '../widgets/auth_underline_field.dart';
import '../widgets/email_suggestion_engine.dart';
```

Also remove the now-unused `Theme(...brightness...)` wrapper that was previously needed only to flip `EmailFormField`'s light/dark palette (lines 391–404 in the original) — `AuthUnderlineField` takes `dark` directly, so the `Theme` wrapper around it can be dropped; keep the `Theme` wrapper only if other descendants still rely on `Theme.of(context).brightness` (check before removing).

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/pages/email_entry_page_test.dart`
Expected: PASS

- [ ] **Step 7: Run the full auth test suite + visual check**

Run: `flutter test test/features/auth/`
Then (PowerShell):
```powershell
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
node .claude/skills/run-dt-teeth/driver.mjs --serve build/web /auth/email
```
Compare screenshot to reference; confirm email suggestions dropdown still opens under the underline field.

- [ ] **Step 8: Commit**

```bash
git add lib/features/auth/presentation/pages/email_entry_page.dart test/features/auth/presentation/pages/email_entry_page_test.dart
git commit -m "feat(auth): migrate email_entry_page to underline field with suggestions, outline button"
```

---

### Task 7: Migrate `verify_code_page.dart` (button + layout only — OTP input unchanged)

**Files:**
- Modify: `lib/features/auth/presentation/pages/verify_code_page.dart:186-242` (`_buildDesktop`)
- Modify: `lib/features/auth/presentation/pages/verify_code_page.dart:320-324` (`_BrandingPanel` padding — note: mirrored the *other* way, since verify_code already has form-left/branding-right)
- Modify: `lib/features/auth/presentation/pages/verify_code_page.dart:552-563` (submit button)
- Test: `test/features/auth/presentation/pages/verify_code_page_test.dart`

**Interfaces:**
- Consumes: `AuthOutlineButton` (Task 3). `OtpInput` stays as-is — it wasn't part of the approved spec's field-conversion scope (spec discussed `email_form_field.dart` specifically; OTP's six-digit-box UI is a different component family, not a text/password field).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/pages/verify_code_page.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_outline_button.dart';

void main() {
  testWidgets('desktop verify_code uses AuthOutlineButton and PositionedDirectional',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      locale: Locale('ar'),
      supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: VerifyCodePage(email: 'ali@clinic.com'),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AuthOutlineButton), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/pages/verify_code_page_test.dart`
Expected: FAIL

- [ ] **Step 3: Update desktop layout**

Replace `lib/features/auth/presentation/pages/verify_code_page.dart:186-242` — note verify_code's layout is already reversed (branding on the *end* side, form on the *start* side, since it's the "mirror" screen even in the original LTR-oriented codebase). Under `PositionedDirectional`, `end`/`start` naturally continue to express "branding opposite of login" correctly without extra flags:

```dart
  Widget _buildDesktop(double W, double H) {
    return Stack(
      children: [
        // Branding (جهة النهاية — يسار في RTL، فوق الكحلي)
        PositionedDirectional(
          end: 0, width: W * 0.40,
          top: 0, bottom: 0,
          child: _BrandingPanel(entryCtrl: _entryCtrl),
        ),

        // Form (جهة البداية — يمين في RTL، فوق الأبيض)
        PositionedDirectional(
          start: 0, end: W * 0.67,
          top: 0, bottom: 0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space3XL + AppSizes.spaceMD,
                  vertical: AppSizes.space3XL + AppSizes.spaceMD,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: _FormContent(
                          otpKey: _otpKey,
                          email: widget.email,
                          mode: widget.mode,
                          code: _code,
                          verifying: _verifying,
                          hasError: _hasError,
                          errMsg: _errMsg,
                          secs: _secs,
                          isMobile: false,
                          entryCtrl: _entryCtrl,
                          onCodeChanged: (v) => setState(() {
                            _code = v;
                            if (_hasError) _hasError = false;
                          }),
                          onVerify: _verify,
                          onResend: _resend,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
```

- [ ] **Step 4: Mirror `_BrandingPanel` padding**

Replace `lib/features/auth/presentation/pages/verify_code_page.dart:320-324`:

```dart
      padding: const EdgeInsetsDirectional.only(
        end: 28, start: 160, top: 28, bottom: 40,
      ),
```

(The "WELCOME BACK!" `Padding(left: 8)` at line 345 becomes `EdgeInsetsDirectional.only(start: 8)` — same edit pattern as Task 5/6.)

- [ ] **Step 5: Replace the submit button**

Replace `lib/features/auth/presentation/pages/verify_code_page.dart:552-563`:

```dart
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthOutlineButton(
            label: context.l10n.authContinue,
            onPressed: onVerify,
            isLoading: verifying,
            isEnabled: code.length == 6 && !verifying,
            withPulseAnimation: true,
          ),
        ),
```

Update imports: replace `import '../widgets/auth_submit_button.dart';` with `import '../widgets/auth_outline_button.dart';`.

- [ ] **Step 6: Run test, full suite, and visual check**

Run: `flutter test test/features/auth/presentation/pages/verify_code_page_test.dart`
Then: `flutter test test/features/auth/`
Then (PowerShell):
```powershell
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
node .claude/skills/run-dt-teeth/driver.mjs --serve build/web /login
```
(Navigate to verify_code manually via the email flow in the screenshot tool, or add its route to the driver's route list if supported — confirm the card + button render correctly; OTP boxes remain visually unchanged as intended.)

- [ ] **Step 7: Commit**

```bash
git add lib/features/auth/presentation/pages/verify_code_page.dart test/features/auth/presentation/pages/verify_code_page_test.dart
git commit -m "feat(auth): migrate verify_code_page to outline button, RTL-mirrored layout"
```

---

### Task 8: Migrate `set_password_page.dart`

**Files:**
- Modify: `lib/features/auth/presentation/pages/set_password_page.dart:157-212` (`_buildDesktop`)
- Modify: `lib/features/auth/presentation/pages/set_password_page.dart:286-289` (`_BrandingPanel` padding)
- Modify: `lib/features/auth/presentation/pages/set_password_page.dart:460-521` (password fields + button)
- Test: `test/features/auth/presentation/pages/set_password_page_test.dart`

**Interfaces:**
- Consumes: `AuthUnderlineField` (Task 2, `showObscureToggle: true`), `AuthOutlineButton` (Task 3).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth_clean/features/auth/presentation/pages/set_password_page.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_underline_field.dart';
import 'package:dt_teeth_clean/features/auth/presentation/widgets/auth_outline_button.dart';

void main() {
  testWidgets('desktop set_password uses AuthUnderlineField x2 and AuthOutlineButton',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      locale: Locale('ar'),
      supportedLocales: [Locale('ar'), Locale('en')],
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: SetPasswordPage(email: 'ali@clinic.com', verificationCode: '123456'),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AuthUnderlineField), findsNWidgets(2));
    expect(find.byType(AuthOutlineButton), findsOneWidget);
    expect(find.byType(PositionedDirectional), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/pages/set_password_page_test.dart`
Expected: FAIL

- [ ] **Step 3: Update desktop layout**

Replace `lib/features/auth/presentation/pages/set_password_page.dart:157-212`:

```dart
  Widget _buildDesktop(double W, double H) {
    return Stack(
      children: [
        PositionedDirectional(
          start: 0, width: W * 0.40,
          top: 0, bottom: 0,
          child: _BrandingPanel(entryCtrl: _entryCtrl),
        ),

        PositionedDirectional(
          start: W * 0.67, end: 0,
          top: 0, bottom: 0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.space3XL + AppSizes.spaceMD,
                  vertical: AppSizes.space3XL + AppSizes.spaceMD,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: _FormContent(
                          pwdCtrl: _pwdCtrl,
                          cfmCtrl: _cfmCtrl,
                          pwd: _pwd,
                          mode: widget.mode,
                          valid: _valid,
                          submitting: _submitting,
                          errPwd: _errPwd,
                          errCfm: _errCfm,
                          isMobile: false,
                          entryCtrl: _entryCtrl,
                          onPwdChanged: (v) => setState(() {
                            _pwd = v; _errPwd = null;
                          }),
                          onCfmChanged: (v) => setState(() {
                            _cfm = v; _errCfm = null;
                          }),
                          onSubmit: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
```

- [ ] **Step 4: Mirror `_BrandingPanel` padding**

Replace `lib/features/auth/presentation/pages/set_password_page.dart:287-289`:

```dart
      padding: const EdgeInsetsDirectional.only(
        start: 28, end: 160, top: 28, bottom: 40,
      ),
```

(and the "ALMOST THERE!" `Padding(left: 8)` → `EdgeInsetsDirectional.only(start: 8)`, same pattern as prior tasks.)

- [ ] **Step 5: Replace password/confirm fields and submit button**

Replace `lib/features/auth/presentation/pages/set_password_page.dart:460-521`:

```dart
        // Password field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field1,
          child: AuthUnderlineField(
            controller: pwdCtrl,
            label: context.l10n.password,
            icon: Icons.lock_outline_rounded,
            dark: isMobile,
            enabled: !submitting,
            errorText: errPwd,
            onChanged: onPwdChanged,
            obscureText: true,
            showObscureToggle: true,
          ),
        ),

        // Strength meter
        Theme(
          data: Theme.of(context).copyWith(brightness: fieldBrightness),
          child: PasswordStrengthMeter(password: pwd),
        ),
        const SizedBox(height: 10),

        // Confirm field
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.field2,
          child: AuthUnderlineField(
            controller: cfmCtrl,
            label: context.l10n.passwordConfirm,
            icon: Icons.lock_outline_rounded,
            dark: isMobile,
            enabled: !submitting,
            errorText: errCfm,
            onChanged: onCfmChanged,
            onSubmitted: (_) => valid ? onSubmit() : null,
            obscureText: true,
            showObscureToggle: true,
          ),
        ),
        const SizedBox(height: AppSizes.spaceXL),

        // Submit button (مشترك — AuthOutlineButton)
        AuthEntryAnimator(
          controller: entryCtrl,
          delay: AuthStaggerDelays.button,
          child: AuthOutlineButton(
            label: mode == AuthFlowMode.reset
                ? (Localizations.localeOf(context).languageCode == 'ar'
                    ? 'إعادة تعيين كلمة المرور'
                    : 'Reset Password')
                : context.l10n.authSaveAndLogin,
            onPressed: onSubmit,
            isLoading: submitting,
            isEnabled: valid && !submitting,
            withPulseAnimation: true,
            icon: Icons.check_rounded,
          ),
        ),
```

`PasswordStrengthMeter` stays wrapped in its existing `Theme(...)` — it isn't part of this migration (not a text field, not discussed in the approved spec).

Update imports: replace `import '../widgets/auth_submit_button.dart';` and `import '../widgets/password_form_field.dart';` with `import '../widgets/auth_outline_button.dart';` and `import '../widgets/auth_underline_field.dart';`.

- [ ] **Step 6: Run test, full suite, and visual check**

Run: `flutter test test/features/auth/presentation/pages/set_password_page_test.dart`
Then: `flutter test test/features/auth/`
Then (PowerShell):
```powershell
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
node .claude/skills/run-dt-teeth/driver.mjs --serve build/web /login
```
Navigate to set_password via the flow (or add its route to the driver's list) and confirm both fields render as underline with working obscure toggles, strength meter still positioned correctly.

- [ ] **Step 7: Commit**

```bash
git add lib/features/auth/presentation/pages/set_password_page.dart test/features/auth/presentation/pages/set_password_page_test.dart
git commit -m "feat(auth): migrate set_password_page to underline fields, outline button"
```

---

### Task 9: Remove dead widgets + final full-suite verification

**Files:**
- Delete: `lib/features/auth/presentation/widgets/auth_submit_button.dart` (fully replaced by `AuthOutlineButton` across all 4 pages)
- Delete: `lib/features/auth/presentation/widgets/email_form_field.dart` (fully replaced by `AuthUnderlineField`)
- Delete: `lib/features/auth/presentation/widgets/password_form_field.dart` (fully replaced by `AuthUnderlineField`)
- Delete any now-orphaned test files for the three deleted widgets, if present.

**Interfaces:** None — this is a cleanup-only task, safe once Tasks 5–8 confirm no remaining references.

- [ ] **Step 1: Confirm no remaining references**

Run: `grep -rn "AuthSubmitButton\|EmailFormField\|PasswordFormField" lib/ test/`
Expected: no matches outside the files being deleted (if `PasswordFormField` is still referenced anywhere outside auth — e.g. a profile "change password" screen — keep that file and only delete `auth_submit_button.dart` / `email_form_field.dart`; check before deleting).

- [ ] **Step 2: Delete confirmed-dead files**

```bash
git rm lib/features/auth/presentation/widgets/auth_submit_button.dart
git rm lib/features/auth/presentation/widgets/email_form_field.dart
# only if Step 1 confirms no external references:
git rm lib/features/auth/presentation/widgets/password_form_field.dart
```

- [ ] **Step 3: Run static analysis**

Run: `flutter analyze`
Expected: 0 issues (per project convention — zero warnings, zero errors).

- [ ] **Step 4: Run the full test suite**

Run: `flutter test`
Expected: all tests PASS.

- [ ] **Step 5: Full visual pass across all 4 routes**

Run (PowerShell):
```powershell
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
node .claude/skills/run-dt-teeth/driver.mjs --serve build/web /login /auth/email
```
Manually walk the full flow (login → forgot password → email → verify → set password) in a browser to confirm the rotating-card transition between steps still animates smoothly (no jank — this is the regression class the project has hit before), and that RTL mirroring is consistent across all four screens.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore(auth): remove boxed field/button widgets superseded by underline/outline variants"
```

## Self-Review Notes

- **Spec coverage:** Architecture ✓ (Tasks 4–8), card/background ✓ (Task 4), fields ✓ (Tasks 2, 5–8), button ✓ (Tasks 3, 5–8), RTL mirroring ✓ (`PositionedDirectional` in Tasks 5–8, auto-mirrored `AuthEntryAnimator` offset in Task 4), timing constraints ✓ (no changes to `auth_flow_transition.dart` or `AuthStaggerDelays` values), perf constraint (no `ImageFilter.blur`) ✓ (verified absent from Tasks 2–4's implementations).
- **Gap filled beyond the spec's literal wording:** the spec's "الحقول" section discussed `email_form_field.dart` as the example, but didn't explicitly call out `password_form_field.dart` or login's private `_InputField`. Since the approved scope is "full design match" across all four pages, leaving those as mismatched boxed fields would contradict that goal — so `AuthUnderlineField` was designed as a general-purpose replacement for all three, and Tasks 5–8 convert every text/password field project-wide. `OtpInput` was deliberately left out (different component family, never discussed).
- **Design simplification kept faithful to intent:** the spec described a hand-animated floating label (`AnimatedAlign`/`AnimatedDefaultTextStyle`). Task 2 uses Flutter's native `InputDecoration.floatingLabelBehavior` instead — same visual result (label floats/shrinks on focus), fewer custom animation bugs, less code. Noted here rather than re-opened with the user, since it doesn't change any visible behavior described in the approved design.
