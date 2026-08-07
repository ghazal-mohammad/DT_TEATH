import 'package:dt_teeth/features/warehouse/domain/entities/material_category.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/material_status.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarehouseMaterial.fromJson (عقد formatMaterial)', () {
    test('يقرأ كل الحقول الأساسية', () {
      final m = WarehouseMaterial.fromJson({
        'id': 12,
        'name': 'قفازات',
        'name_en': 'Gloves',
        'company_name': 'الأمل',
        'price_per_unit': '250.50',
        'dosage': '2%',
        'unit': 'قطعة',
        'category': 'lab',
        'total_stock': 40,
        'batches_count': 3,
      });
      expect(m.id, '12');
      expect(m.name, 'قفازات');
      expect(m.nameEn, 'Gloves');
      expect(m.companyName, 'الأمل');
      expect(m.pricePerUnit, 250.5);
      expect(m.dosage, '2%');
      expect(m.category, MaterialCategory.lab);
      expect(m.quantity, 40);
      expect(m.batchesCount, 3);
    });

    test('فئة مجهولة تُرمى FormatException', () {
      expect(
        () => WarehouseMaterial.fromJson({'name': 'x', 'category': 'زبد'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('حقول اختيارية غائبة ⇒ قيم آمنة (nameEn/dosage null)', () {
      final m = WarehouseMaterial.fromJson({
        'id': '1',
        'name': 'مادة',
        'company_name': 'ش',
        'category': 'clinic',
        'unit': 'علبة',
      });
      expect(m.nameEn, isNull);
      expect(m.dosage, isNull);
      expect(m.pricePerUnit, 0);
      expect(m.quantity, 0);
    });

    test('quantity يقبل total_stock أو quantity', () {
      final a = WarehouseMaterial.fromJson(
          {'id': '1', 'name': 'n', 'company_name': 'c', 'category': 'both', 'unit': 'u', 'quantity': 7});
      expect(a.quantity, 7);
    });
  });

  group('toJson (body الحفظ)', () {
    test('يُنتج مفاتيح الباك ويحذف الاختياري الفارغ', () {
      const m = WarehouseMaterial(
        id: '1',
        name: 'مادة',
        companyName: 'شركة',
        category: MaterialCategory.both,
        quantity: 10,
        unit: 'قطعة',
        pricePerUnit: 99,
      );
      final j = m.toJson();
      expect(j['name'], 'مادة');
      expect(j['company_name'], 'شركة');
      expect(j['price_per_unit'], 99);
      expect(j['unit'], 'قطعة');
      expect(j['category'], 'both');
      expect(j.containsKey('name_en'), isFalse);
      expect(j.containsKey('dosage'), isFalse);
      // الكمية لا تُرسَل (تُدار عبر الدفعات).
      expect(j.containsKey('total_stock'), isFalse);
    });
  });

  group('MaterialCategory mapping', () {
    test('apiKey ثابت لكل قيمة', () {
      expect(MaterialCategory.clinic.apiKey, 'clinic');
      expect(MaterialCategory.lab.apiKey, 'lab');
      expect(MaterialCategory.both.apiKey, 'both');
    });

    test('fromString غير حسّاس لحالة الأحرف/الفراغ', () {
      expect(materialCategoryFromString(' Clinic '), MaterialCategory.clinic);
      expect(materialCategoryFromString('LAB'), MaterialCategory.lab);
      expect(materialCategoryFromString('unknown'), isNull);
    });
  });

  group('MaterialStatusResolver', () {
    test('منتهي الصلاحية له الأولوية القصوى', () {
      expect(
        MaterialStatusResolver.resolve(
            quantity: 100, minStock: 10, daysUntilExpiry: 0),
        MaterialStatus.expired,
      );
    });

    test('كمية صفر ⇒ نفد', () {
      expect(
        MaterialStatusResolver.resolve(quantity: 0, minStock: 5),
        MaterialStatus.outOfStock,
      );
    });

    test('كمية ≤ الحد الأدنى ⇒ ينفد', () {
      expect(
        MaterialStatusResolver.resolve(quantity: 5, minStock: 5),
        MaterialStatus.low,
      );
    });

    test('صلاحية ≤ 30 يوم ⇒ ستنتهي قريباً', () {
      expect(
        MaterialStatusResolver.resolve(
            quantity: 100, minStock: 10, daysUntilExpiry: 15),
        MaterialStatus.expiringSoon,
      );
    });

    test('minStock=0 (بيانات الباك) وكمية موجبة ⇒ متوفر (لا حالة زائفة)', () {
      expect(
        MaterialStatusResolver.resolve(quantity: 3, minStock: 0),
        MaterialStatus.available,
      );
    });
  });

  group('copyWith', () {
    test('يمسح الاختياري صراحةً عبر sentinels', () {
      const m = WarehouseMaterial(
        id: '1',
        name: 'n',
        nameEn: 'N',
        dosage: 'd',
        companyName: 'c',
        category: MaterialCategory.clinic,
        quantity: 1,
        unit: 'u',
        pricePerUnit: 1,
      );
      final cleared = m.copyWith(clearNameEn: true, clearDosage: true);
      expect(cleared.nameEn, isNull);
      expect(cleared.dosage, isNull);
      expect(cleared.name, 'n'); // البقية سليمة.
    });
  });
}
