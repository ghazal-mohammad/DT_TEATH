// اختبار: جدول فريق المخبر ما عاد يعرض حالة "نشط/متاح/استراحة" ولا زر
// إيقاف/استئناف — كانت وهمية بالكامل (لا تُحفظ، لا تعكس شيئاً من الباك).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/technicians/lab_technician_table.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/technicians/lab_technician_view_data.dart';

void main() {
  testWidgets('لا يعرض أيقونة إيقاف/استئناف ولا شارة حالة وهمية', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final tech = TechnicianItem(
      id: 1,
      name: 'يوسف ناصر',
      role: 'فني',
      shift: '—',
      currentTask: 'بانتظار التوكيل',
      taskCount: 0,
      initials: 'ين',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LabTechnicianTeamTable(
            technicians: [tech],
            onAssign: (_) {},
            onEditSchedule: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.pause_rounded), findsNothing);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });
}
