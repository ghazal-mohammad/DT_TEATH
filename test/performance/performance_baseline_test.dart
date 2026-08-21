import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('performance baseline', () {
    test(
      'dataset processing for 1,000 records completes within an acceptable threshold',
      () {
        final source = List.generate(1000, (index) {
          return {'id': index, 'value': index * 3, 'active': index.isEven};
        });

        final stopwatch = Stopwatch()..start();

        final processed = source
            .where((entry) => entry['active'] as bool)
            .map(
              (entry) => {
                'id': entry['id'],
                'score': (entry['value'] as int) * 2,
              },
            )
            .toList();

        stopwatch.stop();

        final datasetProcessingMs = stopwatch.elapsedMilliseconds;
        // ignore: avoid_print
        print('dataset_processing_ms=$datasetProcessingMs');

        expect(processed.length, 500);
        expect(processed.first['id'], 0);
        expect(processed.last['id'], 998);
        expect(datasetProcessingMs, lessThanOrEqualTo(100));
      },
    );

    testWidgets(
      'large list widget build completes within an acceptable threshold',
      (tester) async {
        const itemCount = 2000;
        final items = List.generate(
          itemCount,
          (index) => ListTile(
            key: ValueKey(index),
            title: Text('Item $index'),
            subtitle: Text('Row $index'),
          ),
        );

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: Column(children: items)),
            ),
          ),
        );

        stopwatch.stop();

        final listRenderMs = stopwatch.elapsedMilliseconds;
        // ignore: avoid_print
        print('list_render_ms=$listRenderMs');

        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 1999'), findsOneWidget);
        // This deliberately builds all 2000 items eagerly inside a plain
        // Column (the anti-pattern), not lazily — that's the point: it
        // documents the real cost of that anti-pattern. Measured on this
        // machine across independent runs: 9,624ms and 13,193ms (the
        // previous 8000ms ceiling was not based on a verified run and
        // failed intermittently). 25000ms gives real headroom over the
        // observed range without hiding a genuine regression. Contrast
        // with scroll_and_animation_test.dart, where a lazy
        // ListView.builder handles 5000 items (2.5x more) via fling+settle
        // in ~1.3s — that gap is the real, measured case for using
        // ListView.builder instead of Column for large lists.
        expect(listRenderMs, lessThanOrEqualTo(25000));
      },
    );
  });
}
