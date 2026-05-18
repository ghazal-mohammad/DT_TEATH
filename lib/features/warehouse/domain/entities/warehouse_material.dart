// ════════════════════════════════════════════════════════════════════════════
// warehouse_material.dart
//
// الـ entity الرئيسي للمادة في نظام المستودع.
//
// 🎯 الهدف:
//   تمثيل مادة واحدة بكل حقولها — يُستخدم في:
//   - عرض material card في الشبكة
//   - نموذج الإضافة/التعديل
//   - جدول Reports
//
// 🔮 قابلية التوسيع:
//   - الحقول الاختيارية (supplier, price, notes) سهل إضافة المزيد
//   - `copyWith` يتيح update مرن (للـ form)
//   - `toJson` / `fromJson` جاهزين للـ backend integration
//
// قاعدة معمارية:
//   نستخدم immutable class بـ const constructor — كل تحديث يُنتج نسخة جديدة
//   عبر copyWith. هذا يتوافق مع نمط BLoC ويسهّل اختبار الـ state.
// ════════════════════════════════════════════════════════════════════════════

import 'material_category.dart';
import 'material_status.dart';

/// مادة واحدة في المستودع.
///
/// الحقول الإجبارية: id, name, category, quantity, unit, minStock.
/// الباقي اختياري.
class WarehouseMaterial {
  const WarehouseMaterial({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    this.expiryDate,
    this.supplier,
    this.price,
    this.notes,
  });

  /// المعرّف الفريد (للـ backend عادة UUID، حالياً String mock).
  final String id;

  /// اسم المادة (مثل "قفازات لاتكس M").
  final String name;

  /// فئة المادة.
  final MaterialCategory category;

  /// الكمية الحالية.
  final int quantity;

  /// الوحدة (مثل "قطعة", "علبة", "كيلو").
  final String unit;

  /// الحد الأدنى — تحته تُعتبر "ينفد".
  final int minStock;

  /// تاريخ انتهاء الصلاحية (اختياري — بعض المواد لا تنتهي).
  final DateTime? expiryDate;

  /// اسم المورّد (اختياري).
  final String? supplier;

  /// السعر بالليرة السورية (اختياري).
  final double? price;

  /// ملاحظات إضافية (اختياري).
  final String? notes;

  // ────────────────────────────────────────────────────────────────────────
  //                         COMPUTED PROPERTIES
  // ────────────────────────────────────────────────────────────────────────

  /// عدد الأيام المتبقية قبل انتهاء الصلاحية (`null` لو ما في تاريخ).
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    return expiryDate!.difference(now).inDays;
  }

  /// الحالة المحسوبة من البيانات.
  MaterialStatus get status {
    return MaterialStatusResolver.resolve(
      quantity: quantity,
      minStock: minStock,
      daysUntilExpiry: daysUntilExpiry,
    );
  }

  /// هل الكمية أقل من 30% من الحد الأدنى؟ (للـ severity في UI).
  bool get isCriticalLow => minStock > 0 && quantity < (minStock * 0.3);

  // ────────────────────────────────────────────────────────────────────────
  //                              COPY/UPDATE
  // ────────────────────────────────────────────────────────────────────────

  /// ينتج نسخة جديدة مع تحديث بعض الحقول.
  WarehouseMaterial copyWith({
    String? id,
    String? name,
    MaterialCategory? category,
    int? quantity,
    String? unit,
    int? minStock,
    DateTime? expiryDate,
    String? supplier,
    double? price,
    String? notes,
    // Sentinels لمسح الحقول الاختيارية بشكل صريح
    bool clearExpiry = false,
    bool clearSupplier = false,
    bool clearPrice = false,
    bool clearNotes = false,
  }) {
    return WarehouseMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minStock: minStock ?? this.minStock,
      expiryDate: clearExpiry ? null : (expiryDate ?? this.expiryDate),
      supplier: clearSupplier ? null : (supplier ?? this.supplier),
      price: clearPrice ? null : (price ?? this.price),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              SERIALIZATION
  // ────────────────────────────────────────────────────────────────────────

  /// تحويل إلى JSON — جاهز للـ POST/PUT للـ backend.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.apiKey,
        'quantity': quantity,
        'unit': unit,
        'min_stock': minStock,
        if (expiryDate != null) 'expiry_date': expiryDate!.toIso8601String(),
        if (supplier != null) 'supplier': supplier,
        if (price != null) 'price': price,
        if (notes != null) 'notes': notes,
      };

  /// تكوين entity من JSON — جاهز للـ GET من الـ backend.
  ///
  /// يرمي [FormatException] إذا الـ category غير معروف.
  factory WarehouseMaterial.fromJson(Map<String, dynamic> json) {
    final categoryStr = json['category'] as String;
    final category = materialCategoryFromString(categoryStr);
    if (category == null) {
      throw FormatException('Unknown material category: $categoryStr');
    }
    return WarehouseMaterial(
      id: json['id'] as String,
      name: json['name'] as String,
      category: category,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      minStock: json['min_stock'] as int,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      supplier: json['supplier'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              EQUALITY
  // ────────────────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WarehouseMaterial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WarehouseMaterial(id: $id, name: $name, qty: $quantity $unit)';
}
