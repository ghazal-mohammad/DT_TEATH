// ════════════════════════════════════════════════════════════════════════════
// warehouse_material.dart
//
// الـ entity الرئيسي للمادة في نظام المستودع — **مطابق لعقد الباك**.
//
// عقد الباك (formatMaterial):
//   { id, name, name_en, company_name, price_per_unit, dosage, unit,
//     category(clinic|lab|both), total_stock, batches_count }
//
// الحقول التي لا يرسلها الباك (minStock, expiryDate, notes) اختيارية —
// تُستخدم لحسابات الـ UI فقط (الحالة، أيام الصلاحية) ولا تُرسَل في الحفظ.
//
// قاعدة معمارية:
//   immutable class بـ const constructor — كل تحديث يُنتج نسخة جديدة عبر
//   copyWith. يتوافق مع نمط BLoC ويسهّل اختبار الـ state.
// ════════════════════════════════════════════════════════════════════════════

import 'material_category.dart';
import 'material_status.dart';

/// مادة واحدة في المستودع.
///
/// الحقول الإجبارية (عقد الباك): id, name, companyName, category, quantity,
/// unit, pricePerUnit. الباقي اختياري.
class WarehouseMaterial {
  const WarehouseMaterial({
    required this.id,
    required this.name,
    required this.companyName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.nameEn,
    this.dosage,
    this.batchesCount = 0,
    this.minStock = 0,
    this.expiryDate,
    this.notes,
  });

  /// المعرّف الفريد.
  final String id;

  /// اسم المادة بالعربية (مثل "قفازات لاتكس M").
  final String name;

  /// الاسم بالإنجليزية (اختياري — name_en في الباك).
  final String? nameEn;

  /// اسم الشركة المصنّعة/المورّدة (company_name — إجباري في الباك).
  final String companyName;

  /// فئة المادة — جهة الاستخدام (clinic|lab|both).
  final MaterialCategory category;

  /// الكمية الحالية (total_stock من الباك = مجموع الدفعات).
  final int quantity;

  /// الوحدة (مثل "قطعة", "علبة", "كيلو").
  final String unit;

  /// سعر الوحدة بالليرة السورية (price_per_unit — إجباري في الباك).
  final double pricePerUnit;

  /// الجرعة/التركيز (اختياري — dosage، للأدوية).
  final String? dosage;

  /// عدد الدفعات (batches_count — للقراءة فقط من الباك).
  final int batchesCount;

  /// الحد الأدنى — تحته تُعتبر "تنفد". (حساب UI؛ لا يرسله الباك.)
  final int minStock;

  /// تاريخ انتهاء الصلاحية (حساب UI؛ من أقرب دفعة عند توفّرها).
  final DateTime? expiryDate;

  /// ملاحظات إضافية (اختياري، UI فقط).
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
    String? nameEn,
    String? companyName,
    MaterialCategory? category,
    int? quantity,
    String? unit,
    double? pricePerUnit,
    String? dosage,
    int? batchesCount,
    int? minStock,
    DateTime? expiryDate,
    String? notes,
    // Sentinels لمسح الحقول الاختيارية بشكل صريح
    bool clearNameEn = false,
    bool clearDosage = false,
    bool clearExpiry = false,
    bool clearNotes = false,
  }) {
    return WarehouseMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: clearNameEn ? null : (nameEn ?? this.nameEn),
      companyName: companyName ?? this.companyName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      dosage: clearDosage ? null : (dosage ?? this.dosage),
      batchesCount: batchesCount ?? this.batchesCount,
      minStock: minStock ?? this.minStock,
      expiryDate: clearExpiry ? null : (expiryDate ?? this.expiryDate),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              SERIALIZATION
  // ────────────────────────────────────────────────────────────────────────

  /// جسم الحفظ (POST/PUT) — مطابق لـ StoreMaterialRequest في الباك.
  Map<String, dynamic> toJson() => {
        'name': name,
        if (nameEn != null) 'name_en': nameEn,
        'company_name': companyName,
        'price_per_unit': pricePerUnit,
        if (dosage != null) 'dosage': dosage,
        'unit': unit,
        'category': category.apiKey,
      };

  /// تكوين entity من JSON — مطابق لـ formatMaterial في الباك.
  ///
  /// يرمي [FormatException] إذا الـ category غير معروف.
  factory WarehouseMaterial.fromJson(Map<String, dynamic> json) {
    final categoryStr = (json['category'] as String?) ?? '';
    final category = materialCategoryFromString(categoryStr);
    if (category == null) {
      throw FormatException('Unknown material category: $categoryStr');
    }
    return WarehouseMaterial(
      id: json['id'].toString(),
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      companyName: (json['company_name'] as String?) ?? '',
      category: category,
      // الباك يرسل الأرقام أحياناً كنصوص (decimals: "250.50") ⇒ تحويل متسامح.
      quantity: _numToInt(json['total_stock'] ?? json['quantity']),
      unit: (json['unit'] as String?) ?? '',
      pricePerUnit: _numToDouble(json['price_per_unit']),
      dosage: json['dosage'] as String?,
      batchesCount: _numToInt(json['batches_count']),
    );
  }

  /// تحويل متسامح لـ int (يقبل num أو نصّاً أو null).
  static int _numToInt(Object? v) {
    if (v is num) return v.toInt();
    return double.tryParse('${v ?? ''}')?.toInt() ??
        int.tryParse('${v ?? ''}') ??
        0;
  }

  /// تحويل متسامح لـ double (يقبل num أو نصّاً أو null).
  static double _numToDouble(Object? v) {
    if (v is num) return v.toDouble();
    return double.tryParse('${v ?? ''}') ?? 0;
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
