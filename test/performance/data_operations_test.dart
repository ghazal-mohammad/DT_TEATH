// ════════════════════════════════════════════════════════════════════════════
// data_operations_test.dart
//
// Performance test that operates on real `WarehouseMaterial` domain entities
// (not plain ints/maps) so the measured cost reflects real app objects:
// field comparisons, real memory layout, and real comparator/getter overhead.
//
// Complementary to `performance_baseline_test.dart`, which exercises a plain
// `Map<String, dynamic>` dataset — this file intentionally does NOT repeat
// that scenario. Every operation here is performed on constructed
// `WarehouseMaterial` instances built from the app's own entity/enum types.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material.dart';

void main() {
  group('data operations performance (real WarehouseMaterial entities)', () {
    test(
      'sort/filter/group 10000 WarehouseMaterial instances complete within '
      'an evidence-based threshold',
      () {
        const total = 10000;

        // ── 1. Generate 10,000 distinct real WarehouseMaterial instances ──
        // Quantity descends (10000 down to 1) so sorting ascending by
        // quantity is real, non-trivial work (not already-sorted input).
        // Category cycles across every real MaterialCategory enum value
        // (clinic, lab, both) so grouping exercises all buckets.
        const categories = MaterialCategory.values;
        final materials = List<WarehouseMaterial>.generate(total, (i) {
          return WarehouseMaterial(
            id: 'MAT-$i',
            name: 'Material $i',
            companyName: 'Company ${i % 50}',
            category: categories[i % categories.length],
            quantity: total - i, // descending: 10000, 9999, ..., 1
            unit: 'unit',
            pricePerUnit: (i % 500) + 1.0,
          );
        });

        // ── 2. Time: sort by quantity ascending ──
        final sortStopwatch = Stopwatch()..start();
        materials.sort((a, b) => a.quantity.compareTo(b.quantity));
        sortStopwatch.stop();
        final sortMs = sortStopwatch.elapsedMilliseconds;

        // Correctness: verify actual sortedness by walking adjacent pairs
        // (do not just trust that .sort() worked).
        var isSorted = true;
        for (var i = 1; i < materials.length; i++) {
          if (materials[i - 1].quantity > materials[i].quantity) {
            isSorted = false;
            break;
          }
        }
        expect(isSorted, isTrue, reason: 'list must be non-decreasing by quantity after sort');
        expect(materials.first.quantity, 1);
        expect(materials.last.quantity, total);

        // ── 3. Time: filter for "low stock" ──
        // Reuses the backend's own documented default: the low-stock
        // endpoint's default threshold is 10 units, per the comment in
        // lib/features/warehouse/data/datasources/
        // warehouse_inventory_remote_datasource.dart:
        //   "GET lowStockMaterials?threshold= — الافتراضي بالباك threshold=10."
        // (MaterialStatusResolver's `low` status instead compares quantity
        // against each material's own `minStock` field, which is per-item,
        // not a fixed dataset-wide threshold, so it isn't reusable as a
        // single predicate here — the backend's fixed default is.)
        const lowStockThreshold = 10;
        final filterStopwatch = Stopwatch()..start();
        final lowStockMaterials =
            materials.where((m) => m.quantity < lowStockThreshold).toList();
        filterStopwatch.stop();
        final filterMs = filterStopwatch.elapsedMilliseconds;

        // Correctness: independently compute the expected count via a plain
        // for-loop over the original generation formula (quantity = total -
        // i), a different code path from the `.where(...)` call above.
        var expectedLowStockCount = 0;
        for (var i = 0; i < total; i++) {
          final quantity = total - i;
          if (quantity < lowStockThreshold) expectedLowStockCount++;
        }
        expect(lowStockMaterials.length, expectedLowStockCount);
        expect(lowStockMaterials.every((m) => m.quantity < lowStockThreshold), isTrue);

        // ── 4. Time: group by category (realistic warehouse-dashboard op) ──
        final groupStopwatch = Stopwatch()..start();
        final grouped = <MaterialCategory, List<WarehouseMaterial>>{};
        for (final m in materials) {
          grouped.putIfAbsent(m.category, () => <WarehouseMaterial>[]).add(m);
        }
        groupStopwatch.stop();
        final groupMs = groupStopwatch.elapsedMilliseconds;

        // Correctness: total items across all buckets equals the source size.
        final groupedTotal =
            grouped.values.fold<int>(0, (sum, list) => sum + list.length);
        expect(groupedTotal, total);
        // Every real category value that appears in the source must be a key.
        for (final c in categories) {
          expect(grouped.containsKey(c), isTrue, reason: '$c must have a bucket');
        }

        debugPrint(
          'sort_10k_materials_ms=$sortMs '
          'filter_low_stock_ms=$filterMs '
          'group_by_category_ms=$groupMs',
        );

        // Evidence-based ceilings: a first run on this dev machine measured
        // sort_10k_materials_ms=8, filter_low_stock_ms=2,
        // group_by_category_ms=6 for 10,000 real WarehouseMaterial
        // instances. Ceilings below are ~5x those observed values (rounded
        // up) to leave headroom for slower/loaded CI hardware while still
        // catching a real regression.
        expect(sortMs, lessThanOrEqualTo(40));
        expect(filterMs, lessThanOrEqualTo(20));
        expect(groupMs, lessThanOrEqualTo(30));
      },
    );
  });
}
