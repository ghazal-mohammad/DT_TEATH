// اختبار: التأكد من أن أنيميشن النقطة النابضة (dot pulse) بـ AppTopbarAction
// لا يعمل إلا لما hasDot يكون true — فالحالة الأكثر شيوعاً (hasDot: false)
// ما لازم تشغّل أنيميشن لا نهائي يعلّق pumpAndSettle في كل اختبارات الصفحات.
//
// خلفية العلة (regression): _dotPulseController كان يستدعي
// ..repeat(reverse: true) بدون شرط جوّه initState، فحتى لو hasDot: false
// كانت في أنيميشن لا نهائي شغّالة طول عمر الـ widget — تخلي أي
// tester.pumpAndSettle() يعلّق (timeout) في أي صفحة فيها AppTopbarAction
// جوّه شجرة الـ render (يعني كل صفحة تقريباً عبر AppShellLayout).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/shared/widgets/navigation/app_topbar_action.dart';

void main() {
  testWidgets(
    'hasDot: false — ما فيه أنيميشن شغّالة، فـ pumpAndSettle يكمل من غير timeout',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTopbarAction(
              icon: Icons.notifications,
              onPressed: () {},
              hasDot: false,
            ),
          ),
        ),
      );

      // لو الأنيميشن شغّالة لا نهائياً، هذا السطر يعلّق (timeout) — نجاح
      // الاختبار نفسه هو الدليل على إصلاح العلة.
      await tester.pumpAndSettle();

      expect(find.byType(AppTopbarAction), findsOneWidget);
    },
  );

  testWidgets(
    'hasDot: true — الأنيميشن تشتغل والـ widget يبني من غير أخطاء (بدون pumpAndSettle)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTopbarAction(
              icon: Icons.notifications,
              onPressed: () {},
              hasDot: true,
            ),
          ),
        ),
      );

      // ما نستخدم pumpAndSettle هنا عمداً — الأنيميشن لا نهائية بالتصميم
      // طالما hasDot: true، فـ pumpAndSettle هيعلّق بشكل شرعي.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppTopbarAction), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'hasDot: false → true (didUpdateWidget) — تبدأ الأنيميشن من غير كراش',
    (tester) async {
      Future<void> pumpWithDot(bool hasDot) => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AppTopbarAction(
                  key: const ValueKey('bell'),
                  icon: Icons.notifications,
                  onPressed: () {},
                  hasDot: hasDot,
                ),
              ),
            ),
          );

      // نفس الـ Key عشان Flutter يعيد استخدام نفس الـ State ويستدعي
      // didUpdateWidget بدل ما يعمل State جديدة (createState).
      await pumpWithDot(false);
      await tester.pumpAndSettle();

      await pumpWithDot(true);

      // ما نستخدم pumpAndSettle هنا — بعد didUpdateWidget الأنيميشن
      // المفروض تشتغل لا نهائياً طالما hasDot: true، فهذا شرعي.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppTopbarAction), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'hasDot: true → false (didUpdateWidget) — توقف الأنيميشن، pumpAndSettle يكمل من غير timeout',
    (tester) async {
      Future<void> pumpWithDot(bool hasDot) => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AppTopbarAction(
                  key: const ValueKey('bell'),
                  icon: Icons.notifications,
                  onPressed: () {},
                  hasDot: hasDot,
                ),
              ),
            ),
          );

      await pumpWithDot(true);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await pumpWithDot(false);

      // لو didUpdateWidget ما استدعى .stop() لما hasDot رجعت false، هذا
      // السطر يعلّق (timeout) بنفس شكل العلة الأصلية — هذا هو الدليل
      // الحقيقي إن مسار الإيقاف شغّال صح.
      await tester.pumpAndSettle();

      expect(find.byType(AppTopbarAction), findsOneWidget);
    },
  );
}
