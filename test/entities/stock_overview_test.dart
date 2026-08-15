// اختبار: StockOverviewItem (WarehouseStockController::index) و StockLogEntry
// (WarehouseStockController::logs) — endpoints ما كان إلها أي مستهلك بالفرونت
// قبل مراجعة ربط المستودع الشاملة (2026-08-15). قرأت الكونترولر الفعلي مباشرة
// لالتقاط الشكل الحقيقي (لا تخمين).

import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/stock_overview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StockOverviewItem.fromJson (WarehouseStockController::index)', () {
    test('يقرأ كل الحقول', () {

      final item = StockOverviewItem.fromJson({
        'material_id': 1,
        'name': 'قفازات',
        'name_en': 'Gloves',
        'company_name': 'الأمل',
        'unit': 'علبة',
        'category': 'clinic',
        'price_per_unit': '500.5',
        'is_active': true,
        'total_quantity': 340,
        'batches_count': 3,
        'is_low': false,
      });
      expect(item.materialId, '1');
      expect(item.name, 'قفازات');
      expect(item.nameEn, 'Gloves');
      expect(item.companyName, 'الأمل');
      expect(item.unit, 'علبة');
      expect(item.category, MaterialCategory.clinic);
      expect(item.pricePerUnit, 500.5);
      expect(item.isActive, isTrue);
      expect(item.totalQuantity, 340);
      expect(item.batchesCount, 3);
      expect(item.isLow, isFalse);
    });

    test('category غير معروفة ⇒ null بدل رمي استثناء (قائمة، لا تفشل كاملة)',
        () {
      final item = StockOverviewItem.fromJson({
        'material_id': 2,
        'category': 'weird',
        'total_quantity': 5,
        'is_low': true,
      });
      expect(item.category, isNull);
      expect(item.isLow, isTrue);
    });
  });

  group('StockLogEntry.fromJson (WarehouseStockController::logs)', () {
    test('يقرأ نوع الحركة (in) + التفاصيل', () {
      final log = StockLogEntry.fromJson({
        'id': 5,
        'material_id': 1,
        'material_name': 'قفازات',
        'warehouse_stock_id': 3,
        'type': 'in',
        'quantity': 50,
        'reason': 'purchase',
        'notes': 'دفعة جديدة',
        'done_by': 'سما',
        'created_at': '2026-08-10 09:00:00',
      });
      expect(log.id, '5');
      expect(log.materialName, 'قفازات');
      expect(log.type, StockLogType.stockIn);
      expect(log.quantity, 50);
      expect(log.reason, 'purchase');
      expect(log.notes, 'دفعة جديدة');
      expect(log.doneBy, 'سما');
      expect(log.createdAt, DateTime.parse('2026-08-10 09:00:00'));
    });

    test('type=out + done_by/notes غائبة ⇒ null بدل فراغ', () {
      final log = StockLogEntry.fromJson({
        'id': 6,
        'type': 'out',
        'quantity': 5,
      });
      expect(log.type, StockLogType.stockOut);
      expect(log.doneBy, isNull);
      expect(log.notes, isNull);
    });
  });
}
