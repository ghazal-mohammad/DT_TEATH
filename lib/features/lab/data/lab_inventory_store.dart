// ════════════════════════════════════════════════════════════════════════════
// lab_inventory_store.dart
//
// مصدر بيانات مشترك (in-memory) لمخزون المخبر الداخلي.
// يستخدمه: صفحة مخزون المخبر + مودال إنجاز الطلبية (لإنقاص المواد المستهلكة).
//
// 🔮 يُستبدل لاحقاً بـ Repository يتصل بالـ API:
//   GET  /api/lab/inventory
//   POST /api/lab/orders/{id}/consume   (ينقص المخزون عند إنجاز الطلب)
//
// نمط: ChangeNotifier singleton — أبسط من Bloc لحالة mock مشتركة بين صفحتين.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

/// فئة مادة المخبر.
enum LabMaterialCategory { medical, consumables, medicines, metals }

/// حالة مخزون المادة (محسوبة).
enum LabStockStatus { available, low, out }

/// سطر استهلاك واحد (مادة + كمية) — يُستخدم عند إنجاز الطلب.
class LabConsumptionLine {
  const LabConsumptionLine({required this.materialId, required this.quantity});
  final String materialId;
  final int quantity;
}

/// مادة واحدة في مخزون المخبر الداخلي.
class LabMaterial {
  LabMaterial({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    required this.pricePerUnit,
  });

  final String id;
  final String name;
  final LabMaterialCategory category;
  int quantity;
  final String unit;
  final int minStock;

  /// سعر الوحدة بالليرة السورية — لحساب تكلفة الطلب من الاستهلاك.
  final int pricePerUnit;

  LabStockStatus get status {
    if (quantity <= 0) return LabStockStatus.out;
    if (quantity < minStock) return LabStockStatus.low;
    return LabStockStatus.available;
  }
}

/// مخزن مخزون المخبر — singleton مشترك بين الصفحات.
class LabInventoryStore extends ChangeNotifier {
  LabInventoryStore._();

  static final LabInventoryStore instance = LabInventoryStore._();

  final List<LabMaterial> _items = _seed();

  /// نسخة للقراءة فقط من المواد.
  List<LabMaterial> get items => List.unmodifiable(_items);

  LabMaterial? byId(String id) {
    for (final m in _items) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// إنقاص كمية مادة واحدة (تسجيل استهلاك يدوي).
  void consume(String id, int amount) {
    final m = byId(id);
    if (m == null || amount <= 0) return;
    m.quantity = (m.quantity - amount).clamp(0, m.quantity);
    notifyListeners();
  }

  /// تطبيق استهلاك طلبية كاملة (عند الإنجاز) — ينقص كل الأسطر دفعة واحدة.
  void applyConsumption(List<LabConsumptionLine> lines) {
    var changed = false;
    for (final line in lines) {
      final m = byId(line.materialId);
      if (m == null || line.quantity <= 0) continue;
      m.quantity = (m.quantity - line.quantity).clamp(0, m.quantity);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// مجموع تكلفة المواد لأسطر استهلاك (سعر الوحدة × الكمية).
  int costOf(List<LabConsumptionLine> lines) {
    var total = 0;
    for (final line in lines) {
      final m = byId(line.materialId);
      if (m == null) continue;
      total += m.pricePerUnit * line.quantity;
    }
    return total;
  }

  static List<LabMaterial> _seed() => [
        LabMaterial(
          id: 'LM-01',
          name: 'زركون بلوك A3',
          category: LabMaterialCategory.metals,
          quantity: 8,
          unit: 'بلوك',
          minStock: 5,
          pricePerUnit: 95000,
        ),
        LabMaterial(
          id: 'LM-02',
          name: 'سيراميك E-max',
          category: LabMaterialCategory.metals,
          quantity: 3,
          unit: 'بلوك',
          minStock: 6,
          pricePerUnit: 110000,
        ),
        LabMaterial(
          id: 'LM-03',
          name: 'أكريل تشكيل',
          category: LabMaterialCategory.consumables,
          quantity: 14,
          unit: 'علبة',
          minStock: 4,
          pricePerUnit: 18000,
        ),
        LabMaterial(
          id: 'LM-04',
          name: 'سيليكون طبع A-Type',
          category: LabMaterialCategory.consumables,
          quantity: 5,
          unit: 'كيلو',
          minStock: 2,
          pricePerUnit: 25000,
        ),
        LabMaterial(
          id: 'LM-05',
          name: 'غراء طبي أبيض',
          category: LabMaterialCategory.medical,
          quantity: 6,
          unit: 'أنبوب',
          minStock: 3,
          pricePerUnit: 8000,
        ),
        LabMaterial(
          id: 'LM-06',
          name: 'ورنيش PFM',
          category: LabMaterialCategory.consumables,
          quantity: 2,
          unit: 'زجاجة',
          minStock: 3,
          pricePerUnit: 14000,
        ),
        LabMaterial(
          id: 'LM-07',
          name: 'معجون تلميع',
          category: LabMaterialCategory.consumables,
          quantity: 9,
          unit: 'علبة',
          minStock: 4,
          pricePerUnit: 12000,
        ),
        LabMaterial(
          id: 'LM-08',
          name: 'مسحوق جبص أزرق',
          category: LabMaterialCategory.medical,
          quantity: 11,
          unit: 'كيلو',
          minStock: 5,
          pricePerUnit: 9000,
        ),
      ];
}
