// ════════════════════════════════════════════════════════════════════════════
// mock_warehouse_materials_repository.dart
//
// تنفيذ mock لـ [WarehouseMaterialsRepository] يستخدم بيانات ثابتة في الذاكرة.
//
// 🎯 الهدف:
//   نُحاكي عمليات CRUD على بيانات حقيقية بدون backend. مفيد لـ:
//   - Phase 4.3-4.7 (UI development)
//   - الاختبارات (golden tests, widget tests)
//   - Demo / portfolio
//
// 🔮 الانتقال لـ Real Repository:
//   عند ربط backend في Phase 6:
//   1. أنشئ RemoteWarehouseMaterialsRepository يستخدم Dio
//   2. حدّث injection_container.dart لتسجيل الـ remote بدل mock
//   3. الـ UI ما يحتاج تعديل
//
// تفاصيل تقنية:
//   - StreamController.broadcast لدعم multiple listeners
//   - عمليات async بـ delay صغير لمحاكاة latency واقعية
//   - الـ list محفوظة internally في الذاكرة (تضيع عند restart)
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import '../../domain/entities/material_category.dart';
import '../../domain/entities/warehouse_material.dart';
import '../../domain/repositories/warehouse_materials_repository.dart';

/// تنفيذ mock للـ repository — يخزّن البيانات في الذاكرة.
class MockWarehouseMaterialsRepository
    implements WarehouseMaterialsRepository {
  MockWarehouseMaterialsRepository() {
    _materials = List<WarehouseMaterial>.from(_seedData);
    _controller = StreamController<List<WarehouseMaterial>>.broadcast(
      onListen: () => _emit(),
    );
  }

  late List<WarehouseMaterial> _materials;
  late final StreamController<List<WarehouseMaterial>> _controller;

  /// محاكاة latency network (50-150ms).
  static const _mockLatency = Duration(milliseconds: 80);

  /// يبعث الحالة الحالية على الـ stream.
  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_materials));
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              CRUD
  // ────────────────────────────────────────────────────────────────────────

  @override
  Future<List<WarehouseMaterial>> getAll() async {
    await Future<void>.delayed(_mockLatency);
    return List.unmodifiable(_materials);
  }

  @override
  Future<WarehouseMaterial> getById(String id) async {
    await Future<void>.delayed(_mockLatency);
    final found = _materials.where((m) => m.id == id);
    if (found.isEmpty) {
      throw StateError('Material with id "$id" not found');
    }
    return found.first;
  }

  @override
  Future<WarehouseMaterial> create(WarehouseMaterial material) async {
    await Future<void>.delayed(_mockLatency);
    // إذا الـ id فارغ نولّد واحد جديد
    final id = material.id.isEmpty
        ? 'mat_${DateTime.now().millisecondsSinceEpoch}'
        : material.id;
    final created = material.copyWith(id: id);
    _materials.add(created);
    _emit();
    return created;
  }

  @override
  Future<WarehouseMaterial> update(WarehouseMaterial material) async {
    await Future<void>.delayed(_mockLatency);
    final index = _materials.indexWhere((m) => m.id == material.id);
    if (index < 0) {
      throw StateError('Material with id "${material.id}" not found');
    }
    _materials[index] = material;
    _emit();
    return material;
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(_mockLatency);
    _materials.removeWhere((m) => m.id == id);
    _emit();
  }

  @override
  Stream<List<WarehouseMaterial>> watchAll() => _controller.stream;

  /// يُستخدم في الاختبارات أو لإفراغ الموارد.
  void dispose() {
    _controller.close();
  }

  // ────────────────────────────────────────────────────────────────────────
  //                              SEED DATA
  // ────────────────────────────────────────────────────────────────────────

  /// 18 مادة تجريبية تغطّي الفئات والحالات المختلفة.
  ///
  /// ملاحظة: الأسماء بالعربية ثابتة لأنها تمثل أسماء مواد طبية حقيقية.
  /// في production تأتي من API بناءً على لغة المستخدم.
  static List<WarehouseMaterial> get _seedData {
    final now = DateTime.now();
    DateTime daysFromNow(int d) => now.add(Duration(days: d));

    return [
      // ── مستهلكات (consumables) ─────────────────────────────────────
      WarehouseMaterial(
        id: 'mat_001',
        name: 'قفازات لاتكس M',
        category: MaterialCategory.consumables,
        quantity: 340,
        unit: 'قطعة',
        minStock: 100,
        supplier: 'شركة الأمل الطبية',
        price: 250.0,
        expiryDate: daysFromNow(180),
      ),
      WarehouseMaterial(
        id: 'mat_002',
        name: 'أكواب بلاستيكية',
        category: MaterialCategory.consumables,
        quantity: 0,
        unit: 'كوب',
        minStock: 200,
        supplier: 'مؤسسة النهضة',
        price: 50.0,
      ),
      WarehouseMaterial(
        id: 'mat_003',
        name: 'خيط خياطة 3/0',
        category: MaterialCategory.consumables,
        quantity: 44,
        unit: 'بكرة',
        minStock: 20,
        supplier: 'شركة الأمل الطبية',
        price: 800.0,
        expiryDate: daysFromNow(540),
      ),
      WarehouseMaterial(
        id: 'mat_004',
        name: 'ماسكات طبية',
        category: MaterialCategory.consumables,
        quantity: 8,
        unit: 'علبة',
        minStock: 30,
        supplier: 'مؤسسة النهضة',
        price: 1200.0,
      ),
      WarehouseMaterial(
        id: 'mat_005',
        name: 'مناديل معقّمة',
        category: MaterialCategory.consumables,
        quantity: 120,
        unit: 'علبة',
        minStock: 50,
        price: 350.0,
      ),

      // ── أدوية (medicines) ───────────────────────────────────────────
      WarehouseMaterial(
        id: 'mat_006',
        name: 'حقن بنج موضعي',
        category: MaterialCategory.medicines,
        quantity: 56,
        unit: 'حقنة',
        minStock: 60,
        supplier: 'صيدلية الشام',
        price: 2500.0,
        expiryDate: daysFromNow(18),
      ),
      WarehouseMaterial(
        id: 'mat_007',
        name: 'مرهم تخدير سطحي',
        category: MaterialCategory.medicines,
        quantity: 12,
        unit: 'أنبوب',
        minStock: 8,
        supplier: 'صيدلية الشام',
        price: 1800.0,
        expiryDate: daysFromNow(23),
      ),
      WarehouseMaterial(
        id: 'mat_008',
        name: 'مضاد حيوي',
        category: MaterialCategory.medicines,
        quantity: 35,
        unit: 'علبة',
        minStock: 15,
        supplier: 'صيدلية الشام',
        price: 4200.0,
        expiryDate: daysFromNow(120),
      ),
      WarehouseMaterial(
        id: 'mat_009',
        name: 'مسكّن ألم',
        category: MaterialCategory.medicines,
        quantity: 80,
        unit: 'شريط',
        minStock: 25,
        price: 600.0,
        expiryDate: daysFromNow(365),
      ),

      // ── مواد طبية (medical) ────────────────────────────────────────
      WarehouseMaterial(
        id: 'mat_010',
        name: 'سيليكون طبع',
        category: MaterialCategory.medical,
        quantity: 15,
        unit: 'كيلو',
        minStock: 5,
        supplier: 'مختبرات الدلتا',
        price: 38000.0,
        expiryDate: daysFromNow(720),
      ),
      WarehouseMaterial(
        id: 'mat_011',
        name: 'محلول تطهير',
        category: MaterialCategory.medical,
        quantity: 8,
        unit: 'لتر',
        minStock: 10,
        supplier: 'شركة الأمل الطبية',
        price: 5500.0,
        expiryDate: daysFromNow(30),
      ),
      WarehouseMaterial(
        id: 'mat_012',
        name: 'جبص أسنان',
        category: MaterialCategory.medical,
        quantity: 25,
        unit: 'كيلو',
        minStock: 10,
        supplier: 'مختبرات الدلتا',
        price: 12000.0,
      ),
      WarehouseMaterial(
        id: 'mat_013',
        name: 'حشوة ضوئية',
        category: MaterialCategory.medical,
        quantity: 40,
        unit: 'محقن',
        minStock: 20,
        supplier: 'مختبرات الدلتا',
        price: 8500.0,
        expiryDate: daysFromNow(450),
      ),

      // ── معدات (equipment) ───────────────────────────────────────────
      WarehouseMaterial(
        id: 'mat_014',
        name: 'مرايا فحص',
        category: MaterialCategory.equipment,
        quantity: 22,
        unit: 'قطعة',
        minStock: 8,
        supplier: 'تجهيزات شام',
        price: 6500.0,
      ),
      WarehouseMaterial(
        id: 'mat_015',
        name: 'مسبار نخر',
        category: MaterialCategory.equipment,
        quantity: 15,
        unit: 'قطعة',
        minStock: 6,
        supplier: 'تجهيزات شام',
        price: 9500.0,
      ),
      WarehouseMaterial(
        id: 'mat_016',
        name: 'كماشة قلع',
        category: MaterialCategory.equipment,
        quantity: 6,
        unit: 'قطعة',
        minStock: 4,
        supplier: 'تجهيزات شام',
        price: 25000.0,
      ),
      WarehouseMaterial(
        id: 'mat_017',
        name: 'قاطعة جبص',
        category: MaterialCategory.equipment,
        quantity: 3,
        unit: 'قطعة',
        minStock: 2,
        price: 18000.0,
      ),
      WarehouseMaterial(
        id: 'mat_018',
        name: 'مولّد ضوء',
        category: MaterialCategory.equipment,
        quantity: 2,
        unit: 'جهاز',
        minStock: 1,
        supplier: 'تجهيزات شام',
        price: 320000.0,
      ),
    ];
  }
}
