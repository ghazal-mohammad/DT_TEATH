# Auth Navy Palette + Button Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the turquoise/cyan accent used on all five auth screens with the navy/purple palette from the current React reference, redesign `AuthOutlineButton` to a pill shape with a bottom-to-top hover fill, and remove one duplicated line of copy under the email-entry button.

**Architecture:** Three independent, additive changes: (1) swap 3 color constants + add 1 new constant in the single shared `AppColors` auth section — this cascades automatically to every auth screen because they all consume `AuthFlowShell`/`AuthCardGlowBorder`/`AuthOutlineButton`/`AuthUnderlineField`, none of which hardcode colors; (2) rebuild `AuthOutlineButton`'s internal `Stack` so the hover fill is a clipped, bottom-anchored `FractionallySizedBox` instead of a horizontal alpha-tinted gradient; (3) delete one `Row` (icon + duplicate subtitle text) from `email_entry_page.dart`. No new dependencies, no routing changes, no backend calls.

**Tech Stack:** Flutter/Dart, flutter_test + mocktail (existing project conventions), no new packages.

## Global Constraints

- Every color constant referenced by auth widgets lives in `lib/core/theme/app_colors.dart` — no new hardcoded hex literals inside `lib/features/auth/**` (matches the project's single-source-of-color rule; see `docs/AUDIT_2026-08-11.md` C1).
- Hover-driven behavior must only ever be reachable via `MouseRegion.onEnter`, which already gates on `active` — no behavior change for touch/mobile.
- Do not touch `authFooterNote` usages in `verify_code_page.dart`, `set_password_page.dart`, `system_selection_page.dart`, or `login_form_side.dart` — those show functional content (errors, password hints, preview notes), not the duplicated copy this plan removes.
- Do not touch `AuthNavyBackground` / `authNavyGradientColors` — out of scope per spec.
- `flutter analyze` must stay at zero issues and `flutter test` must stay fully green after every task.

---

### Task 1: Swap the auth accent palette to navy/purple

**Files:**
- Modify: `lib/core/theme/app_colors.dart:382,386,415`
- Test: Create `test/core/theme/app_colors_auth_palette_test.dart`

**Interfaces:**
- Consumes: nothing (this is the base layer).
- Produces: `AppColors.authBorderBlue`, `AppColors.authGlowBlue`, `AppColors.authPulsePeak` (existing names, new values), and a new constant `AppColors.authHoverFillStart` (`Color`) — Task 2 consumes `authHoverFillStart` and `authGlowBlue` for the button's hover-fill gradient.

- [ ] **Step 1: Write the failing test**

Create `test/core/theme/app_colors_auth_palette_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_colors_auth_palette_test.dart`
Expected: FAIL — `authBorderBlue` is `#05B4D7` not `#141455` (and `authHoverFillStart` doesn't exist, causing a compile error until Step 3).

- [ ] **Step 3: Update the color constants**

In `lib/core/theme/app_colors.dart`, replace:

```dart
  /// أزرق فاتح مطابق لحدّ الكارت بالمرجع (React: `border-[#05B4D7]`) —
  /// للخطوط الصلبة (حدّ الكارت، حدّ الحقل عند التركيز، حدّ/نص الزر، الأيقونة).
  /// خاصّ بشاشات auth (login/email/verify/setPassword) — لا يُستخدم عالمياً
  /// مثل AppColors.accent، فتغييره لا يمسّ بقية التطبيق.
  static const Color authBorderBlue = Color(0xFF05B4D7);

  /// أزرق فاتح أسطع مطابق لتوهّج الكارت بالمرجع (React: `shadow-[0_0_25px_#4DE1FF]`) —
  /// للتأثيرات الضبابية فقط (BoxShadow، خط التوهج، تدرّج hover). خاصّ بـ auth.
  static const Color authGlowBlue = Color(0xFF4DE1FF);
```

with:

```dart
  /// كحلي مطابق لحدّ الكارت/الزر بمرجع React الحالي (`border-[#141455]`) —
  /// للخطوط الصلبة (حدّ الكارت، حدّ الحقل عند التركيز، حدّ/نص الزر، الأيقونة).
  /// خاصّ بشاشات auth (login/email/verify/setPassword) — لا يُستخدم عالمياً
  /// مثل AppColors.accent، فتغييره لا يمسّ بقية التطبيق.
  static const Color authBorderBlue = Color(0xFF141455);

  /// بنفسجي-أزرق مطابق لتوهّج الكارت وتدرّج تعبئة الزر بمرجع React الحالي
  /// (`linear-gradient(#1a1a2e,#5959B3,...)`) — للتأثيرات الضبابية (BoxShadow،
  /// خط التوهج) ولطرف تدرّج تعبئة الـ hover. خاصّ بـ auth.
  static const Color authGlowBlue = Color(0xFF5959B3);

  /// طرف البداية (الأسفل) لتدرّج تعبئة الزر عند hover — مطابق لأول قيمة
  /// بتدرّج المرجع (`linear-gradient(#1a1a2e, #5959B3, ...)`). خاصّ بـ auth.
  static const Color authHoverFillStart = Color(0xFF1A1A2E);
```

And replace:

```dart
  static const Color authPulsePeak = Color(0xFF1C6377); // teal عميق
```

with:

```dart
  static const Color authPulsePeak = Color(0xFF5959B3); // موحَّد مع authGlowBlue الجديد
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/theme/app_colors_auth_palette_test.dart`
Expected: PASS

- [ ] **Step 5: Run the existing symbolic-reference test to confirm no regression**

Run: `flutter test test/features/auth/presentation/widgets/auth_underline_field_test.dart`
Expected: PASS unchanged — that test compares against `AppColors.authBorderBlue` by reference, not by hex value, so it is unaffected by the swap.

- [ ] **Step 6: Commit**

```bash
git add lib/core/theme/app_colors.dart test/core/theme/app_colors_auth_palette_test.dart
git commit -m "fix(auth): replace turquoise accent palette with navy/purple reference colors"
```

---

### Task 2: Redesign AuthOutlineButton — pill shape + bottom-to-top hover fill

**Files:**
- Modify: `lib/features/auth/presentation/widgets/auth_outline_button.dart`
- Test: Modify `test/features/auth/presentation/widgets/auth_outline_button_test.dart`

**Interfaces:**
- Consumes: `AppColors.authBorderBlue`, `AppColors.authGlowBlue`, `AppColors.authHoverFillStart`, `AppColors.authPulsePeak` (from Task 1).
- Produces: `AuthOutlineButton` keeps its existing public API (`label`, `onPressed`, `isLoading`, `isEnabled`, `withPulseAnimation`, `icon`) unchanged — Task 3 and every existing call site (`login_page.dart`, `email_entry_page.dart`, `verify_code_page.dart`, `set_password_page.dart`) need no changes.

- [ ] **Step 1: Write the failing tests**

Add to the top of `test/features/auth/presentation/widgets/auth_outline_button_test.dart` (after the existing imports):

```dart
import 'package:dt_teeth/core/theme/app_colors.dart';
```

Then add these test cases inside `void main() { ... }`, after the existing tests:

```dart
  testWidgets('button shape is a full pill (borderRadius = height / 2)',
      (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final bordered = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere((c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border != null);
    final decoration = bordered.decoration! as BoxDecoration;

    expect(decoration.borderRadius, BorderRadius.circular(25));
  });

  testWidgets('idle button has no hover fill overlay', (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    expect(find.byType(FractionallySizedBox), findsNothing);
  });

  testWidgets(
      'hover reveals a vertical bottom-anchored fill that grows to full height',
      (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.byType(AuthOutlineButton)));
    await tester.pump(const Duration(milliseconds: 110)); // mid-sweep (220ms total)

    final midFill =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(midFill.heightFactor, greaterThan(0.0));
    expect(midFill.heightFactor, lessThan(1.0));
    expect(midFill.alignment, Alignment.bottomCenter);

    await tester.pump(const Duration(milliseconds: 200)); // finish sweep

    final fullFill =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(fullFill.heightFactor, closeTo(1.0, 0.01));
  });

  testWidgets('label color shifts from navy to white as the fill grows',
      (tester) async {
    await tester.pumpWidget(_wrap(AuthOutlineButton(
      label: 'Sign In',
      onPressed: () {},
    )));

    final idleColor = tester.widget<Text>(find.text('Sign In')).style!.color;
    expect(idleColor, AppColors.authBorderBlue);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byType(AuthOutlineButton)));
    await tester.pump(const Duration(milliseconds: 220)); // full sweep

    final hoveredColor =
        tester.widget<Text>(find.text('Sign In')).style!.color;
    expect(hoveredColor, Colors.white);
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/features/auth/presentation/widgets/auth_outline_button_test.dart`
Expected: FAIL — current implementation has no `FractionallySizedBox`, uses `AppSizes.radiusLG` (12.0) instead of a pill radius, and never lerps the label color.

- [ ] **Step 3: Rewrite the button's build method**

Replace the entire `build` method body in `lib/features/auth/presentation/widgets/auth_outline_button.dart` (currently lines 98–217, from `Widget build(BuildContext context) {` through its closing `}`) with:

```dart
  @override
  Widget build(BuildContext context) {
    final bool active = widget.isEnabled && !widget.isLoading;
    final Listenable pulse = widget.withPulseAnimation
        ? _pulseAnim
        : const AlwaysStoppedAnimation<double>(0.0);

    return Semantics(
      button: true,
      enabled: active,
      label: widget.label,
      child: Focus(
        canRequestFocus: active,
        onKeyEvent: (node, event) {
          if (active &&
              event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            _handleTap();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
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
                final double glow = (active && widget.withPulseAnimation)
                    ? _pulseAnim.value
                    : 0.0;
                final double sweep = _hoverCtrl.value.clamp(0.0, 1.0);
                final Color borderColor = active
                    ? AppColors.authBorderBlue
                    : AppColors.authBorderBlue.withValues(alpha: 0.35);
                final Color fg = active
                    ? Color.lerp(AppColors.authBorderBlue, Colors.white, sweep)!
                    : AppColors.authBorderBlue.withValues(alpha: 0.35);

                final Widget content = Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: fg,
                          ),
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
                              Icon(
                                widget.icon,
                                size: AppSizes.iconMD,
                                color: fg,
                              ),
                            ],
                          ],
                        ),
                );

                return SizedBox(
                  height: _kButtonHeight,
                  child: Stack(
                    children: [
                      // طبقة التعبئة — مقصوصة بشكل الحبة (pill)، تنمو من
                      // الأسفل للأعلى مع تقدّم hover. خلف الحدّ/المحتوى فلا
                      // تُغطّي عليهما.
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(_kButtonHeight / 2),
                        child: SizedBox(
                          height: _kButtonHeight,
                          width: double.infinity,
                          child: sweep > 0
                              ? FractionallySizedBox(
                                  heightFactor: sweep,
                                  alignment: Alignment.bottomCenter,
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          AppColors.authHoverFillStart,
                                          AppColors.authGlowBlue,
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      // الحدّ + التوهّج + المحتوى — طبقة غير مقصوصة (عشان
                      // BoxShadow ما ينقصّ) وفوق طبقة التعبئة.
                      Container(
                        height: _kButtonHeight,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(_kButtonHeight / 2),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow:
                              (active && widget.withPulseAnimation && glow > 0)
                                  ? [
                                      BoxShadow(
                                        color: AppColors.authPulsePeak
                                            .withValues(alpha: 0.45 * glow),
                                        blurRadius: 20 + 10 * glow,
                                        spreadRadius: 2 * glow,
                                      ),
                                    ]
                                  : null,
                        ),
                        child: content,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
```

Also add this constant near the top of the file, alongside the existing `_kAuthTapCooldown`/`_kHoverSweepDuration`:

```dart
const double _kButtonHeight = 50.0;
```

(`AppSizes` import stays — `AppSizes.fontLG`, `AppSizes.spaceSM`, `AppSizes.iconMD` are still used; `AppSizes.radiusLG` is no longer referenced by this file, which is expected.)

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/features/auth/presentation/widgets/auth_outline_button_test.dart`
Expected: PASS — all 10 tests (6 existing + 4 new).

- [ ] **Step 5: Run the full auth widget test suite to confirm no regression at call sites**

Run: `flutter test test/features/auth/`
Expected: PASS — `login_page_test.dart`, `email_entry_page_test.dart`, `verify_code_page_test.dart`, `set_password_page_test.dart` all still find `AuthOutlineButton` by type/label; none inspect its internal decoration.

- [ ] **Step 6: Commit**

```bash
git add lib/features/auth/presentation/widgets/auth_outline_button.dart test/features/auth/presentation/widgets/auth_outline_button_test.dart
git commit -m "feat(auth): pill-shaped AuthOutlineButton with bottom-up hover fill"
```

---

### Task 3: Remove the duplicated email-subtitle line from email_entry_page.dart

**Files:**
- Modify: `lib/features/auth/presentation/pages/email_entry_page.dart:434-454`
- Test: Modify `test/features/auth/presentation/pages/email_entry_page_test.dart`

**Interfaces:**
- Consumes: nothing new (uses existing `EmailEntryPage`, `AppLocalizations`, `LocaleCubit` already imported in the test file).
- Produces: nothing consumed by later tasks — this is the last task.

- [ ] **Step 1: Write the failing test**

Add to `test/features/auth/presentation/pages/email_entry_page_test.dart`, inside `void main() { ... }`, after the existing two tests:

```dart
  testWidgets(
      'does not show a duplicate email-subtitle note under the button',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit(),
        child: const EmailEntryPage(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    // Subtitle appears exactly once (above the field) — no duplicate row
    // with the info icon underneath the submit button.
    expect(
      find.text('أدخل البريد الإلكتروني الذي سجّله المدير لك'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/auth/presentation/pages/email_entry_page_test.dart`
Expected: FAIL — `find.text('أدخل البريد الإلكتروني الذي سجّله المدير لك')` currently `findsNWidgets(2)` (subtitle + duplicated footer note), and `find.byIcon(Icons.info_outline_rounded)` currently `findsOneWidget`.

- [ ] **Step 3: Delete the duplicated Row**

In `lib/features/auth/presentation/pages/email_entry_page.dart`, inside `_FormContent.build`, replace:

```dart
            const SizedBox(height: AppSizes.spaceLG),

            AuthEntryAnimator(
              controller: entryCtrl,
              delay: AuthStaggerDelays.footer,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: AppSizes.iconXS + 1, color: subColor),
                  const SizedBox(width: AppSizes.spaceXS + 2),
                  Expanded(
                    child: Text(
                      context.l10n.authEnterEmailSubtitle,
                      style: AppTextStyles.authFooterNote
                          .copyWith(color: subColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceXL),
```

with:

```dart
            const SizedBox(height: AppSizes.spaceXL),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/auth/presentation/pages/email_entry_page_test.dart`
Expected: PASS — all 3 tests (2 existing + 1 new).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/pages/email_entry_page.dart test/features/auth/presentation/pages/email_entry_page_test.dart
git commit -m "fix(auth): remove duplicated email-subtitle note under the submit button"
```

---

## Final Verification (after Task 3)

- [ ] **Run the full analyzer:** `flutter analyze` — expect "No issues found".
- [ ] **Run the full test suite:** `flutter test` — expect all tests passing (218 existing + 6 new = 224).
- [ ] **Manual visual check:** run the app (`flutter run -d chrome` or equivalent) and step through all five auth screens (login, email entry, verify code, set password, system selection) confirming: no cyan/turquoise anywhere (card border/glow, diagonal seam line, field focus border, button), buttons are full pills that fill bottom-to-top with the navy/purple gradient on hover (desktop), and the email-entry screen shows the subtitle only once (no duplicate row under the button).
