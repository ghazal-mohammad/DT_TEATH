import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:dt_teeth/shared/widgets/layout/app_dashboard_hero.dart';

void main() {
  group('performance startup/dashboard', () {
    testWidgets('simulated startup: dashboard hero initial build', (
      tester,
    ) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppDashboardHero(
                title: 'مرحباً، د.خالد',
                subtitle: 'اختبار بداية التطبيق — benchmark',
                stats: const [
                  AppDashboardHeroStat(value: '247', label: 'مادة'),
                  AppDashboardHeroStat(value: '12', label: 'طلب جديد'),
                  AppDashboardHeroStat(value: '98%', label: 'معدل إنجاز'),
                ],
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      final startupMs = stopwatch.elapsedMilliseconds;
      print('startup_simulated_ms=$startupMs');

      expect(find.text('مرحباً، د.خالد'), findsOneWidget);
      expect(startupMs, lessThanOrEqualTo(2000));

      // Persist measurement for reporting
      try {
        final file = File('test/performance/perf-measurements.json');
        final data = '{"startup_simulated_ms": $startupMs}';
        file.writeAsStringSync(data);
      } catch (_) {}
    });

    testWidgets('dashboard hero medium: multiple stats render', (tester) async {
      // Use a medium number of stats that fits the test viewport.
      const statsCount = 6;
      final stats = List.generate(
        statsCount,
        (i) => AppDashboardHeroStat(value: '${i * 10}', label: 'S$i'),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppDashboardHero(
                        title: 'ملف الإحصاءات',
                        subtitle: 'عرض إحصاءات متعددة',
                        stats: stats,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      final dashboardMs = stopwatch.elapsedMilliseconds;
      print('dashboard_heavy_ms=$dashboardMs');

      // Append dashboard measurement to the same file
      try {
        final file = File('test/performance/perf-measurements.json');
        final existing = file.existsSync() ? file.readAsStringSync() : '{}';
        final merged = existing.replaceFirst(
          '}',
          ', "dashboard_heavy_ms": $dashboardMs}',
        );
        file.writeAsStringSync(merged);
      } catch (_) {}

      expect(find.text('ملف الإحصاءات'), findsOneWidget);
      expect(dashboardMs, lessThanOrEqualTo(4000));
    });
  });
}
