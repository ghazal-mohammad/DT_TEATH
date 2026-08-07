// ════════════════════════════════════════════════════════════════════════════
// warehouse_inventory_repository.dart
//
// عقد مؤشّرات المخزون للوحة المستودع.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/inventory_summary.dart';

abstract class WarehouseInventoryRepository {
  /// يجمع ملخّص مستويات المخزون + قيمته في كيان واحد للوحة.
  Future<InventorySummary> getSummary();
}
