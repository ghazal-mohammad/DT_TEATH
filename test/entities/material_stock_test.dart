import 'package:dt_teeth/features/warehouse/domain/entities/material_stock.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/stock_batch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StockBatch.fromJson', () {
    test('يقرأ الحقول ويحوّل التاريخ', () {
      final b = StockBatch.fromJson({
        'id': 5,
        'quantity': '12',
        'expiration_date': '2027-01-15',
        'is_expired': false,
        'created_at': '2026-08-01 10:00:00',
      });
      expect(b.id, '5');
      expect(b.quantity, 12);
      expect(b.expiryDate, DateTime(2027, 1, 15));
      expect(b.isExpired, isFalse);
    });

    test('بلا صلاحية ⇒ null، وحالة انتهاء true', () {
      final b = StockBatch.fromJson(
          {'id': 1, 'quantity': 3, 'expiration_date': null, 'is_expired': true});
      expect(b.expiryDate, isNull);
      expect(b.isExpired, isTrue);
    });
  });

  group('MaterialStock.fromJson (showStockDetails)', () {
    test('يجمع المادة + الدفعات + الإجمالي', () {
      final s = MaterialStock.fromJson({
        'material': {
          'id': 9,
          'name': 'قفازات',
          'unit': 'قطعة',
          'company_name': 'الأمل',
        },
        'total_quantity': 40,
        'batches_count': 2,
        'batches': [
          {'id': 1, 'quantity': 25, 'expiration_date': '2027-02-01'},
          {'id': 2, 'quantity': 15, 'expiration_date': null},
        ],
      });
      expect(s.materialId, '9');
      expect(s.name, 'قفازات');
      expect(s.unit, 'قطعة');
      expect(s.totalQuantity, 40);
      expect(s.batches.length, 2);
      expect(s.batchesCount, 2);
      expect(s.batches.first.quantity, 25);
    });

    test('استجابة بلا دفعات ⇒ قائمة فارغة لا انهيار', () {
      final s = MaterialStock.fromJson({
        'material': {'id': 1, 'name': 'x', 'unit': 'u', 'company_name': 'c'},
        'total_quantity': 0,
      });
      expect(s.batches, isEmpty);
      expect(s.totalQuantity, 0);
    });
  });

  group('StockMovementReason.apiKey', () {
    test('يطابق قيم الباك (returned ⇒ return)', () {
      expect(StockMovementReason.purchase.apiKey, 'purchase');
      expect(StockMovementReason.fulfillment.apiKey, 'fulfillment');
      expect(StockMovementReason.expired.apiKey, 'expired');
      expect(StockMovementReason.adjustment.apiKey, 'adjustment');
      expect(StockMovementReason.returned.apiKey, 'return');
    });
  });
}
