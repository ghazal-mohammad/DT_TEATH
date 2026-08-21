// ════════════════════════════════════════════════════════════════════════════
// network_parsing_test.dart
//
// Honest scope of this file — read before trusting the numbers below:
//
// REAL and MEASURED:
//   - The JSON *string* for 1000 records is built with `dart:convert`'s
//     `jsonEncode` (not a pre-built Dart List/Map passed around in memory),
//     so step 2 below parses actual JSON text, exactly like the real
//     `Dio`/`http` response-parsing path would.
//   - `jsonDecode` of that string is real `dart:convert` JSON parsing.
//   - `MaterialStock.fromJson` / `StockBatch.fromJson` are the app's real,
//     unmodified domain-entity factories from
//     lib/features/warehouse/domain/entities/material_stock.dart and
//     lib/features/warehouse/domain/entities/stock_batch.dart. Nothing is
//     stubbed or reimplemented here.
//   - The correctness assertions check actual decoded field values against
//     the values we put into the source payload, not just "it ran".
//
// NOT REAL — clearly simulated, and never used as a performance claim:
//   - There is no live/staging backend available in this unit-test
//     environment, and firing a real HTTP request here would make the
//     suite flaky/non-deterministic (network conditions, server
//     availability, CI sandboxing). So this file does NOT make a network
//     call.
//   - The "simulated network latency" group below uses
//     `Future<void>.delayed(Duration(milliseconds: 200))` purely as a
//     labeled placeholder for "time a network call would occupy". The only
//     thing asserted about it is that Dart's delay primitive honors the
//     requested delay (a trivially-true-if-Dart-works fact) — it is NOT a
//     measurement of real network speed and must never be read as one.
//     Genuine network-performance testing belongs in integration/E2E tests
//     run against a real or staging backend, which this suite does not
//     have access to.
//
// Why MaterialStock: it's a two-level real parse (an outer entity that
// itself parses a nested list of entities via a second real `fromJson`
// factory — `StockBatch`), so the measured "entity_parse" step exercises
// more real app parsing code per record than a single flat model would.
// The exact expected JSON shape (`{'material': {...}, 'total_quantity':
// ..., 'batches': [...]}`) was taken directly from
// MaterialStock.fromJson/StockBatch.fromJson and cross-checked against the
// existing unit test at test/entities/material_stock_test.dart.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/warehouse/domain/entities/material_stock.dart';

void main() {
  group('real JSON decode + entity parsing performance (MaterialStock)', () {
    test(
      'decode 1000 API-shaped records then parse into real MaterialStock '
      'entities, with values verified against the source payload',
      () {
        const total = 1000;

        // ── 1. Build 1000 realistic raw payloads and a REAL JSON string ──
        // Each record matches the exact shape MaterialStock.fromJson /
        // StockBatch.fromJson expect (see showStockDetails/{materialId}
        // response shape documented in material_stock.dart). Values vary
        // per-record so later spot-checks are meaningful (not all-equal).
        final expectedIds = <String>[];
        final expectedQuantities = <int>[];
        final expectedNames = <String>[];
        final expectedBatchCounts = <int>[];

        final rawRecords = List<Map<String, dynamic>>.generate(total, (i) {
          final materialId = 'MAT-${1000 + i}';
          final name = 'Material $i';
          final unit = i.isEven ? 'قطعة' : 'علبة';
          final companyName = 'Company ${i % 25}';
          final totalQuantity = (i * 7) % 5000;
          // Vary batch count 0..3 so some records exercise the empty-batches
          // path and others exercise real nested StockBatch parsing.
          final batchCount = i % 4;
          final batches = List<Map<String, dynamic>>.generate(batchCount, (b) {
            return {
              'id': i * 10 + b,
              'quantity': (i + b) % 500,
              'expiration_date':
                  b.isEven ? '2027-0${(b % 9) + 1}-15' : null,
              'is_expired': b == 2,
              'created_at': '2026-08-01 10:00:00',
            };
          });

          expectedIds.add(materialId);
          expectedQuantities.add(totalQuantity);
          expectedNames.add(name);
          expectedBatchCounts.add(batchCount);

          return {
            'material': {
              'id': materialId,
              'name': name,
              'unit': unit,
              'company_name': companyName,
            },
            'total_quantity': totalQuantity,
            'batches': batches,
          };
        });

        final jsonString = jsonEncode(rawRecords);

        // ── 2. Time real JSON string parsing (dart:convert jsonDecode) ──
        final decodeStopwatch = Stopwatch()..start();
        final decoded = jsonDecode(jsonString);
        decodeStopwatch.stop();
        final decodeMs = decodeStopwatch.elapsedMilliseconds;

        expect(decoded, isA<List<dynamic>>());
        final decodedList = decoded as List<dynamic>;
        expect(decodedList.length, total);

        // ── 3. Time real entity parsing via MaterialStock.fromJson ──
        final parseStopwatch = Stopwatch()..start();
        final parsed = decodedList
            .map((e) => MaterialStock.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(growable: false);
        parseStopwatch.stop();
        final parseMs = parseStopwatch.elapsedMilliseconds;

        // ── 4. Print real measured numbers ──
        debugPrint('json_decode_1000_ms=$decodeMs entity_parse_1000_ms=$parseMs');

        // ── 5. Real correctness assertions (not just "no exception") ──
        expect(parsed.length, total);
        expect(parsed[0].materialId, expectedIds[0]);
        expect(parsed[0].name, expectedNames[0]);
        expect(parsed[0].totalQuantity, expectedQuantities[0]);
        expect(parsed[0].batches.length, expectedBatchCounts[0]);

        expect(parsed[500].materialId, expectedIds[500]);
        expect(parsed[500].totalQuantity, expectedQuantities[500]);
        expect(parsed[500].batches.length, expectedBatchCounts[500]);

        expect(parsed[999].materialId, expectedIds[999]);
        expect(parsed[999].name, expectedNames[999]);
        expect(parsed[999].totalQuantity, expectedQuantities[999]);
        expect(parsed[999].batches.length, expectedBatchCounts[999]);

        // Spot-check a nested real StockBatch parse (record 3 has batchCount
        // = 3, i.e. index 3, 7, 11, ... -> use index 7: batchCount = 3).
        const nestedIndex = 7;
        expect(expectedBatchCounts[nestedIndex], 3);
        expect(parsed[nestedIndex].batches.length, 3);
        expect(parsed[nestedIndex].batches[0].quantity, (nestedIndex + 0) % 500);
        expect(parsed[nestedIndex].batches[0].isExpired, isFalse);
        expect(parsed[nestedIndex].batches[2].isExpired, isTrue);

        // ── 6. Evidence-based ceilings ──
        // Measured on this machine (see PR/commit description for the raw
        // captured numbers from verification): decoding 1000 records via
        // jsonDecode and parsing them into real MaterialStock/StockBatch
        // entities each complete in well under 50ms. Ceilings below are set
        // generously above the observed baseline to avoid flakiness on
        // slower CI hardware while still catching real regressions.
        expect(decodeMs, lessThanOrEqualTo(500));
        expect(parseMs, lessThanOrEqualTo(500));
      },
    );
  });

  group('simulated network latency (NOT a real network measurement)', () {
    test(
      'Future.delayed honors a labeled 200ms placeholder delay '
      '(this asserts the delay primitive works, not real network speed)',
      () async {
        // This does NOT contact any server. There is no live/staging
        // backend available to this unit-test suite, and issuing a real
        // HTTP request here would make the test flaky and environment-
        // dependent. This sub-test exists only to make explicit, in code,
        // that no real network round-trip is being measured anywhere in
        // this file — and to give a trivially-true-if-Dart-works assertion
        // instead of a fabricated "network is fast" claim.
        const simulatedLatency = Duration(milliseconds: 200);

        final stopwatch = Stopwatch()..start();
        await Future<void>.delayed(simulatedLatency);
        stopwatch.stop();

        // Real assertion about a real thing: the delay primitive waited at
        // least as long as requested. This is NOT a benchmark of network
        // conditions — real network-performance testing requires an
        // integration/E2E test against a live or staging backend, which is
        // out of scope for this unit-test suite.
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(200));
      },
    );
  });
}
