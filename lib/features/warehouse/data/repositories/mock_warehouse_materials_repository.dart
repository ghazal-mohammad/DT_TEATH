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
    return const [
      // ── مواد العيادة (clinic) ───────────────────────────────────────
      WarehouseMaterial(
        id: 'mat_001',
        name: 'قفازات لاتكس M',
        nameEn: 'Latex Gloves M',
        companyName: 'شركة الأمل الطبية',
        category: MaterialCategory.clinic,
        quantity: 340,
        unit: 'قطعة',
        pricePerUnit: 250.0,
        minStock: 100,
        batchesCount: 3,
      ),
      WarehouseMaterial(
        id: 'mat_002',
        name: 'أكواب بلاستيكية',
        nameEn: 'Plastic Cups',
        companyName: 'مؤسسة النهضة',
        category: MaterialCategory.clinic,
        quantity: 0,
        unit: 'كوب',
        pricePerUnit: 50.0,
        minStock: 200,
      ),
      WarehouseMaterial(
        id: 'mat_003',
        name: 'خيط خياطة 3/0',
        nameEn: 'Suture 3/0',
        companyName: 'شركة الأمل الطبية',
        category: MaterialCategory.clinic,
        quantity: 44,
        unit: 'بكرة',
        pricePerUnit: 800.0,
        minStock: 20,
        batchesCount: 2,
      ),
      WarehouseMaterial(
        id: 'mat_004',
        name: 'ماسكات طبية',
        nameEn: 'Surgical Masks',
        companyName: 'مؤسسة النهضة',
        category: MaterialCategory.clinic,
        quantity: 8,
        unit: 'علبة',
        pricePerUnit: 1200.0,
        minStock: 30,
      ),
      WarehouseMaterial(
        id: 'mat_005',
        name: 'مناديل معقّمة',
        nameEn: 'Sterile Wipes',
        companyName: 'مؤسسة النهضة',
        category: MaterialCategory.clinic,
        quantity: 120,
        unit: 'علبة',
        pricePerUnit: 350.0,
        minStock: 50,
      ),
      WarehouseMaterial(
        id: 'mat_006',
        name: 'حقن بنج موضعي',
        nameEn: 'Local Anesthetic',
        companyName: 'صيدلية الشام',
        category: MaterialCategory.clinic,
        quantity: 56,
        unit: 'حقنة',
        pricePerUnit: 2500.0,
        dosage: '2% ليدوكائين',
        minStock: 60,
        batchesCount: 4,
      ),
      WarehouseMaterial(
        id: 'mat_007',
        name: 'مرهم تخدير سطحي',
        nameEn: 'Topical Anesthetic',
        companyName: 'صيدلية الشام',
        category: MaterialCategory.clinic,
        quantity: 12,
        unit: 'أنبوب',
        pricePerUnit: 1800.0,
        dosage: '20% بنزوكائين',
        minStock: 8,
      ),
      WarehouseMaterial(
        id: 'mat_008',
        name: 'مضاد حيوي',
        nameEn: 'Antibiotic',
        companyName: 'صيدلية الشام',
        category: MaterialCategory.clinic,
        quantity: 35,
        unit: 'علبة',
        pricePerUnit: 4200.0,
        dosage: '500 ملغ',
        minStock: 15,
      ),
      WarehouseMaterial(
        id: 'mat_009',
        name: 'مسكّن ألم',
        nameEn: 'Painkiller',
        companyName: 'صيدلية الشام',
        category: MaterialCategory.clinic,
        quantity: 80,
        unit: 'شريط',
        pricePerUnit: 600.0,
        dosage: '400 ملغ',
        minStock: 25,
      ),

      // ── مواد المخبر (lab) ──────────────────────────────────────────
      WarehouseMaterial(
        id: 'mat_010',
        name: 'سيليكون طبع',
        nameEn: 'Impression Silicone',
        companyName: 'مختبرات الدلتا',
        category: MaterialCategory.lab,
        quantity: 15,
        unit: 'كيلو',
        pricePerUnit: 38000.0,
        minStock: 5,
        batchesCount: 2,
      ),
      WarehouseMaterial(
        id: 'mat_012',
        name: 'جبص أسنان',
        nameEn: 'Dental Gypsum',
        companyName: 'مختبرات الدلتا',
        category: MaterialCategory.lab,
        quantity: 25,
        unit: 'كيلو',
        pricePerUnit: 12000.0,
        minStock: 10,
      ),
      WarehouseMaterial(
        id: 'mat_017',
        name: 'قاطعة جبص',
        nameEn: 'Gypsum Cutter',
        companyName: 'تجهيزات شام',
        category: MaterialCategory.lab,
        quantity: 3,
        unit: 'قطعة',
        pricePerUnit: 18000.0,
        minStock: 2,
      ),
      WarehouseMaterial(
        id: 'mat_018',
        name: 'مولّد ضوء',
        nameEn: 'Light Curing Unit',
        companyName: 'تجهيزات شام',
        category: MaterialCategory.lab,
        quantity: 2,
        unit: 'جهاز',
        pricePerUnit: 320000.0,
        minStock: 1,
      ),

      // ── مواد مشتركة (both) ─────────────────────────────────────────
      WarehouseMaterial(
        id: 'mat_011',
        name: 'محلول تطهير',
        nameEn: 'Disinfectant Solution',
        companyName: 'شركة الأمل الطبية',
        category: MaterialCategory.both,
        quantity: 8,
        unit: 'لتر',
        pricePerUnit: 5500.0,
        minStock: 10,
      ),
      WarehouseMaterial(
        id: 'mat_013',
        name: 'حشوة ضوئية',
        nameEn: 'Composite Filling',
        companyName: 'مختبرات الدلتا',
        category: MaterialCategory.both,
        quantity: 40,
        unit: 'محقن',
        pricePerUnit: 8500.0,
        minStock: 20,
        batchesCount: 3,
      ),
      WarehouseMaterial(
        id: 'mat_014',
        name: 'مرايا فحص',
        nameEn: 'Examination Mirrors',
        companyName: 'تجهيزات شام',
        category: MaterialCategory.both,
        quantity: 22,
        unit: 'قطعة',
        pricePerUnit: 6500.0,
        minStock: 8,
      ),
      WarehouseMaterial(
        id: 'mat_015',
        name: 'مسبار نخر',
        nameEn: 'Caries Explorer',
        companyName: 'تجهيزات شام',
        category: MaterialCategory.both,
        quantity: 15,
        unit: 'قطعة',
        pricePerUnit: 9500.0,
        minStock: 6,
      ),
      WarehouseMaterial(
        id: 'mat_016',
        name: 'كماشة قلع',
        nameEn: 'Extraction Forceps',
        companyName: 'تجهيزات شام',
        category: MaterialCategory.both,
        quantity: 6,
        unit: 'قطعة',
        pricePerUnit: 25000.0,
        minStock: 4,
      ),
    ];
  }
}
