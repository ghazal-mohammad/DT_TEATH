# فواتير طلب المواد بالمخبر — خطة التنفيذ

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** استبدال فورم "طلب مادة" أحادي المادة بميزة "فواتير" حقيقية متعددة المواد بحالتين (من مواد المستودع / من شركة خارجية)، مع ربط كامل وصحيح للـ 6 endpoints الموجودة أصلاً بالباك إند (بدون أي endpoint جديد)، وميزة طباعة للفاتورة.

**Architecture:** إعادة بناء بمكانها لملفات الميزة الموجودة (`lib/features/lab/**/*material_request*`, `lab_mat_request_*`) — نفس البنية الطبقية الحالية (Entity → Repository → Datasource → Cubit → UI). الكيان المسطّح (مادة واحدة) يُستبدل بكيان يحمل قائمتي عناصر (`items`/`newItems`) مطابق تماماً لشكل `WarehouseRequest` الشغّال أصلاً بجهة المستودع لنفس المورد الخلفي.

**Tech Stack:** Flutter/Dart، `dio` (HTTP)، `flutter_bloc` (Cubit)، `get_it` (DI)، `pdf`+`printing` (طباعة، موجودتان أصلاً بـ pubspec)، `mocktail`+`flutter_test`.

## Global Constraints

- **لا أي endpoint جديد بالباك إند.** الـ 6 المستخدَمة: `labManager/showAllWarehouseMaterials`, `labManager/showWarehouseMaterial/{id}`, `labManager/showAllMaterialRequests`, `labManager/addMaterialRequest`, `labManager/showMaterialRequest/{id}`, `labManager/deleteMaterialRequest/{id}`.
- **`addMaterialRequest` يُرسَل كـ JSON (Map مباشرة لـ Dio)** — ليس `FormData` — مطابقةً حرفية لتوثيق الـ API (`Content-Type: application/json`). `DioClient` الأساسي أصلاً بيضبط `Content-Type` تلقائياً حسب نوع الـ body (JSON لـ `Map`، multipart لـ `FormData`) — بلا حاجة لأي تعديل على `dio_client.dart`.
- **كل فاتورة نوع واحد بس** — إما `items[]` (من المستودع) أو `new_items[]` (من شركة)، أبداً الاثنين سوا بنفس الطلب. قرار معتمد من المستخدم.
- **مادتين+ من نفس الشركة = فاتورة واحدة.** حقل اسم الشركة يُدخَل مرة وحدة بالواجهة ويتكرّر تلقائياً بكل عنصر بجسم JSON (الباك إند طالبها حقلاً لكل عنصر).
- أسماء الكلاسات/الملفات بالكود **تبقى كما هي** (`MatRequest`, `LabMaterialRequestsRepository`, `lab_material_requests_*.dart`) — فقط النصوص المواجهة للمستخدم (l10n) تتغيّر لمصطلح "فاتورة".
- التطبيق RTL-first (عربي افتراضي) — كل الودجت الجديدة تتبع نفس اتفاقيات Directional الموجودة بالملفات المرجعية (`lab_mat_request_dialog.dart` القديم).
- `flutter analyze` يجب يبقى نظيف بعد كل مهمة (لا تحذيرات جديدة) — أي `import`/دالّة تصير بلا استخدام يجب حذفها بنفس المهمة.

---

## File Structure

| الملف | التعديل |
|---|---|
| `lib/features/lab/domain/entities/lab_material_request.dart` | إعادة بناء — `MatRequestItem`/`MatRequestNewItem` جديدتان، `MatRequest` يحمل قوائم بدل حقول مسطّحة |
| `lib/features/lab/domain/repositories/lab_material_requests_repository.dart` | تعديل — `addRequest` تُستبدل بـ `addRequestFromWarehouse`/`addRequestFromCompany`، إضافة `getOne`/`getWarehouseMaterial` |
| `lib/features/lab/data/datasources/lab_material_requests_remote_datasource.dart` | تعديل — `create` يرسل JSON، إضافة `getOne`/`getWarehouseMaterial` |
| `lib/features/lab/data/repositories/remote_lab_material_requests_repository.dart` | إعادة بناء — `_fromJson` كامل (لا قصّ)، الدوال الجديدة |
| `lib/features/lab/presentation/bloc/lab_material_requests_cubit.dart` | تعديل — دوال الإنشاء الجديدة، معالجة فشل الكتالوج |
| `lib/features/lab/presentation/bloc/lab_material_requests_state.dart` | تعديل — `catalogError`، تحديث `filtered` |
| `lib/core/l10n/arb/app_ar.arb` + `app_en.arb` | تعديل — مفاتيح جديدة + تحديث نصوص موجودة |
| `lib/features/lab/presentation/widgets/material_requests/lab_mat_request_card.dart` | إعادة بناء — عرض عدد المواد + نوع الفاتورة، بلا حقول مسطّحة |
| `lib/features/lab/presentation/widgets/material_requests/lab_invoice_type_chooser_dialog.dart` | **جديد** — خطوة اختيار النوع |
| `lib/features/lab/presentation/widgets/material_requests/lab_invoice_from_warehouse_dialog.dart` | **جديد** — فورم متعدد المواد من المستودع |
| `lib/features/lab/presentation/widgets/material_requests/lab_invoice_from_company_dialog.dart` | **جديد** — فورم متعدد المواد من شركة |
| `lib/features/lab/presentation/widgets/material_requests/lab_invoice_details_dialog.dart` | **جديد** — عرض كل عناصر فاتورة |
| `lib/features/lab/presentation/widgets/material_requests/lab_invoice_printer.dart` | **جديد** — توليد/طباعة PDF |
| `lib/features/lab/presentation/widgets/material_requests/lab_mat_request_dialog.dart` | **يُحذف** — استُبدل بالثلاثة الجديدة أعلاه |
| `lib/features/lab/presentation/pages/lab_material_requests_page.dart` | تعديل — ربط الفورمات الجديدة، زر الطباعة |
| `test/state/lab_material_requests_filter_test.dart` | إعادة كتابة كاملة (الكيان تغيّر جذرياً) |
| عدّة ملفات اختبار جديدة | حسب كل مهمة أدناه |

---

### Task 1: الكيانات (Entities)

**Files:**
- Modify: `lib/features/lab/domain/entities/lab_material_request.dart`
- Test: `test/entities/lab_material_request_test.dart` (جديد)

**Interfaces:**
- Produces: `MatRequestStatus` (بلا تغيير)، `MatRequestItem{id, materialName, quantityRequested, notes}`، `MatRequestNewItem{id, materialName, quantity, unit, companyName, reason}`، `MatRequest{id, status, requestedBy, requesterType, date, notes, items, newItems, itemsCount, isFromWarehouse, isFromCompany}`.

- [ ] **Step 1: كتابة الاختبار (سيفشل لأن الكلاسات الجديدة غير موجودة)**

أنشئ `test/entities/lab_material_request_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';

void main() {
  test('MatRequest بمواد مستودع متعددة — يحمل كل العناصر بلا قصّ', () {
    final req = MatRequest(
      id: '1',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      notes: 'طلب شهري',
      items: const [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: const [],
    );

    expect(req.items.length, 2);
    expect(req.itemsCount, 2);
    expect(req.isFromWarehouse, isTrue);
    expect(req.isFromCompany, isFalse);
  });

  test('MatRequest بمواد شركة جديدة متعددة', () {
    final req = MatRequest(
      id: '2',
      status: MatRequestStatus.newRequest,
      requestedBy: 'سارة',
      requesterType: 'lab',
      date: '2026-08-19',
      items: const [],
      newItems: const [
        MatRequestNewItem(
          id: '1',
          materialName: 'صمغ طبي خاص',
          quantity: 3,
          unit: 'علبة',
          companyName: 'شركة دنتال سوريا',
          reason: 'نحتاج هذه المادة',
        ),
        MatRequestNewItem(
          id: '2',
          materialName: 'قفازات خاصة',
          quantity: 20,
          unit: 'علبة',
          companyName: 'شركة دنتال سوريا',
        ),
      ],
    );

    expect(req.newItems.length, 2);
    expect(req.itemsCount, 2);
    expect(req.isFromCompany, isTrue);
    expect(req.isFromWarehouse, isFalse);
    expect(req.newItems.every((i) => i.companyName == 'شركة دنتال سوريا'), isTrue);
  });
}
```

- [ ] **Step 2: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/entities/lab_material_request_test.dart`
Expected: FAIL — `MatRequestItem`/`MatRequestNewItem` غير معرَّفتين، و`MatRequest` توقيعها القديم مختلف.

- [ ] **Step 3: إعادة كتابة الملف بالكامل**

استبدل محتوى `lib/features/lab/domain/entities/lab_material_request.dart` بالكامل:

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_material_request.dart
//
// كيان domain لفاتورة طلب مواد أرسلها المخبر للمستودع (منظور المخبر). نقي
// (pure Dart). فاتورة واحدة تحمل عدّة عناصر — إما items[] (مواد من كتالوج
// المستودع) أو newItems[] (مواد جديدة من شركة خارجية)، أبداً الاثنين سوا
// (قرار معتمد). يطابق تماماً شكل WarehouseRequest بجهة المستودع لنفس المورد
// الخلفي (MaterialRequestResource).
// ════════════════════════════════════════════════════════════════════════════

// القيم الخمس تطابق enum الحالة الفعلي بالباك: new/pending/completed/
// rejected/cancelled (تحقّق 2026-08-14) — كل حالة باك تُميَّز بحالة فرونت
// مستقلة (بلا fallback مشترك) كي تُعرض شارة مختلفة لكل منها.
enum MatRequestStatus { newRequest, inProgress, delivered, unavailable, cancelled }

/// عنصر مادة من كتالوج المستودع ضمن الفاتورة (مسار items[] بالباك).
class MatRequestItem {
  const MatRequestItem({
    required this.id,
    required this.materialName,
    required this.quantityRequested,
    this.notes,
  });

  final String id;
  final String materialName;
  final int quantityRequested;
  final String? notes;
}

/// عنصر مادة جديدة من شركة خارجية ضمن الفاتورة (مسار new_items[] بالباك).
class MatRequestNewItem {
  const MatRequestNewItem({
    required this.id,
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.companyName,
    this.reason,
  });

  final String id;
  final String materialName;
  final int quantity;
  final String unit;
  final String? companyName;
  final String? reason;
}

/// فاتورة طلب مواد كاملة أرسلها المخبر للمستودع.
class MatRequest {
  const MatRequest({
    required this.id,
    required this.status,
    required this.requestedBy,
    required this.requesterType,
    required this.date,
    required this.items,
    required this.newItems,
    this.notes,
  });

  final String id;
  final MatRequestStatus status;
  final String requestedBy;
  final String requesterType;
  final String date;

  /// ملاحظة عامة على الفاتورة (top-level notes بجسم الطلب/الرد).
  final String? notes;

  /// مواد من كتالوج المستودع — فارغة لفاتورة "من شركة".
  final List<MatRequestItem> items;

  /// مواد جديدة من شركة خارجية — فارغة لفاتورة "من مستودع".
  final List<MatRequestNewItem> newItems;

  int get itemsCount => items.length + newItems.length;
  bool get isFromWarehouse => items.isNotEmpty;
  bool get isFromCompany => newItems.isNotEmpty;
}
```

- [ ] **Step 4: تشغيل الاختبار والتأكد من النجاح**

Run: `flutter test test/entities/lab_material_request_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lab/domain/entities/lab_material_request.dart test/entities/lab_material_request_test.dart
git commit -m "refactor(lab): أعد بناء كيان MatRequest ليحمل قوائم عناصر الفاتورة كاملة"
```

**ملاحظة للمهام التالية:** هذا التعديل يكسر التصريف (compile) بملفات أخرى تعتمد الحقول القديمة (`.material`, `.quantity`, `.unit`, `.company`, `.reason`, `.labOrderId`, `.note`, `.labOrderId`) — هذا متوقّع ومقصود؛ المهام 2-9 تُصلح كل هالملفات بالتتابع. لا تُشغّل `flutter analyze`/`flutter test` على كامل المشروع لحد ما تخلص كل المهام (بس على الملفات المستهدفة بكل مهمة) — Task الأخيرة (11) بتتحقق من كل شي سوا.

---

### Task 2: عقد الـ Repository + الـ Datasource

**Files:**
- Modify: `lib/features/lab/domain/repositories/lab_material_requests_repository.dart`
- Modify: `lib/features/lab/data/datasources/lab_material_requests_remote_datasource.dart`
- Test: `test/features/lab/data/lab_material_requests_remote_datasource_test.dart` (جديد)

**Interfaces:**
- Consumes: `MatRequest` من Task 1 (بس بالتوقيع، بلا استهلاك فعلي بهالملفين).
- Produces: `LabMaterialRequestsRepository` بتوقيعه الجديد الكامل (تستهلكه Task 3 و6 و9). `LabMaterialRequestsRemoteDataSource.create(Map)` بلا `FormData`، + `getOne(Object id)`, `getWarehouseMaterial(Object id)`.

- [ ] **Step 1: تعديل عقد الـ Repository**

استبدل محتوى `lib/features/lab/domain/repositories/lab_material_requests_repository.dart` بالكامل:

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_repository.dart
//
// عقد الوصول لفواتير طلب المواد التي يرسلها المخبر للمستودع.
// ════════════════════════════════════════════════════════════════════════════

import '../entities/lab_material_request.dart';
import '../entities/warehouse_material_ref.dart';

/// عقد الوصول لفواتير طلب المواد.
abstract class LabMaterialRequestsRepository {
  /// آخر قائمة مُحمَّلة (للعرض الفوري عند إعادة زيارة الصفحة)، أو null إن لم
  /// تُحمَّل بعد. يُمكّن نمط stale-while-revalidate في الـ Cubit.
  List<MatRequest>? get cached;

  /// يجلب كل الفواتير.
  Future<List<MatRequest>> getAll();

  /// يجلب فاتورة واحدة بالمعرّف (showMaterialRequest/{id}).
  Future<MatRequest> getOne(String id);

  /// يجلب كتالوج مواد المستودع (لاختيار مواد فاتورة "من المستودع").
  Future<List<WarehouseMaterialRef>> getWarehouseMaterials();

  /// يجلب تفاصيل مادة واحدة من كتالوج المستودع (showWarehouseMaterial/{id}).
  Future<WarehouseMaterialRef> getWarehouseMaterial(int id);

  /// ينشئ فاتورة من مواد كتالوج المستودع (مسار items[] بالباك).
  Future<void> addRequestFromWarehouse({
    required List<({int materialId, int quantity, String? notes})> items,
    String? notes,
  });

  /// ينشئ فاتورة من مواد جديدة من شركة خارجية (مسار new_items[] بالباك).
  /// [companyName] يُكتب مرة وحدة هون ويتكرّر تلقائياً بكل عنصر بجسم الطلب.
  Future<void> addRequestFromCompany({
    required String companyName,
    required List<({String materialName, int quantity, String unit, String? reason})> items,
    String? notes,
  });

  /// يحذف فاتورة بالمعرّف.
  Future<void> delete(String id);

  /// stream للفواتير — لتحديث الـ UI تلقائياً.
  Stream<List<MatRequest>> watchAll();
}
```

- [ ] **Step 2: كتابة اختبار الـ Datasource (سيفشل)**

`Dio` (نسخة 5.8.0 المستخدمة بالمشروع) صنف `abstract class` — قابل للـ mock مباشرة بـ `mocktail` (الموجودة أصلاً بـ `pubspec.yaml`) بلا حاجة لأي حزمة HTTP-mock إضافية.

أنشئ `test/features/lab/data/lab_material_requests_remote_datasource_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/network/endpoints.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_material_requests_remote_datasource.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late LabMaterialRequestsRemoteDataSource ds;

  setUp(() {
    dio = _MockDio();
    ds = LabMaterialRequestsRemoteDataSource(dio);
  });

  test('create يرسل الجسم كـ Map مباشرة لـ Dio.post (بلا FormData)', () async {
    when(() => dio.post<dynamic>(
          ApiEndpoints.labManagerAddMaterialRequest,
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.labManagerAddMaterialRequest),
          data: {'data': {}},
          statusCode: 200,
        ));

    final body = {
      'items': [
        {'material_id': 1, 'quantity_requested': 10},
      ],
    };
    await ds.create(body);

    final captured = verify(() => dio.post<dynamic>(
          ApiEndpoints.labManagerAddMaterialRequest,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, isA<Map<String, dynamic>>());
    expect(captured, isNot(isA<FormData>()));
    expect((captured as Map)['items'], body['items']);
  });

  test('getOne يستدعي showMaterialRequest/{id}', () async {
    when(() => dio.get<dynamic>(ApiEndpoints.labManagerShowMaterialRequest(7))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.labManagerShowMaterialRequest(7)),
        data: {'data': {'id': 7}},
        statusCode: 200,
      ),
    );
    final res = await ds.getOne(7);
    expect(res['id'], 7);
  });

  test('getWarehouseMaterial يستدعي showWarehouseMaterial/{id}', () async {
    when(() => dio.get<dynamic>(ApiEndpoints.labManagerShowWarehouseMaterial(3))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.labManagerShowWarehouseMaterial(3)),
        data: {'data': {'id': 3, 'material_id': 3}},
        statusCode: 200,
      ),
    );
    final res = await ds.getWarehouseMaterial(3);
    expect(res['material_id'], 3);
  });
}
```

- [ ] **Step 3: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/features/lab/data/lab_material_requests_remote_datasource_test.dart`
Expected: FAIL — `getOne`/`getWarehouseMaterial` غير معرَّفتين بعد، و`create` لسا FormData.

- [ ] **Step 4: تعديل الـ Datasource**

استبدل محتوى `lib/features/lab/data/datasources/lab_material_requests_remote_datasource.dart` بالكامل:

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_remote_datasource.dart
//
// مصدر بيانات فواتير طلب المواد البعيد (منظور المخبر) — يتصل مباشرة بـ Dio.
// التوكن يُضاف تلقائياً عبر interceptor. يرجّع JSON خام؛ التحويل في الـ repository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';

class LabMaterialRequestsRemoteDataSource {
  LabMaterialRequestsRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/labManager/showAllMaterialRequests → فواتير المخبر الخام.
  Future<List<Map<String, dynamic>>> getAll() async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowAllMaterialRequests);
    return _asList(res.data);
  }

  /// GET /api/labManager/showMaterialRequest/{id} → فاتورة واحدة خام.
  Future<Map<String, dynamic>> getOne(Object id) async {
    final res =
        await _dio.get<dynamic>(ApiEndpoints.labManagerShowMaterialRequest(id));
    return _asMap(res.data);
  }

  /// POST /api/labManager/addMaterialRequest — إنشاء فاتورة.
  /// [body] يُرسَل كـ JSON خام (Map) — Dio يضبط Content-Type: application/json
  /// تلقائياً لأي body من نوع Map (راجع DioClient.build)، مطابقةً حرفية
  /// لتوثيق الـ API (خلافاً للسلوك القديم الذي كان يرسل FormData).
  Future<void> create(Map<String, dynamic> body) async {
    await _dio.post<dynamic>(
      ApiEndpoints.labManagerAddMaterialRequest,
      data: body,
    );
  }

  /// POST /api/labManager/deleteMaterialRequest/{id} → حذف فاتورة.
  Future<void> delete(Object id) async {
    await _dio
        .post<dynamic>(ApiEndpoints.labManagerDeleteMaterialRequest(id));
  }

  /// GET /api/labManager/showAllWarehouseMaterials → كتالوج مواد المستودع الخام.
  Future<List<Map<String, dynamic>>> getWarehouseMaterials() async {
    final res = await _dio
        .get<dynamic>(ApiEndpoints.labManagerShowAllWarehouseMaterials);
    return _asList(res.data);
  }

  /// GET /api/labManager/showWarehouseMaterial/{id} → مادة مستودع واحدة خام.
  Future<Map<String, dynamic>> getWarehouseMaterial(Object id) async {
    final res = await _dio
        .get<dynamic>(ApiEndpoints.labManagerShowWarehouseMaterial(id));
    return _asMap(res.data);
  }

  List<Map<String, dynamic>> _asList(Object? data) {
    final list = (data is Map) ? data['data'] : null;
    if (list is! List) return <Map<String, dynamic>>[];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _asMap(Object? data) {
    final map = (data is Map) ? data['data'] : null;
    return map is Map ? Map<String, dynamic>.from(map) : <String, dynamic>{};
  }
}
```

- [ ] **Step 5: تشغيل الاختبار والتأكد من النجاح**

Run: `flutter test test/features/lab/data/lab_material_requests_remote_datasource_test.dart`
Expected: PASS (الاختبارات الثلاثة)

- [ ] **Step 6: Commit**

```bash
git add lib/features/lab/domain/repositories/lab_material_requests_repository.dart lib/features/lab/data/datasources/lab_material_requests_remote_datasource.dart test/features/lab/data/lab_material_requests_remote_datasource_test.dart
git commit -m "refactor(lab): عقد Repository جديد لفواتير متعددة المواد + Datasource يرسل JSON بدل FormData"
```

---

### Task 3: تنفيذ الـ Repository (Remote)

**Files:**
- Modify: `lib/features/lab/data/repositories/remote_lab_material_requests_repository.dart`
- Test: `test/features/lab/data/remote_lab_material_requests_repository_test.dart` (جديد)

**Interfaces:**
- Consumes: `MatRequest`/`MatRequestItem`/`MatRequestNewItem` (Task 1)، `LabMaterialRequestsRepository`/`LabMaterialRequestsRemoteDataSource` (Task 2).
- Produces: `RemoteLabMaterialRequestsRepository` كامل التنفيذ — تستهلكه Task 4 (الـ Cubit) عبر DI الموجود أصلاً بـ `injection_container.dart` (بلا تعديل هناك — نفس التوقيع `RemoteLabMaterialRequestsRepository(dataSource, persistentCache)`).

- [ ] **Step 1: كتابة الاختبار (سيفشل)**

أنشئ `test/features/lab/data/remote_lab_material_requests_repository_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/offline/persistent_cache.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_material_requests_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/repositories/remote_lab_material_requests_repository.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';

class _MockDataSource extends Mock implements LabMaterialRequestsRemoteDataSource {}
class _MockCache extends Mock implements PersistentCache {}

void main() {
  late _MockDataSource ds;
  late _MockCache cache;
  late RemoteLabMaterialRequestsRepository repo;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    ds = _MockDataSource();
    cache = _MockCache();
    when(() => cache.read(any())).thenAnswer((_) async => null);
    when(() => cache.write(any(), any())).thenAnswer((_) async {});
    repo = RemoteLabMaterialRequestsRepository(ds, cache);
  });

  test('getAll يحوّل فاتورة بعدة items[] كاملةً — بلا قصّ لأول عنصر', () async {
    when(() => ds.getAll()).thenAnswer((_) async => [
          {
            'id': 1,
            'status': 'new',
            'requester': {'name': 'أحمد'},
            'requester_type': 'lab',
            'notes': 'طلب شهري',
            'items': [
              {'id': 1, 'material': 'زركون', 'quantity_requested': 10, 'notes': 'ملاحظة'},
              {'id': 2, 'material': 'جبس', 'quantity_requested': 5},
            ],
            'new_items': [],
            'created_at': '2026-08-19 10:00:00',
          },
        ]);

    final result = await repo.getAll();

    expect(result, hasLength(1));
    final req = result.first;
    expect(req.items, hasLength(2));
    expect(req.items[0].materialName, 'زركون');
    expect(req.items[0].quantityRequested, 10);
    expect(req.items[1].materialName, 'جبس');
    expect(req.requestedBy, 'أحمد');
    expect(req.date, '2026-08-19');
    expect(req.status, MatRequestStatus.newRequest);
  });

  test('getAll يحوّل فاتورة بعدة new_items[] كاملةً', () async {
    when(() => ds.getAll()).thenAnswer((_) async => [
          {
            'id': 2,
            'status': 'pending',
            'requester': {'name': 'سارة'},
            'requester_type': 'lab',
            'items': [],
            'new_items': [
              {'id': 1, 'material_name': 'صمغ', 'quantity': 3, 'unit': 'علبة', 'company_name': 'دنتال سوريا'},
              {'id': 2, 'material_name': 'قفازات', 'quantity': 20, 'unit': 'علبة', 'company_name': 'دنتال سوريا'},
            ],
            'created_at': '2026-08-19 11:00:00',
          },
        ]);

    final result = await repo.getAll();

    expect(result.first.newItems, hasLength(2));
    expect(result.first.status, MatRequestStatus.inProgress);
    expect(result.first.newItems.every((i) => i.companyName == 'دنتال سوريا'), isTrue);
  });

  test('addRequestFromWarehouse يبني items[] بمفاتيح صحيحة ويرسل JSON', () async {
    when(() => ds.create(any())).thenAnswer((_) async {});
    when(() => ds.getAll()).thenAnswer((_) async => []);

    await repo.addRequestFromWarehouse(
      items: const [(materialId: 1, quantity: 10, notes: null), (materialId: 2, quantity: 5, notes: 'مستعجل')],
      notes: 'طلب شهري',
    );

    final captured = verify(() => ds.create(captureAny())).captured.single as Map<String, dynamic>;
    expect(captured['notes'], 'طلب شهري');
    expect(captured['items'], [
      {'material_id': 1, 'quantity_requested': 10},
      {'material_id': 2, 'quantity_requested': 5, 'notes': 'مستعجل'},
    ]);
    expect(captured.containsKey('new_items'), isFalse);
  });

  test('addRequestFromCompany يكرّر اسم الشركة بكل عنصر', () async {
    when(() => ds.create(any())).thenAnswer((_) async {});
    when(() => ds.getAll()).thenAnswer((_) async => []);

    await repo.addRequestFromCompany(
      companyName: 'شركة دنتال سوريا',
      items: const [
        (materialName: 'صمغ', quantity: 3, unit: 'علبة', reason: 'نحتاجها'),
        (materialName: 'قفازات', quantity: 20, unit: 'علبة', reason: null),
      ],
    );

    final captured = verify(() => ds.create(captureAny())).captured.single as Map<String, dynamic>;
    final newItems = captured['new_items'] as List;
    expect(newItems, hasLength(2));
    expect(newItems.every((i) => (i as Map)['company_name'] == 'شركة دنتال سوريا'), isTrue);
    expect((newItems[0] as Map)['reason'], 'نحتاجها');
    expect((newItems[1] as Map).containsKey('reason'), isFalse);
    expect(captured.containsKey('items'), isFalse);
  });

  test('getOne يحوّل فاتورة واحدة كاملة', () async {
    when(() => ds.getOne(5)).thenAnswer((_) async => {
          'id': 5,
          'status': 'completed',
          'requester': {'name': 'أحمد'},
          'requester_type': 'lab',
          'items': [
            {'id': 1, 'material': 'زركون', 'quantity_requested': 10},
          ],
          'new_items': [],
          'created_at': '2026-08-19 09:00:00',
        });

    final req = await repo.getOne('5');
    expect(req.id, '5');
    expect(req.status, MatRequestStatus.delivered);
    expect(req.items.single.materialName, 'زركون');
  });

  test('getWarehouseMaterial يحوّل مادة واحدة', () async {
    when(() => ds.getWarehouseMaterial(3)).thenAnswer((_) async => {
          'material_id': 3,
          'material': 'زركون',
          'unit': 'كيلو',
        });

    final ref = await repo.getWarehouseMaterial(3);
    expect(ref.materialId, 3);
    expect(ref.name, 'زركون');
    expect(ref.unit, 'كيلو');
  });
}
```

- [ ] **Step 2: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/features/lab/data/remote_lab_material_requests_repository_test.dart`
Expected: FAIL — الدوال الجديدة غير موجودة، `_fromJson` القديمة بتقصّ العناصر.

- [ ] **Step 3: إعادة كتابة الملف**

استبدل محتوى `lib/features/lab/data/repositories/remote_lab_material_requests_repository.dart` بالكامل:

```dart
// ════════════════════════════════════════════════════════════════════════════
// remote_lab_material_requests_repository.dart
//
// تنفيذ Remote لـ [LabMaterialRequestsRepository] — يجلب/ينشئ فواتير طلب مواد
// عبر [LabMaterialRequestsRemoteDataSource].
//
// مطابقة العقد مع الباك (نفس مورد MaterialRequestResource المستخدم بجهة
// المستودع warehouseManager — تحقّق عبر warehouse_request.dart الشغّال):
//   {id, status(new/pending/completed/rejected/cancelled), requester:{name},
//    requester_type, notes,
//    items:[{id, material, quantity_requested, notes}],
//    new_items:[{id, material_name, quantity, unit, company_name, reason}],
//    created_at}.
//   الإرسال: items[] لمواد كتالوج المستودع (material_id)، new_items[] لمواد
//   شركة خارجية (material_name) — جسم JSON خام (Map)، ليس FormData.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/offline/cached_list_repository.dart';
import '../../../../core/offline/persistent_cache.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/entities/warehouse_material_ref.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import '../../../../core/session/session_cache_registry.dart';
import '../datasources/lab_material_requests_remote_datasource.dart';

class RemoteLabMaterialRequestsRepository
    with PersistentListCache
    implements LabMaterialRequestsRepository {
  RemoteLabMaterialRequestsRepository(this._remote, this.persistentCache) {
    _controller = StreamController<List<MatRequest>>.broadcast(onListen: _emit);
    SessionCacheRegistry.instance.register(_clearCache);
  }

  @override
  final PersistentCache persistentCache;

  @override
  String get cacheResource => 'lab_material_requests';

  /// يمسح كاش الجلسة (يُستدعى عند تسجيل الخروج) — منعًا لتسريب بيانات مستخدم لآخر.
  void _clearCache() {
    _cache = const [];
    _loaded = false;
    _emit();
  }

  final LabMaterialRequestsRemoteDataSource _remote;
  late final StreamController<List<MatRequest>> _controller;
  List<MatRequest> _cache = const [];

  /// هل جُلبت القائمة مرة على الأقل؟ (لتمييز "لم يُحمَّل" عن "مُحمَّل وفارغ").
  bool _loaded = false;

  @override
  List<MatRequest>? get cached => _loaded ? List.unmodifiable(_cache) : null;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_cache));
    }
  }

  @override
  Future<List<MatRequest>> getAll() async {
    try {
      final raw = await _remote.getAll();
      _cache = raw.map(_fromJson).toList();
      _loaded = true;
      await saveCachedRows(raw);
      _emit();
      return List.unmodifiable(_cache);
    } on DioException catch (e) {
      final failure = _mapDioError(e);
      if (failure is NetworkFailure || failure is TimeoutFailure) {
        final cached = await loadCachedRows();
        if (cached != null) {
          _cache = cached.map(_fromJson).toList();
          _loaded = true;
          _emit();
          return List.unmodifiable(_cache);
        }
      }
      throw failure;
    }
  }

  @override
  Future<MatRequest> getOne(String id) async {
    try {
      final raw = await _remote.getOne(id);
      return _fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<WarehouseMaterialRef>> getWarehouseMaterials() async {
    try {
      final raw = await _remote.getWarehouseMaterials();
      return raw.map(_refFromJson).where((m) => m.materialId > 0 && m.name.isNotEmpty).toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<WarehouseMaterialRef> getWarehouseMaterial(int id) async {
    try {
      final raw = await _remote.getWarehouseMaterial(id);
      return _refFromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  WarehouseMaterialRef _refFromJson(Map<String, dynamic> m) => WarehouseMaterialRef(
        materialId: int.tryParse('${m['material_id'] ?? ''}') ?? 0,
        name: '${m['material'] ?? ''}'.trim(),
        unit: '${m['unit'] ?? ''}'.trim(),
      );

  @override
  Future<void> addRequestFromWarehouse({
    required List<({int materialId, int quantity, String? notes})> items,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'items': [
          for (final it in items)
            {
              'material_id': it.materialId,
              'quantity_requested': it.quantity,
              if (it.notes != null && it.notes!.isNotEmpty) 'notes': it.notes,
            },
        ],
      };
      await _remote.create(body);
      await getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> addRequestFromCompany({
    required String companyName,
    required List<({String materialName, int quantity, String unit, String? reason})> items,
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'new_items': [
          for (final it in items)
            {
              'material_name': it.materialName,
              'quantity': it.quantity,
              'unit': it.unit,
              'company_name': companyName,
              if (it.reason != null && it.reason!.isNotEmpty) 'reason': it.reason,
            },
        ],
      };
      await _remote.create(body);
      await getAll();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remote.delete(id);
      _cache = _cache.where((r) => r.id != id).toList(growable: false);
      _emit();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Stream<List<MatRequest>> watchAll() => _controller.stream;

  // ── تحويل JSON → entity ──────────────────────────────────────────────────

  MatRequest _fromJson(Map<String, dynamic> j) {
    final requester = j['requester'] is Map
        ? Map<String, dynamic>.from(j['requester'] as Map)
        : const <String, dynamic>{};

    return MatRequest(
      id: '${j['id'] ?? ''}',
      status: _mapStatus('${j['status'] ?? ''}'),
      requestedBy: (requester['name'] ?? '').toString(),
      requesterType: (j['requester_type'] ?? '').toString(),
      date: '${j['created_at'] ?? ''}'.split(' ').first,
      notes: (j['notes']?.toString().isEmpty ?? true) ? null : j['notes'].toString(),
      items: _asList(j['items']).map(_itemFromJson).toList(growable: false),
      newItems: _asList(j['new_items']).map(_newItemFromJson).toList(growable: false),
    );
  }

  MatRequestItem _itemFromJson(Map<String, dynamic> j) => MatRequestItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material'] ?? '').toString(),
        quantityRequested: _toInt(j['quantity_requested']),
        notes: (j['notes']?.toString().isEmpty ?? true) ? null : j['notes'].toString(),
      );

  MatRequestNewItem _newItemFromJson(Map<String, dynamic> j) => MatRequestNewItem(
        id: '${j['id'] ?? ''}',
        materialName: (j['material_name'] ?? '').toString(),
        quantity: _toInt(j['quantity']),
        unit: (j['unit'] ?? '').toString(),
        companyName: _nn(j['company_name']),
        reason: _nn(j['reason']),
      );

  static List<Map<String, dynamic>> _asList(Object? v) => (v is List)
      ? v.whereType<Map<dynamic, dynamic>>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];

  static int _toInt(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

  static String? _nn(Object? v) => (v == null || v.toString().isEmpty) ? null : v.toString();

  /// خريطة حالة الباك → حالة الفرونت. القيم الحقيقية بالباك (enum
  /// material_requests.status، تحقّق مباشر من migration الباك بتاريخ
  /// 2026-08-14 بعد إعادة تسمية الباك لـ in_progress ⇒ pending):
  /// new | pending | completed | rejected | cancelled.
  MatRequestStatus _mapStatus(String s) {
    switch (s) {
      case 'pending':
        return MatRequestStatus.inProgress;
      case 'completed':
        return MatRequestStatus.delivered;
      case 'rejected':
        return MatRequestStatus.unavailable;
      case 'cancelled':
        return MatRequestStatus.cancelled;
      case 'new':
      default:
        return MatRequestStatus.newRequest;
    }
  }

  Failure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    if (status == null) return const NetworkFailure();

    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ServerFailure(data['message'] as String, code: '$status');
    }
    return ServerFailure.fromStatusCode(status);
  }
}
```

- [ ] **Step 4: تشغيل الاختبار والتأكد من النجاح**

Run: `flutter test test/features/lab/data/remote_lab_material_requests_repository_test.dart`
Expected: PASS (كل الاختبارات السبعة)

- [ ] **Step 5: Commit**

```bash
git add lib/features/lab/data/repositories/remote_lab_material_requests_repository.dart test/features/lab/data/remote_lab_material_requests_repository_test.dart
git commit -m "refactor(lab): Repository يقرأ كل عناصر الفاتورة (بلا قصّ) ويبني items[]/new_items[] الصحيحة"
```

---

### Task 4: الـ Cubit + الـ State

**Files:**
- Modify: `lib/features/lab/presentation/bloc/lab_material_requests_state.dart`
- Modify: `lib/features/lab/presentation/bloc/lab_material_requests_cubit.dart`
- Modify: `test/state/lab_material_requests_filter_test.dart` (إعادة كتابة كاملة)
- Test: `test/features/lab/presentation/lab_material_requests_cubit_test.dart` (جديد)

**Interfaces:**
- Consumes: `LabMaterialRequestsRepository` (Task 2/3)، `MatRequest`/`MatRequestItem`/`MatRequestNewItem` (Task 1).
- Produces: `LabMaterialRequestsCubit.addRequestFromWarehouse(...)`/`.addRequestFromCompany(...)` (`Future<bool>`)، `LabMaterialRequestsState.catalogError` — تستهلكهم Task 7/8/9 (الفورمات والصفحة).

- [ ] **Step 1: تعديل الـ State**

بملف `lib/features/lab/presentation/bloc/lab_material_requests_state.dart`، استبدل الملف بالكامل:

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_state.dart
//
// State لـ LabMaterialRequestsCubit: مرحلة التحميل + الفواتير + الفلتر النشط.
// القائمة المُفلترة computed.
// ════════════════════════════════════════════════════════════════════════════

import '../../domain/entities/lab_material_request.dart';
import '../../domain/entities/warehouse_material_ref.dart';

enum LabMatRequestsStatus { loading, loaded, error }

/// State كامل لصفحة الفواتير.
class LabMaterialRequestsState {
  const LabMaterialRequestsState({
    required this.status,
    required this.requests,
    required this.filterIndex,
    this.catalog = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.catalogError,
  });

  const LabMaterialRequestsState.initial()
      : status = LabMatRequestsStatus.loading,
        requests = const [],
        filterIndex = 0,
        catalog = const [],
        searchQuery = '',
        errorMessage = null,
        catalogError = null;

  final LabMatRequestsStatus status;
  final List<MatRequest> requests;

  /// كتالوج مواد المستودع (لفورم "من المستودع").
  final List<WarehouseMaterialRef> catalog;

  /// 0=الكل 1=جديد 2=تم التسليم 3=غير متوفر.
  final int filterIndex;

  /// نص البحث المُوجَّه لهذه الصفحة (يفلتر بأسماء المواد/رقم الفاتورة).
  final String searchQuery;
  final String? errorMessage;

  /// رسالة فشل تحميل كتالوج المستودع — منفصلة عن errorMessage (خاصة بقائمة
  /// الفواتير) كي تظهر بمكانها الصحيح (فورم "من المستودع") لا بكل الصفحة.
  final String? catalogError;

  /// الفواتير بعد تطبيق فلتر الحالة + نص البحث (بأسماء كل مواد الفاتورة).
  List<MatRequest> get filtered {
    Iterable<MatRequest> list = requests;
    switch (filterIndex) {
      case 1:
        list = list.where((r) => r.status == MatRequestStatus.newRequest);
      case 2:
        list = list.where((r) => r.status == MatRequestStatus.delivered);
      case 3:
        list = list.where((r) => r.status == MatRequestStatus.unavailable);
    }
    final q = searchQuery.trim();
    if (q.isNotEmpty) {
      list = list.where((r) =>
          r.id.contains(q) ||
          r.items.any((i) => i.materialName.contains(q)) ||
          r.newItems.any((i) =>
              i.materialName.contains(q) || (i.companyName?.contains(q) ?? false)));
    }
    return list.toList(growable: false);
  }

  LabMaterialRequestsState copyWith({
    LabMatRequestsStatus? status,
    List<MatRequest>? requests,
    int? filterIndex,
    List<WarehouseMaterialRef>? catalog,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? catalogError,
    bool clearCatalogError = false,
  }) {
    return LabMaterialRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      filterIndex: filterIndex ?? this.filterIndex,
      catalog: catalog ?? this.catalog,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      catalogError: clearCatalogError ? null : (catalogError ?? this.catalogError),
    );
  }
}
```

- [ ] **Step 2: تعديل الـ Cubit**

بملف `lib/features/lab/presentation/bloc/lab_material_requests_cubit.dart`، استبدل الملف بالكامل:

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_cubit.dart
//
// Cubit لإدارة شاشة فواتير طلب المواد — تحميل + فلترة + إنشاء فاتورة جديدة.
// يطابق نمط بقية الـ Cubits (UI → Cubit → Repository).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import 'lab_material_requests_state.dart';

/// Cubit إدارة فواتير طلب المواد من المستودع.
class LabMaterialRequestsCubit extends Cubit<LabMaterialRequestsState> {
  LabMaterialRequestsCubit({required LabMaterialRequestsRepository repository})
      : _repository = repository,
        super(const LabMaterialRequestsState.initial());

  final LabMaterialRequestsRepository _repository;
  StreamSubscription<List<MatRequest>>? _subscription;

  /// تحميل الفواتير. عند إعادة الزيارة يعرض الكاش فوراً (بلا شيمر) ثم يحدّث
  /// صامتاً (stale-while-revalidate)، ويشترك بالـ stream للتحديث التلقائي.
  Future<void> load() async {
    final cached = _repository.cached;
    if (cached != null) {
      emit(state.copyWith(
          status: LabMatRequestsStatus.loaded,
          requests: cached,
          clearError: true));
    } else {
      emit(state.copyWith(
          status: LabMatRequestsStatus.loading, clearError: true));
    }
    try {
      final requests = await _repository.getAll();
      emit(state.copyWith(
        status: LabMatRequestsStatus.loaded,
        requests: requests,
        clearError: true,
      ));
    } catch (e) {
      if (cached == null) {
        emit(state.copyWith(
          status: LabMatRequestsStatus.error,
          errorMessage: userMessageFromError(e),
        ));
      }
    }
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (list) => emit(state.copyWith(requests: list)),
      onError: (Object e) => emit(state.copyWith(
        status: LabMatRequestsStatus.error,
        errorMessage: userMessageFromError(e),
      )),
    );

    await loadCatalog();
  }

  /// تحميل كتالوج مواد المستودع (لفورم "من المستودع"). فشله لا يكسر الصفحة —
  /// بس يظهر بـ catalogError كي تعرضه فورم "من المستودع" بوضوح مع زر إعادة
  /// محاولة، بدل الاختفاء الصامت.
  Future<void> loadCatalog() async {
    try {
      final catalog = await _repository.getWarehouseMaterials();
      emit(state.copyWith(catalog: catalog, clearCatalogError: true));
    } catch (e) {
      emit(state.copyWith(catalogError: userMessageFromError(e)));
    }
  }

  /// تغيير الفلتر النشط (0=الكل 1=جديد 2=تم التسليم 3=غير متوفر).
  void setFilter(int index) {
    if (index == state.filterIndex) return;
    emit(state.copyWith(filterIndex: index));
  }

  /// تحديث نص البحث المُوجَّه لهذه الصفحة.
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  /// إرسال فاتورة من مواد كتالوج المستودع. يُرجع true عند النجاح.
  Future<bool> addRequestFromWarehouse({
    required List<({int materialId, int quantity, String? notes})> items,
    String? notes,
  }) async {
    try {
      await _repository.addRequestFromWarehouse(items: items, notes: notes);
      emit(state.copyWith(filterIndex: 0, clearError: true));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  /// إرسال فاتورة من مواد شركة خارجية. يُرجع true عند النجاح.
  Future<bool> addRequestFromCompany({
    required String companyName,
    required List<({String materialName, int quantity, String unit, String? reason})> items,
    String? notes,
  }) async {
    try {
      await _repository.addRequestFromCompany(
        companyName: companyName,
        items: items,
        notes: notes,
      );
      emit(state.copyWith(filterIndex: 0, clearError: true));
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  /// حذف فاتورة (الـ stream يحدّث القائمة تلقائياً). يُرجع true عند النجاح.
  Future<bool> delete(String id) async {
    try {
      await _repository.delete(id);
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 3: إعادة كتابة اختبار الفلترة (الكيان تغيّر جذرياً)**

استبدل محتوى `test/state/lab_material_requests_filter_test.dart` بالكامل:

```dart
// اختبار وحدة: فلترة الفواتير — فلتر الحالة + البحث النصّي معًا (بمواد
// items[]/newItems[] كاملة، مو حقول مسطّحة).

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_material_requests_state.dart';

MatRequest _fromWarehouse(String id, String material, MatRequestStatus status) => MatRequest(
      id: id,
      status: status,
      requestedBy: 'x',
      requesterType: 'lab',
      date: '2026-01-01',
      items: [MatRequestItem(id: '1', materialName: material, quantityRequested: 1)],
      newItems: const [],
    );

MatRequest _fromCompany(String id, String material, String company, MatRequestStatus status) => MatRequest(
      id: id,
      status: status,
      requestedBy: 'x',
      requesterType: 'lab',
      date: '2026-01-01',
      items: const [],
      newItems: [
        MatRequestNewItem(id: '1', materialName: material, quantity: 1, unit: 'قطعة', companyName: company),
      ],
    );

void main() {
  final data = [
    _fromWarehouse('MR-001', 'زركون', MatRequestStatus.newRequest),
    _fromWarehouse('MR-002', 'جبس', MatRequestStatus.delivered),
    _fromCompany('MR-003', 'زركون بلوك', 'شام', MatRequestStatus.unavailable),
  ];

  LabMaterialRequestsState state({int filter = 0, String q = ''}) =>
      LabMaterialRequestsState(
        status: LabMatRequestsStatus.loaded,
        requests: data,
        filterIndex: filter,
        searchQuery: q,
      );

  test('فلتر 0 = الكل', () {
    expect(state().filtered.length, 3);
  });

  test('فلتر الحالة (1=جديد)', () {
    final f = state(filter: 1).filtered;
    expect(f.length, 1);
    expect(f.first.id, 'MR-001');
  });

  test('البحث بمادة items[] يطابق جزئيًا', () {
    final f = state(q: 'زركون').filtered;
    expect(f.map((r) => r.id), containsAll(['MR-001', 'MR-003']));
    expect(f.length, 2);
  });

  test('البحث برقم الفاتورة', () {
    expect(state(q: 'MR-002').filtered.single.items.single.materialName, 'جبس');
  });

  test('البحث باسم الشركة (newItems فقط)', () {
    expect(state(q: 'شام').filtered.single.id, 'MR-003');
  });

  test('الحالة + البحث معًا (تقاطع)', () {
    final f = state(filter: 1, q: 'زركون').filtered;
    expect(f.single.id, 'MR-001');
  });

  test('بحث بلا نتيجة ⇒ فارغ', () {
    expect(state(q: 'لا يوجد').filtered, isEmpty);
  });
}
```

- [ ] **Step 4: كتابة اختبار الـ Cubit الجديد**

أنشئ `test/features/lab/presentation/lab_material_requests_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/features/lab/domain/entities/warehouse_material_ref.dart';
import 'package:dt_teeth/features/lab/domain/repositories/lab_material_requests_repository.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_material_requests_cubit.dart';
import 'package:dt_teeth/features/lab/presentation/bloc/lab_material_requests_state.dart';

class _MockRepo extends Mock implements LabMaterialRequestsRepository {}

void main() {
  late _MockRepo repo;
  late LabMaterialRequestsCubit cubit;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.cached).thenReturn(null);
    when(() => repo.getAll()).thenAnswer((_) async => []);
    when(() => repo.watchAll()).thenAnswer((_) => const Stream.empty());
    cubit = LabMaterialRequestsCubit(repository: repo);
  });

  tearDown(() => cubit.close());

  test('load ينجح بتحميل الكتالوج ⇒ catalogError يبقى null', () async {
    when(() => repo.getWarehouseMaterials())
        .thenAnswer((_) async => const [WarehouseMaterialRef(materialId: 1, name: 'زركون', unit: 'كيلو')]);

    await cubit.load();

    expect(cubit.state.status, LabMatRequestsStatus.loaded);
    expect(cubit.state.catalog, hasLength(1));
    expect(cubit.state.catalogError, isNull);
  });

  test('فشل تحميل الكتالوج ⇒ catalogError يُملأ (لا يتبلع بصمت)', () async {
    when(() => repo.getWarehouseMaterials()).thenThrow(Exception('network'));

    await cubit.load();

    expect(cubit.state.status, LabMatRequestsStatus.loaded);
    expect(cubit.state.catalogError, isNotNull);
  });

  test('addRequestFromWarehouse ينجح ⇒ true + إعادة تصفير الفلتر', () async {
    when(() => repo.getWarehouseMaterials()).thenAnswer((_) async => []);
    when(() => repo.addRequestFromWarehouse(items: any(named: 'items'), notes: any(named: 'notes')))
        .thenAnswer((_) async {});
    await cubit.load();

    final ok = await cubit.addRequestFromWarehouse(
        items: const [(materialId: 1, quantity: 5, notes: null)]);

    expect(ok, isTrue);
    expect(cubit.state.filterIndex, 0);
  });

  test('addRequestFromCompany يفشل ⇒ false + errorMessage', () async {
    when(() => repo.getWarehouseMaterials()).thenAnswer((_) async => []);
    when(() => repo.addRequestFromCompany(
          companyName: any(named: 'companyName'),
          items: any(named: 'items'),
          notes: any(named: 'notes'),
        )).thenThrow(Exception('server error'));
    await cubit.load();

    final ok = await cubit.addRequestFromCompany(
      companyName: 'شركة',
      items: const [(materialName: 'مادة', quantity: 1, unit: 'قطعة', reason: null)],
    );

    expect(ok, isFalse);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
```

- [ ] **Step 5: تشغيل الاختبارات والتأكد من النجاح**

Run: `flutter test test/state/lab_material_requests_filter_test.dart test/features/lab/presentation/lab_material_requests_cubit_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/features/lab/presentation/bloc/lab_material_requests_state.dart lib/features/lab/presentation/bloc/lab_material_requests_cubit.dart test/state/lab_material_requests_filter_test.dart test/features/lab/presentation/lab_material_requests_cubit_test.dart
git commit -m "refactor(lab): Cubit/State يدعمان إنشاء فاتورة من مستودع أو شركة + فشل كتالوج ما بيتبلع بصمت"
```

---

### Task 5: نصوص الترجمة (l10n)

**Files:**
- Modify: `lib/core/l10n/arb/app_ar.arb`
- Modify: `lib/core/l10n/arb/app_en.arb`

**Interfaces:**
- Produces: مفاتيح l10n جديدة تستهلكها المهام 6-10 (البطاقة، الفورمات، الصفحة). **شغّل توليد الكود بعد التعديل** (`flutter gen-l10n` أو ما يعادلها — تحقّق من `l10n.yaml`؛ إذا المشروع يولّد تلقائياً عبر `flutter pub get`/build فشغّلها).

- [ ] **Step 1: تحديث مفاتيح موجودة (app_ar.arb)**

بملف `lib/core/l10n/arb/app_ar.arb`، بدّل القيم التالية (السطر الدقيق حسب آخر قراءة — ابحث بالمفتاح، القيمة القديمة موجودة أعلاه بالخطة كمرجع):

```json
"materialRequests": "الفواتير",
```
(كانت "طلبات المستودع")

```json
"labReqNewRequest": "طلب فاتورة جديدة",
```
(كانت "طلب مادة جديدة")

```json
"labReqEmptyCategory": "لا توجد فواتير في هذه الفئة",
```
(كانت "لا توجد طلبيات مواد في هذه الفئة")

```json
"labReqDeleteTitle": "حذف الفاتورة",
"labReqDeleteConfirm": "هل تريد حذف الفاتورة #{id}؟ لا يمكن التراجع.",
"@labReqDeleteConfirm": {
  "placeholders": {
    "id": {
      "type": "String"
    }
  }
},
```
(كانت `{material}` — الحقل المسطّح غير موجود بالكيان الجديد، استبدلناه برقم الفاتورة المتوفر دايماً)

```json
"labReqSentSuccess": "تم إرسال الفاتورة للمستودع",
```
(كانت "تم إرسال طلب المادة للمستودع")

- [ ] **Step 2: إضافة مفاتيح جديدة (app_ar.arb)**

أضف بعد `"labReqSentSuccess"` مباشرة:

```json
"labReqChooseTypeTitle": "نوع الفاتورة",
"labReqFromWarehouseTitle": "من مواد المستودع",
"labReqFromWarehouseDesc": "اختر مواد موجودة أصلاً بمخزون المستودع",
"labReqFromCompanyTitle": "من شركة (مادة جديدة)",
"labReqFromCompanyDesc": "مواد غير موجودة بالمستودع — تُطلب من شركة خارجية",
"labReqSearchMaterialHint": "ابحث باسم المادة...",
"labReqAddToInvoice": "إضافة",
"labReqInvoiceItemsEmpty": "لم تُضَف أي مادة بعد",
"labReqAddMaterialRow": "+ إضافة مادة",
"labReqRemoveRow": "حذف",
"labReqCompanyNameRequired": "اسم الشركة مطلوب",
"labReqAtLeastOneItemRequired": "أضف مادة واحدة على الأقل",
"labReqNotesOptional": "ملاحظات (اختياري)",
"labReqCatalogLoadFailed": "تعذّر تحميل مواد المستودع",
"labReqCatalogRetry": "إعادة المحاولة",
"labReqItemsCount": "{count} مادة",
"@labReqItemsCount": {
  "placeholders": {
    "count": {
      "type": "int"
    }
  }
},
"labReqTypeWarehouse": "من المستودع",
"labReqTypeCompany": "من شركة",
"labReqInvoiceNumber": "فاتورة #{id}",
"@labReqInvoiceNumber": {
  "placeholders": {
    "id": {
      "type": "String"
    }
  }
},
"labReqDetailsTitle": "تفاصيل الفاتورة",
"labReqPrint": "طباعة",
"labReqQuantityColumn": "الكمية",
"labReqUnitColumn": "الوحدة",
"labReqCompanyColumn": "الشركة",
```

- [ ] **Step 3: نفس التعديلات بـ `app_en.arb` (تحديث + إضافة)**

بملف `lib/core/l10n/arb/app_en.arb`، بدّل:

```json
"materialRequests": "Invoices",
"labReqNewRequest": "New invoice",
"labReqEmptyCategory": "No invoices in this category",
"labReqDeleteTitle": "Delete invoice",
"labReqDeleteConfirm": "Delete invoice #{id}? This cannot be undone.",
"@labReqDeleteConfirm": {
  "placeholders": {
    "id": {
      "type": "String"
    }
  }
},
"labReqSentSuccess": "Invoice sent to the warehouse",
```

وأضف نفس المفاتيح الجديدة بترجمة إنجليزية مطابقة بالمعنى (بنفس أسلوب باقي الملف — جمل قصيرة مباشرة):

```json
"labReqChooseTypeTitle": "Invoice type",
"labReqFromWarehouseTitle": "From warehouse materials",
"labReqFromWarehouseDesc": "Choose materials already in the warehouse stock",
"labReqFromCompanyTitle": "From a company (new material)",
"labReqFromCompanyDesc": "Materials not in the warehouse — requested from an external company",
"labReqSearchMaterialHint": "Search by material name...",
"labReqAddToInvoice": "Add",
"labReqInvoiceItemsEmpty": "No materials added yet",
"labReqAddMaterialRow": "+ Add material",
"labReqRemoveRow": "Remove",
"labReqCompanyNameRequired": "Company name is required",
"labReqAtLeastOneItemRequired": "Add at least one material",
"labReqNotesOptional": "Notes (optional)",
"labReqCatalogLoadFailed": "Failed to load warehouse materials",
"labReqCatalogRetry": "Retry",
"labReqItemsCount": "{count} materials",
"@labReqItemsCount": {
  "placeholders": {
    "count": {
      "type": "int"
    }
  }
},
"labReqTypeWarehouse": "From warehouse",
"labReqTypeCompany": "From company",
"labReqInvoiceNumber": "Invoice #{id}",
"@labReqInvoiceNumber": {
  "placeholders": {
    "id": {
      "type": "String"
    }
  }
},
"labReqDetailsTitle": "Invoice details",
"labReqPrint": "Print",
"labReqQuantityColumn": "Quantity",
"labReqUnitColumn": "Unit",
"labReqCompanyColumn": "Company",
```

- [ ] **Step 4: توليد كود الترجمة والتحقق من عدم وجود أخطاء**

Run: `flutter gen-l10n` (أو `flutter pub get` لو المشروع يولّد تلقائياً — تحقّق من `l10n.yaml` بالجذر أولاً؛ `synthetic-package: false` تعني الملفات المولَّدة بـ `lib/core/l10n/generated/` تُحدَّث مباشرة بأمر `flutter gen-l10n`)

Expected: بلا أخطاء JSON/بلا مفاتيح ناقصة بين `app_ar.arb`/`app_en.arb` (لازم كل مفتاح موجود بالاثنين بنفس الـ placeholders).

Run: `flutter analyze lib/core/l10n/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/core/l10n/arb/app_ar.arb lib/core/l10n/arb/app_en.arb lib/core/l10n/generated/
git commit -m "feat(l10n): نصوص فواتير طلب المواد (مصطلح فاتورة + فورمي الإنشاء وتفاصيل الفاتورة)"
```

---

### Task 6: بطاقة الفاتورة بالقائمة

**Files:**
- Modify: `lib/features/lab/presentation/widgets/material_requests/lab_mat_request_card.dart`
- Test: `test/widgets/lab_mat_request_card_test.dart` (جديد)

**Interfaces:**
- Consumes: `MatRequest` (Task 1)، مفاتيح l10n (Task 5): `labReqItemsCount`, `labReqTypeWarehouse`, `labReqTypeCompany`, `labReqInvoiceNumber`.
- Produces: `LabMatRequestCard({required MatRequest request, VoidCallback? onDelete, VoidCallback? onTap})` — بارامتر `onTap` **جديد** (تستهلكه Task 9 لفتح تفاصيل الفاتورة).

- [ ] **Step 1: كتابة الاختبار (سيفشل)**

أنشئ `test/widgets/lab_mat_request_card_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_mat_request_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  testWidgets('فاتورة مستودع بمادتين — تعرض عدد المواد ونوع "من المستودع"', (tester) async {
    final req = MatRequest(
      id: '5',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      items: const [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: const [],
    );

    await tester.pumpWidget(wrap(LabMatRequestCard(request: req)));
    await tester.pump();

    expect(find.textContaining('2'), findsWidgets);
    expect(find.text('من المستودع'), findsOneWidget);
  });

  testWidgets('فاتورة شركة — تعرض نوع "من شركة"، والدوس عليها يستدعي onTap', (tester) async {
    final req = MatRequest(
      id: '6',
      status: MatRequestStatus.newRequest,
      requestedBy: 'سارة',
      requesterType: 'lab',
      date: '2026-08-19',
      items: const [],
      newItems: const [
        MatRequestNewItem(id: '1', materialName: 'صمغ', quantity: 3, unit: 'علبة', companyName: 'دنتال'),
      ],
    );

    var tapped = false;
    await tester.pumpWidget(wrap(LabMatRequestCard(request: req, onTap: () => tapped = true)));
    await tester.pump();

    expect(find.text('من شركة'), findsOneWidget);
    await tester.tap(find.byType(LabMatRequestCard));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/widgets/lab_mat_request_card_test.dart`
Expected: FAIL — `LabMatRequestCard` لسا بتستعمل `r.material`/`r.quantity` غير الموجودين (compile error)، و`onTap` غير موجود.

- [ ] **Step 3: إعادة كتابة الملف**

استبدل محتوى `lib/features/lab/presentation/widgets/material_requests/lab_mat_request_card.dart` بالكامل (نفس الستايل/الألوان/البادجات الأصلية، فقط قسم "المحتوى" يتغيّر ليعرض عدد المواد ونوعها بدل حقل مادة واحد):

```dart
import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_badge.dart';
import 'lab_mat_request_data.dart';

/// بطاقة فاتورة واحدة في قائمة فواتير المخبر.
class LabMatRequestCard extends StatefulWidget {
  const LabMatRequestCard({super.key, required this.request, this.onDelete, this.onTap});
  final MatRequest request;

  /// عند تمريره يظهر زر حذف في رأس البطاقة (null = بلا حذف).
  final VoidCallback? onDelete;

  /// يُستدعى عند الدوس على البطاقة (لفتح تفاصيل الفاتورة).
  final VoidCallback? onTap;

  @override
  State<LabMatRequestCard> createState() => _LabMatRequestCardState();
}

class _LabMatRequestCardState extends State<LabMatRequestCard> {
  bool _hovered = false;

  Color get _accentColor {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return AppColors.accent;
      case MatRequestStatus.inProgress:
        return AppColors.statusProgress;
      case MatRequestStatus.delivered:
        return AppColors.success;
      case MatRequestStatus.unavailable:
        return AppColors.error;
      case MatRequestStatus.cancelled:
        return AppColors.categoryGrey;
    }
  }

  AppBadgeVariant get _badgeVariant {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return AppBadgeVariant.cyan;
      case MatRequestStatus.inProgress:
        return AppBadgeVariant.violet;
      case MatRequestStatus.delivered:
        return AppBadgeVariant.green;
      case MatRequestStatus.unavailable:
        return AppBadgeVariant.redAnimated;
      case MatRequestStatus.cancelled:
        return AppBadgeVariant.gold;
    }
  }

  String _badgeText(BuildContext context) {
    switch (widget.request.status) {
      case MatRequestStatus.newRequest:
        return context.l10n.statusNew;
      case MatRequestStatus.inProgress:
        return context.l10n.labReqStatusInProgress;
      case MatRequestStatus.delivered:
        return context.l10n.statusDelivered;
      case MatRequestStatus.unavailable:
        return context.l10n.labReqStatusUnavailable;
      case MatRequestStatus.cancelled:
        return context.l10n.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final l10n = context.l10n;
    final typeLabel = r.isFromCompany ? l10n.labReqTypeCompany : l10n.labReqTypeWarehouse;
    final typeIcon = r.isFromCompany ? AppIcons.supplier : AppIcons.materials;
    final firstMaterialName = r.isFromCompany
        ? (r.newItems.isNotEmpty ? r.newItems.first.materialName : '')
        : (r.items.isNotEmpty ? r.items.first.materialName : '');

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      // ClipRRect + شريط لوني منفصل بدل Border رباعي الألوان: Flutter يرمي
      // استثناء عند الرسم لو Border له borderRadius وألوان أضلاع مختلفة.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
              border: Border.all(
                color: _hovered
                    ? (isLight ? AppColors.lightBorderHover : AppColors.darkBorderHover)
                    : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
              ),
              boxShadow: _hovered
                  ? [BoxShadow(color: _accentColor.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(width: 3, color: _accentColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: رقم الفاتورة + أول مادة (+الباقي) + الحالة
                      Row(
                        children: [
                          Text(
                            l10n.labReqInvoiceNumber(r.id),
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spaceSM),
                          Expanded(
                            child: Text(
                              r.itemsCount > 1
                                  ? '$firstMaterialName +${r.itemsCount - 1}'
                                  : firstMaterialName,
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppBadge(text: _badgeText(context), variant: _badgeVariant),
                          if (widget.onDelete != null) ...[
                            const SizedBox(width: AppSizes.spaceSM),
                            Tooltip(
                              message: context.l10n.delete,
                              child: Semantics(
                                button: true,
                                label: context.l10n.delete,
                                child: InkResponse(
                                  onTap: widget.onDelete,
                                  radius: 18,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSizes.spaceMD),
                      const Divider(height: 1, color: AppColors.darkBorder),
                      const SizedBox(height: AppSizes.spaceMD),
                      // Row 2: التفاصيل
                      Row(
                        children: [
                          _cell(context, icon: typeIcon, label: '', value: typeLabel),
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(context, icon: AppIcons.box, label: l10n.labReqItemsCount(r.itemsCount), value: ''),
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(
                            context,
                            icon: AppIcons.profile,
                            label: context.l10n.labReqRequestedBy,
                            value: r.requestedBy,
                            valueColor: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSizes.spaceXL),
                          _cell(context, icon: AppIcons.calendar, label: context.l10n.ordersDate, value: r.date),
                          const Spacer(),
                        ],
                      ),
                      if (r.notes != null && r.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.spaceSM),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceMD, vertical: AppSizes.spaceXS),
                          decoration: BoxDecoration(
                            color: AppColors.statusInfo.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                            border: Border.all(color: AppColors.statusInfo.withValues(alpha: 0.18)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.statusInfo),
                              const SizedBox(width: AppSizes.spaceXS),
                              Expanded(
                                child: Text(
                                  r.notes!,
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusInfo),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final text = label.isEmpty ? value : (value.isEmpty ? label : '$label: $value');
    return Row(
      children: [
        Icon(icon, size: 11, color: isLight ? AppColors.lightText4 : AppColors.darkText4),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? (isLight ? AppColors.lightText1 : AppColors.darkText1),
          ),
        ),
      ],
    );
  }
}
```

**ملاحظة:** `_cell` تغيّر شكلها البسيط (نص واحد بدل عمود label/value منفصل) عشان تناسب استخدامها المزدوج هون (أحياناً label بس، أحياناً label+value). لو النتيجة البصرية بالاختبار اليدوي (Task 11) ما بانت مرتّبة، عدّل التنسيق بحرية بنفس المهمة — المطلوب الجوهري هو عرض عدد المواد والنوع بشكل واضح، مو تطابق بكسل-لبكسل مع الكود أعلاه.

- [ ] **Step 4: تشغيل الاختبار والتأكد من النجاح**

Run: `flutter test test/widgets/lab_mat_request_card_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lab/presentation/widgets/material_requests/lab_mat_request_card.dart test/widgets/lab_mat_request_card_test.dart
git commit -m "refactor(lab): بطاقة الفاتورة تعرض عدد المواد ونوع الفاتورة (مستودع/شركة) بدل مادة واحدة"
```

---

### Task 7: فورم "من مواد المستودع"

**Files:**
- Create: `lib/features/lab/presentation/widgets/material_requests/lab_invoice_from_warehouse_dialog.dart`
- Test: `test/widgets/lab_invoice_from_warehouse_dialog_test.dart` (جديد)

**Interfaces:**
- Consumes: `WarehouseMaterialRef` (موجود)، مفاتيح l10n (Task 5).
- Produces: `LabInvoiceFromWarehouseResult{items: List<({int materialId, int quantity, String? notes})>, notes: String?}`، و`LabInvoiceFromWarehouseDialog.show(context, {required List<WarehouseMaterialRef> catalog, String? catalogError, required VoidCallback onRetryCatalog}) → Future<LabInvoiceFromWarehouseResult?>` — تستهلكه Task 9.

- [ ] **Step 1: كتابة الاختبار (سيفشل)**

أنشئ `test/widgets/lab_invoice_from_warehouse_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/warehouse_material_ref.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_from_warehouse_dialog.dart';

const _catalog = [
  WarehouseMaterialRef(materialId: 1, name: 'زركون', unit: 'كيلو'),
  WarehouseMaterialRef(materialId: 2, name: 'جبس', unit: 'كيلو'),
];

void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Builder(builder: (context) => child)),
      );

  testWidgets('اختيار مادتين وإدخال كمية لكل وحدة ⇒ نتيجة items بعنصرين', (tester) async {
    LabInvoiceFromWarehouseResult? result;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await LabInvoiceFromWarehouseDialog.show(
            context,
            catalog: _catalog,
            onRetryCatalog: () {},
          );
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // إضافة "زركون" للسلة
    await tester.tap(find.text('زركون'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة').first);
    await tester.pumpAndSettle();

    // إضافة "جبس" للسلة
    await tester.tap(find.text('جبس'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة').first);
    await tester.pumpAndSettle();

    // إدخال كمية لكل عنصر بالسلة
    final qtyFields = find.byType(TextField);
    await tester.enterText(qtyFields.at(0), '10');
    await tester.enterText(qtyFields.at(1), '5');

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.items, hasLength(2));
    expect(result!.items.map((e) => e.materialId), containsAll([1, 2]));
  });

  testWidgets('إرسال بدون أي مادة ⇒ الحوار يبقى مفتوح (بلا نتيجة)', (tester) async {
    LabInvoiceFromWarehouseResult? result;
    var popped = false;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await LabInvoiceFromWarehouseDialog.show(context, catalog: _catalog, onRetryCatalog: () {});
          popped = true;
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();

    expect(popped, isFalse);
    expect(result, isNull);
  });
}
```

- [ ] **Step 2: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/widgets/lab_invoice_from_warehouse_dialog_test.dart`
Expected: FAIL — الملف غير موجود.

- [ ] **Step 3: إنشاء الملف**

أنشئ `lib/features/lab/presentation/widgets/material_requests/lab_invoice_from_warehouse_dialog.dart`:

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_from_warehouse_dialog.dart
//
// فورم "فاتورة من مواد المستودع" — يسمح باختيار عدّة مواد من كتالوج المستودع
// وتحديد كمية لكل واحدة (سلة)، ثم إرسالها كفاتورة واحدة (items[]).
// نفس ستايل lab_mat_request_dialog.dart القديم (الآن محذوف).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/warehouse_material_ref.dart';

class LabInvoiceFromWarehouseResult {
  const LabInvoiceFromWarehouseResult({required this.items, this.notes});
  final List<({int materialId, int quantity, String? notes})> items;
  final String? notes;
}

class LabInvoiceFromWarehouseDialog extends StatefulWidget {
  const LabInvoiceFromWarehouseDialog({
    super.key,
    required this.catalog,
    this.catalogError,
    required this.onRetryCatalog,
  });

  final List<WarehouseMaterialRef> catalog;
  final String? catalogError;
  final VoidCallback onRetryCatalog;

  static Future<LabInvoiceFromWarehouseResult?> show(
    BuildContext context, {
    required List<WarehouseMaterialRef> catalog,
    String? catalogError,
    required VoidCallback onRetryCatalog,
  }) {
    return showDialog<LabInvoiceFromWarehouseResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabInvoiceFromWarehouseDialog(
        catalog: catalog,
        catalogError: catalogError,
        onRetryCatalog: onRetryCatalog,
      ),
    );
  }

  @override
  State<LabInvoiceFromWarehouseDialog> createState() => _LabInvoiceFromWarehouseDialogState();
}

class _CartRow {
  _CartRow(this.material) : quantityController = TextEditingController();
  final WarehouseMaterialRef material;
  final TextEditingController quantityController;
}

class _LabInvoiceFromWarehouseDialogState extends State<LabInvoiceFromWarehouseDialog> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final List<_CartRow> _cart = [];
  String? _errorText;

  @override
  void dispose() {
    _search.dispose();
    _notes.dispose();
    for (final row in _cart) {
      row.quantityController.dispose();
    }
    super.dispose();
  }

  List<WarehouseMaterialRef> get _filtered {
    final q = _search.text.trim();
    final inCart = _cart.map((r) => r.material.materialId).toSet();
    final base = widget.catalog.where((m) => !inCart.contains(m.materialId));
    if (q.isEmpty) return base.toList();
    return base.where((m) => m.name.contains(q)).toList();
  }

  void _addToCart(WarehouseMaterialRef m) {
    setState(() {
      _cart.add(_CartRow(m));
      _search.clear();
      _errorText = null;
    });
  }

  void _removeFromCart(_CartRow row) {
    setState(() {
      row.quantityController.dispose();
      _cart.remove(row);
    });
  }

  void _submit() {
    final l10n = context.l10n;
    if (_cart.isEmpty) {
      setState(() => _errorText = l10n.labReqAtLeastOneItemRequired);
      return;
    }
    final items = <({int materialId, int quantity, String? notes})>[];
    for (final row in _cart) {
      final qty = int.tryParse(row.quantityController.text.trim()) ?? 0;
      if (qty <= 0) {
        setState(() => _errorText = l10n.labReqQuantityRequired);
        return;
      }
      items.add((materialId: row.material.materialId, quantity: qty, notes: null));
    }
    final notes = _notes.text.trim();
    Navigator.of(context).pop(
      LabInvoiceFromWarehouseResult(items: items, notes: notes.isEmpty ? null : notes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labReqFromWarehouseTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              if (widget.catalogError != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(widget.catalogError!, style: TextStyle(color: AppColors.error))),
                      TextButton(onPressed: widget.onRetryCatalog, child: Text(l10n.labReqCatalogRetry)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spaceMD),
              ],
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: l10n.labReqSearchMaterialHint,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSizes.spaceSM),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 140),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final m = _filtered[i];
                    return ListTile(
                      dense: true,
                      title: Text(m.name),
                      subtitle: m.unit.isEmpty ? null : Text(m.unit),
                      trailing: TextButton(
                        onPressed: () => _addToCart(m),
                        child: Text(l10n.labReqAddToInvoice),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.spaceMD),
              Flexible(
                child: _cart.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceLG),
                        child: Text(l10n.labReqInvoiceItemsEmpty, textAlign: TextAlign.center),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _cart.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spaceSM),
                        itemBuilder: (context, i) {
                          final row = _cart[i];
                          return Row(
                            children: [
                              Expanded(child: Text(row.material.name)),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: row.quantityController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: l10n.colQuantity,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => _removeFromCart(row),
                                tooltip: l10n.labReqRemoveRow,
                              ),
                            ],
                          );
                        },
                      ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSizes.spaceSM),
                Text(_errorText!, style: TextStyle(color: AppColors.error, fontSize: 12)),
              ],
              const SizedBox(height: AppSizes.spaceMD),
              TextField(
                controller: _notes,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
                decoration: InputDecoration(
                  hintText: l10n.labReqNotesOptional,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton.primary(
                    label: l10n.labReqSubmit,
                    onPressed: _submit,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: تشغيل الاختبار والتأكد من النجاح**

Run: `flutter test test/widgets/lab_invoice_from_warehouse_dialog_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lab/presentation/widgets/material_requests/lab_invoice_from_warehouse_dialog.dart test/widgets/lab_invoice_from_warehouse_dialog_test.dart
git commit -m "feat(lab): فورم فاتورة متعددة المواد من كتالوج المستودع (سلة اختيار)"
```

---

### Task 8: فورم "من شركة" + دمج مع خطوة اختيار النوع

**Files:**
- Create: `lib/features/lab/presentation/widgets/material_requests/lab_invoice_from_company_dialog.dart`
- Create: `lib/features/lab/presentation/widgets/material_requests/lab_invoice_type_chooser_dialog.dart`
- Delete: `lib/features/lab/presentation/widgets/material_requests/lab_mat_request_dialog.dart`
- Test: `test/widgets/lab_invoice_from_company_dialog_test.dart` (جديد)
- Test: `test/widgets/lab_invoice_type_chooser_dialog_test.dart` (جديد)

**Interfaces:**
- Produces: `LabInvoiceFromCompanyResult{companyName: String, items: List<({String materialName, int quantity, String unit, String? reason})>, notes: String?}`، `LabInvoiceFromCompanyDialog.show(context) → Future<LabInvoiceFromCompanyResult?>`. `LabInvoiceType {warehouse, company}`، `LabInvoiceTypeChooserDialog.show(context) → Future<LabInvoiceType?>` — تستهلكهم Task 9.

- [ ] **Step 1: كتابة اختبار خطوة الاختيار (سيفشل)**

أنشئ `test/widgets/lab_invoice_type_chooser_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_type_chooser_dialog.dart';

void main() {
  testWidgets('اختيار "من مواد المستودع" يرجع LabInvoiceType.warehouse', (tester) async {
    LabInvoiceType? result;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async => result = await LabInvoiceTypeChooserDialog.show(context),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('من مواد المستودع'));
    await tester.pumpAndSettle();

    expect(result, LabInvoiceType.warehouse);
  });
}
```

- [ ] **Step 2: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/widgets/lab_invoice_type_chooser_dialog_test.dart`
Expected: FAIL — الملف غير موجود.

- [ ] **Step 3: إنشاء `lab_invoice_type_chooser_dialog.dart`**

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_type_chooser_dialog.dart
//
// خطوة اختيار نوع الفاتورة الجديدة — من مواد المستودع، أو من شركة خارجية.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';

enum LabInvoiceType { warehouse, company }

class LabInvoiceTypeChooserDialog extends StatelessWidget {
  const LabInvoiceTypeChooserDialog({super.key});

  static Future<LabInvoiceType?> show(BuildContext context) {
    return showDialog<LabInvoiceType>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LabInvoiceTypeChooserDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labReqChooseTypeTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              _OptionCard(
                icon: AppIcons.materials,
                title: l10n.labReqFromWarehouseTitle,
                subtitle: l10n.labReqFromWarehouseDesc,
                onTap: () => Navigator.of(context).pop(LabInvoiceType.warehouse),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              _OptionCard(
                icon: AppIcons.supplier,
                title: l10n.labReqFromCompanyTitle,
                subtitle: l10n.labReqFromCompanyDesc,
                onTap: () => Navigator.of(context).pop(LabInvoiceType.company),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.spaceMD),
          decoration: BoxDecoration(
            border: Border.all(color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: تشغيل اختبار الخطوة والتأكد من النجاح**

Run: `flutter test test/widgets/lab_invoice_type_chooser_dialog_test.dart`
Expected: PASS

- [ ] **Step 5: كتابة اختبار فورم "من شركة" (سيفشل)**

أنشئ `test/widgets/lab_invoice_from_company_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_from_company_dialog.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Builder(builder: (context) => child)),
      );

  testWidgets('اسم الشركة + مادتين ⇒ نتيجة بعنصرين، والشركة مكرّرة تلقائياً', (tester) async {
    LabInvoiceFromCompanyResult? result;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async => result = await LabInvoiceFromCompanyDialog.show(context),
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('company_name_field')), 'شركة دنتال سوريا');

    // صف مادة أول موجود افتراضياً
    await tester.enterText(find.byKey(const Key('material_name_0')), 'صمغ طبي خاص');
    await tester.enterText(find.byKey(const Key('material_qty_0')), '3');

    // إضافة صف تاني
    await tester.tap(find.text('+ إضافة مادة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('material_name_1')), 'قفازات');
    await tester.enterText(find.byKey(const Key('material_qty_1')), '20');

    await tester.tap(find.text('إرسال الطلب'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.companyName, 'شركة دنتال سوريا');
    expect(result!.items, hasLength(2));
    expect(result!.items[0].materialName, 'صمغ طبي خاص');
    expect(result!.items[1].materialName, 'قفازات');
  });

  testWidgets('اسم شركة فارغ ⇒ لا يُغلق الحوار', (tester) async {
    LabInvoiceFromCompanyResult? result;
    var popped = false;
    await tester.pumpWidget(wrap(Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () async {
          result = await LabInvoiceFromCompanyDialog.show(context);
          popped = true;
        },
        child: const Text('open'),
      );
    })));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('material_name_0')), 'مادة');
    await tester.enterText(find.byKey(const Key('material_qty_0')), '5');
    await tester.tap(find.text('إرسال الطلب'));
    await tester.pump();

    expect(popped, isFalse);
    expect(result, isNull);
  });
}
```

- [ ] **Step 6: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/widgets/lab_invoice_from_company_dialog_test.dart`
Expected: FAIL — الملف غير موجود.

- [ ] **Step 7: إنشاء `lab_invoice_from_company_dialog.dart`**

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_from_company_dialog.dart
//
// فورم "فاتورة من شركة" — اسم شركة واحد + قائمة مواد قابلة للتكرار (اسم/كمية/
// وحدة/سبب لكل صف). اسم الشركة يتكرّر تلقائياً بكل عنصر بجسم الطلب (يبنيه
// الـ Repository، هالفورم بس بيجمع البيانات).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_select.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import 'lab_mat_request_data.dart';

class LabInvoiceFromCompanyResult {
  const LabInvoiceFromCompanyResult({required this.companyName, required this.items, this.notes});
  final String companyName;
  final List<({String materialName, int quantity, String unit, String? reason})> items;
  final String? notes;
}

class LabInvoiceFromCompanyDialog extends StatefulWidget {
  const LabInvoiceFromCompanyDialog({super.key});

  static Future<LabInvoiceFromCompanyResult?> show(BuildContext context) {
    return showDialog<LabInvoiceFromCompanyResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LabInvoiceFromCompanyDialog(),
    );
  }

  @override
  State<LabInvoiceFromCompanyDialog> createState() => _LabInvoiceFromCompanyDialogState();
}

class _MaterialRow {
  _MaterialRow()
      : nameController = TextEditingController(),
        quantityController = TextEditingController(),
        reasonController = TextEditingController(),
        unit = kMatRequestUnits.first;
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController reasonController;
  String unit;

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    reasonController.dispose();
  }
}

class _LabInvoiceFromCompanyDialogState extends State<LabInvoiceFromCompanyDialog> {
  final TextEditingController _company = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final List<_MaterialRow> _rows = [_MaterialRow()];
  String? _companyError;
  String? _rowsError;

  @override
  void dispose() {
    _company.dispose();
    _notes.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_MaterialRow()));

  void _removeRow(int i) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows.removeAt(i).dispose();
    });
  }

  void _submit() {
    final l10n = context.l10n;
    final company = _company.text.trim();
    setState(() {
      _companyError = company.isEmpty ? l10n.labReqCompanyNameRequired : null;
    });
    final items = <({String materialName, int quantity, String unit, String? reason})>[];
    for (final row in _rows) {
      final name = row.nameController.text.trim();
      final qty = int.tryParse(row.quantityController.text.trim()) ?? 0;
      if (name.isEmpty || qty <= 0) continue;
      final reason = row.reasonController.text.trim();
      items.add((materialName: name, quantity: qty, unit: row.unit, reason: reason.isEmpty ? null : reason));
    }
    setState(() {
      _rowsError = items.isEmpty ? l10n.labReqAtLeastOneItemRequired : null;
    });
    if (_companyError != null || _rowsError != null) return;
    final notes = _notes.text.trim();
    Navigator.of(context).pop(
      LabInvoiceFromCompanyResult(companyName: company, items: items, notes: notes.isEmpty ? null : notes),
    );
  }

  InputDecoration _decoration({String? errorText, String? hintText}) => InputDecoration(
        errorText: errorText,
        hintText: hintText,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSM)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.labReqFromCompanyTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                ),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              TextField(
                key: const Key('company_name_field'),
                controller: _company,
                inputFormatters: [LengthLimitingTextInputFormatter(120)],
                decoration: _decoration(errorText: _companyError, hintText: l10n.labReqFieldCompany),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              for (var i = 0; i < _rows.length; i++) ...[
                _materialRow(context, i, isLight),
                const SizedBox(height: AppSizes.spaceMD),
              ],
              if (_rowsError != null)
                Text(_rowsError!, style: TextStyle(color: AppColors.error, fontSize: 12)),
              TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.labReqAddMaterialRow),
              ),
              const SizedBox(height: AppSizes.spaceMD),
              TextField(
                controller: _notes,
                maxLines: 2,
                inputFormatters: [LengthLimitingTextInputFormatter(300)],
                decoration: _decoration(hintText: l10n.labReqNotesOptional),
              ),
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    size: AppButtonSize.small,
                  ),
                  const SizedBox(width: 10),
                  AppButton.primary(
                    label: l10n.labReqSubmit,
                    onPressed: _submit,
                    size: AppButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _materialRow(BuildContext context, int i, bool isLight) {
    final l10n = context.l10n;
    final row = _rows[i];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            key: Key('material_name_$i'),
            controller: row.nameController,
            inputFormatters: [LengthLimitingTextInputFormatter(120)],
            decoration: _decoration(hintText: l10n.labReqFieldMaterial),
          ),
        ),
        const SizedBox(width: AppSizes.spaceSM),
        Expanded(
          flex: 2,
          child: TextField(
            key: Key('material_qty_$i'),
            controller: row.quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _decoration(hintText: l10n.colQuantity),
          ),
        ),
        const SizedBox(width: AppSizes.spaceSM),
        Expanded(
          flex: 2,
          child: AppDropdownMenuTheme(
            child: DropdownButtonFormField<String>(
              initialValue: row.unit,
              isExpanded: true,
              decoration: _decoration(),
              dropdownColor: isLight ? Colors.white : AppColors.darkBg1,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
              items: [for (final u in kMatRequestUnits) DropdownMenuItem(value: u, child: Text(u))],
              onChanged: (v) => setState(() => row.unit = v ?? row.unit),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 18),
          onPressed: _rows.length > 1 ? () => _removeRow(i) : null,
          tooltip: l10n.labReqRemoveRow,
        ),
      ],
    );
  }
}
```

- [ ] **Step 8: تشغيل اختبار فورم الشركة والتأكد من النجاح**

Run: `flutter test test/widgets/lab_invoice_from_company_dialog_test.dart`
Expected: PASS

- [ ] **Step 9: حذف الفورم القديم**

```bash
rm lib/features/lab/presentation/widgets/material_requests/lab_mat_request_dialog.dart
```

تحقّق (grep) إن ما في أي ملف تاني بيستورد `lab_mat_request_dialog.dart` أو يستخدم `LabMaterialRequestDialog`/`LabMaterialRequestResult` قبل الحذف — المستهلك الوحيد هو `lab_material_requests_page.dart` يلي بتتعدّل بـ Task 9 (بعد هالمهمة). إذا لقيت استخدامات تانية، وقف وأبلغ — لا تحذف الملف.

- [ ] **Step 10: تشغيل كل اختبارات المجلد والتأكد من عدم وجود انحدار**

Run: `flutter test test/widgets/lab_invoice_type_chooser_dialog_test.dart test/widgets/lab_invoice_from_company_dialog_test.dart test/widgets/lab_invoice_from_warehouse_dialog_test.dart`
Expected: PASS (كل الاختبارات)

- [ ] **Step 11: Commit**

```bash
git add lib/features/lab/presentation/widgets/material_requests/lab_invoice_from_company_dialog.dart lib/features/lab/presentation/widgets/material_requests/lab_invoice_type_chooser_dialog.dart test/widgets/lab_invoice_from_company_dialog_test.dart test/widgets/lab_invoice_type_chooser_dialog_test.dart
git add lib/features/lab/presentation/widgets/material_requests/lab_mat_request_dialog.dart
git commit -m "feat(lab): فورم فاتورة متعددة المواد من شركة + خطوة اختيار النوع؛ حذف الفورم القديم أحادي المادة"
```

---

### Task 9: تفاصيل الفاتورة (Dialog عرض)

**Files:**
- Create: `lib/features/lab/presentation/widgets/material_requests/lab_invoice_details_dialog.dart`
- Test: `test/widgets/lab_invoice_details_dialog_test.dart` (جديد)

**Interfaces:**
- Consumes: `MatRequest` (Task 1)، مفاتيح l10n (Task 5).
- Produces: `LabInvoiceDetailsDialog.show(BuildContext, MatRequest invoice, {VoidCallback? onPrint})` — تستهلكه Task 10.

- [ ] **Step 1: كتابة الاختبار (سيفشل)**

أنشئ `test/widgets/lab_invoice_details_dialog_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/core/l10n/generated/app_localizations.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_details_dialog.dart';

void main() {
  testWidgets('يعرض كل عناصر الفاتورة (مو أول واحد بس) + زر طباعة', (tester) async {
    final req = MatRequest(
      id: '10',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      items: const [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: const [],
    );
    var printed = false;

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => LabInvoiceDetailsDialog.show(context, req, onPrint: () => printed = true),
            child: const Text('open'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('زركون'), findsOneWidget);
    expect(find.text('جبس'), findsOneWidget);

    await tester.tap(find.text('طباعة'));
    expect(printed, isTrue);
  });
}
```

- [ ] **Step 2: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/widgets/lab_invoice_details_dialog_test.dart`
Expected: FAIL — الملف غير موجود.

- [ ] **Step 3: إنشاء الملف**

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_details_dialog.dart
//
// عرض تفاصيل فاتورة كاملة (كل items[]/newItems[]) — بلا أزرار إجراء تنفيذ
// (المخبر هون هو مُنشئ الفاتورة مو مُنفّذها). زر طباعة اختياري.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../domain/entities/lab_material_request.dart';

class LabInvoiceDetailsDialog extends StatelessWidget {
  const LabInvoiceDetailsDialog({super.key, required this.invoice, this.onPrint});

  final MatRequest invoice;
  final VoidCallback? onPrint;

  static Future<void> show(BuildContext context, MatRequest invoice, {VoidCallback? onPrint}) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabInvoiceDetailsDialog(invoice: invoice, onPrint: onPrint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.labReqInvoiceNumber(invoice.id),
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              Text(l10n.labReqDetailsTitle, style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSizes.spaceMD),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final it in invoice.items)
                      _row(context, it.materialName, '${it.quantityRequested}', notes: it.notes),
                    for (final it in invoice.newItems)
                      _row(context, it.materialName, '${it.quantity} ${it.unit}',
                          company: it.companyName, notes: it.reason),
                  ],
                ),
              ),
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spaceMD),
                Text(invoice.notes!, style: AppTextStyles.bodySmall),
              ],
              const SizedBox(height: AppSizes.spaceLG),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onPrint != null)
                    AppButton.secondary(label: l10n.labReqPrint, onPressed: onPrint, size: AppButtonSize.small),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String name, String qty, {String? company, String? notes}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                if (company != null) Text(company, style: AppTextStyles.bodySmall),
                if (notes != null) Text(notes, style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusInfo)),
              ],
            ),
          ),
          Text(qty, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: تشغيل الاختبار والتأكد من النجاح**

Run: `flutter test test/widgets/lab_invoice_details_dialog_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lab/presentation/widgets/material_requests/lab_invoice_details_dialog.dart test/widgets/lab_invoice_details_dialog_test.dart
git commit -m "feat(lab): حوار تفاصيل الفاتورة — يعرض كل المواد بلا قصّ"
```

---

### Task 10: الطباعة

**Files:**
- Create: `lib/features/lab/presentation/widgets/material_requests/lab_invoice_printer.dart`
- Test: `test/widgets/lab_invoice_printer_test.dart` (جديد)

**Interfaces:**
- Consumes: `MatRequest` (Task 1).
- Produces: `LabInvoicePrinter.print(MatRequest invoice) → Future<void>` — تستهلكه Task 11 (ربط زر الطباعة بالصفحة).

- [ ] **Step 1: كتابة اختبار بسيط (سيفشل)**

أنشئ `test/widgets/lab_invoice_printer_test.dart`:

```dart
// اختبار بنائي فقط: التأكد إن بناء مستند PDF لفاتورة (بعناصر متعددة) ما بيرمي
// استثناء — بلا اختبار سلوك الطباعة الفعلي (Printing.layoutPdf بيفتح حوار
// نظام حقيقي، غير قابل للاختبار الآلي بنفس أسلوب report_export.dart الحالي
// يلي ما إله اختبار مماثل لنفس السبب).

import 'package:flutter_test/flutter_test.dart';

import 'package:dt_teeth/features/lab/domain/entities/lab_material_request.dart';
import 'package:dt_teeth/features/lab/presentation/widgets/material_requests/lab_invoice_printer.dart';

void main() {
  test('buildDocument لفاتورة مستودع بعدة مواد — يبني PDF بلا استثناء', () async {
    final req = MatRequest(
      id: '1',
      status: MatRequestStatus.newRequest,
      requestedBy: 'أحمد',
      requesterType: 'lab',
      date: '2026-08-19',
      notes: 'ملاحظة',
      items: const [
        MatRequestItem(id: '1', materialName: 'زركون', quantityRequested: 10),
        MatRequestItem(id: '2', materialName: 'جبس', quantityRequested: 5),
      ],
      newItems: const [],
    );
    final bytes = await LabInvoicePrinter.buildPdfBytes(req);
    expect(bytes, isNotEmpty);
  });

  test('buildDocument لفاتورة شركة — يبني PDF بلا استثناء', () async {
    final req = MatRequest(
      id: '2',
      status: MatRequestStatus.newRequest,
      requestedBy: 'سارة',
      requesterType: 'lab',
      date: '2026-08-19',
      items: const [],
      newItems: const [
        MatRequestNewItem(id: '1', materialName: 'صمغ', quantity: 3, unit: 'علبة', companyName: 'دنتال', reason: 'سبب'),
      ],
    );
    final bytes = await LabInvoicePrinter.buildPdfBytes(req);
    expect(bytes, isNotEmpty);
  });
}
```

- [ ] **Step 2: تشغيل الاختبار والتأكد من الفشل**

Run: `flutter test test/widgets/lab_invoice_printer_test.dart`
Expected: FAIL — الملف غير موجود.

- [ ] **Step 3: إنشاء الملف**

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_invoice_printer.dart
//
// توليد وطباعة PDF لفاتورة طلب مواد — نفس نمط report_export.dart (خط عربي
// RTL متّصل، pdf+printing الموجودتان أصلاً بـ pubspec.yaml).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../domain/entities/lab_material_request.dart';

class LabInvoicePrinter {
  LabInvoicePrinter._();

  static pw.Font? _font;

  static Future<pw.Font> _loadFont() async {
    final cached = _font;
    if (cached != null) return cached;
    final data = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    final font = pw.Font.ttf(data);
    _font = font;
    return font;
  }

  /// يبني بايتات PDF للفاتورة — مستخرَجة منفصلة عن [print] كي تكون قابلة
  /// للاختبار الآلي (Printing.layoutPdf بيفتح حوار نظام حقيقي غير قابل للاختبار).
  static Future<Uint8List> buildPdfBytes(MatRequest invoice) async {
    final font = await _loadFont();
    final doc = pw.Document();
    final isFromCompany = invoice.isFromCompany;

    doc.addPage(
      pw.Page(
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('فاتورة #${invoice.id}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('التاريخ: ${invoice.date}    مقدّم الطلب: ${invoice.requestedBy}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
            pw.SizedBox(height: 18),
            if (!isFromCompany)
              pw.TableHelper.fromTextArray(
                context: context,
                headers: const ['المادة', 'الكمية', 'ملاحظة'],
                data: [for (final it in invoice.items) [it.materialName, '${it.quantityRequested}', it.notes ?? '']],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 11),
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              )
            else
              pw.TableHelper.fromTextArray(
                context: context,
                headers: const ['المادة', 'الكمية', 'الوحدة', 'الشركة', 'السبب'],
                data: [
                  for (final it in invoice.newItems)
                    [it.materialName, '${it.quantity}', it.unit, it.companyName ?? '', it.reason ?? ''],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 11),
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              ),
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text('ملاحظات: ${invoice.notes}', style: const pw.TextStyle(fontSize: 11)),
            ],
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// يفتح حوار الطباعة الأصلي للمتصفح/النظام (طباعة فعلية أو حفظ PDF).
  static Future<void> print(MatRequest invoice) async {
    final bytes = await buildPdfBytes(invoice);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: 'فاتورة_${invoice.id}.pdf',
    );
  }
}
```

- [ ] **Step 4: تشغيل الاختبار والتأكد من النجاح**

Run: `flutter test test/widgets/lab_invoice_printer_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/lab/presentation/widgets/material_requests/lab_invoice_printer.dart test/widgets/lab_invoice_printer_test.dart
git commit -m "feat(lab): طباعة الفاتورة كـ PDF (خط عربي RTL، نفس نمط تصدير التقارير)"
```

---

### Task 11: ربط الصفحة الرئيسية

**Files:**
- Modify: `lib/features/lab/presentation/pages/lab_material_requests_page.dart`

**Interfaces:**
- Consumes: كل واجهات المهام 1-10 (`LabMaterialRequestsCubit` الجديد، `LabInvoiceTypeChooserDialog`, `LabInvoiceFromWarehouseDialog`, `LabInvoiceFromCompanyDialog`, `LabInvoiceDetailsDialog`, `LabInvoicePrinter`, `LabMatRequestCard` بتوقيعه الجديد).

- [ ] **Step 1: إعادة كتابة الصفحة**

استبدل محتوى `lib/features/lab/presentation/pages/lab_material_requests_page.dart` بالكامل:

```dart
// ════════════════════════════════════════════════════════════════════════════
// lab_material_requests_page.dart  — فواتير طلب المواد (منظور المخبر)
//
// المخبر يرسل فواتير للمستودع: إما من مواد كتالوج المستودع (items[])، أو من
// شركة خارجية لمواد جديدة (new_items[]) — كل فاتورة نوع واحد بس.
//   - 4 filter chips (الكل / جديد / تم التسليم / غير متوفر)
//   - قائمة فواتير + زر "طلب فاتورة جديدة" → خطوة اختيار النوع → فورم مناسب
//
// المعمارية: UI → LabMaterialRequestsCubit → LabMaterialRequestsRepository.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/employee_role_label.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../shared/widgets/core/app_system_type.dart';
import '../../../../shared/widgets/feedback/glass_toast.dart';
import '../../../../shared/widgets/layout/app_page_action_bar.dart';
import '../../../../shared/widgets/layout/app_shell_layout.dart';
import '../../../../shared/widgets/loading/app_shimmer_card.dart';
import '../../../../shared/widgets/primitives/app_button.dart';
import '../../../../shared/widgets/primitives/app_filter_chip.dart';
import '../../domain/entities/lab_material_request.dart';
import '../../domain/repositories/lab_material_requests_repository.dart';
import '../bloc/lab_material_requests_cubit.dart';
import '../bloc/lab_material_requests_state.dart';
import '../navigation/lab_sidebar_sections.dart';
import '../widgets/material_requests/lab_invoice_details_dialog.dart';
import '../widgets/material_requests/lab_invoice_from_company_dialog.dart';
import '../widgets/material_requests/lab_invoice_from_warehouse_dialog.dart';
import '../widgets/material_requests/lab_invoice_printer.dart';
import '../widgets/material_requests/lab_invoice_type_chooser_dialog.dart';
import '../widgets/material_requests/lab_mat_request_card.dart';
import '../widgets/material_requests/lab_mat_requests_empty.dart';

/// صفحة الفواتير — تُنشئ [LabMaterialRequestsCubit] وتزوّده للـ subtree.
class LabMaterialRequestsPage extends StatelessWidget {
  const LabMaterialRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LabMaterialRequestsCubit(
        repository: sl<LabMaterialRequestsRepository>(),
      )..load(),
      child: BlocBuilder<LabMaterialRequestsCubit, LabMaterialRequestsState>(
        builder: (context, state) {
          return AppShellLayout(
            system: AppSystemType.lab,
            currentRoute: RouteNames.labMaterialRequests,
            sections: LabSidebarSections.build(context),
            pageTitle: context.l10n.materialRequests,
            pageSubtitle: context.l10n.labTopbarSubtitle,
            userRole: currentUserRoleLabel(context, fallback: context.l10n.roleLabManager),
            searchPlaceholder: context.l10n.labReqSearchHint,
            onSearchChanged: (q) =>
                context.read<LabMaterialRequestsCubit>().setSearchQuery(q),
            body: _MaterialRequestsBody(state: state),
          );
        },
      ),
    );
  }
}

class _MaterialRequestsBody extends StatelessWidget {
  const _MaterialRequestsBody({required this.state});

  final LabMaterialRequestsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.status == LabMatRequestsStatus.loading && state.requests.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.spaceLG),
        child: Column(
          children: [
            AppShimmerCard(layout: AppShimmerCardLayout.basic),
            SizedBox(height: AppSizes.spaceMD),
            AppShimmerCard(layout: AppShimmerCardLayout.basic),
            SizedBox(height: AppSizes.spaceMD),
            AppShimmerCard(layout: AppShimmerCardLayout.basic),
          ],
        ),
      );
    }

    if (state.status == LabMatRequestsStatus.error && state.requests.isEmpty) {
      return _MatRequestsError(
        message: state.errorMessage ?? l10n.error,
        onRetry: () => context.read<LabMaterialRequestsCubit>().load(),
      );
    }

    final requests = state.filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageActionBar(
            filter: AppFilterChipRow(
              options: [
                l10n.labOrdersFilterAll,
                l10n.statusNew,
                l10n.statusDelivered,
                l10n.labReqStatusUnavailable,
              ],
              selectedIndex: state.filterIndex,
              onChanged: (i) =>
                  context.read<LabMaterialRequestsCubit>().setFilter(i),
            ),
            actions: [
              AppButton.primary(
                label: '+ ${l10n.labReqNewRequest}',
                onPressed: () => _onNewInvoice(context),
                size: AppButtonSize.small,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceLG),
          if (requests.isEmpty)
            const LabMatRequestsEmpty()
          else
            for (final req in requests) ...[
              LabMatRequestCard(
                request: req,
                onTap: () => LabInvoiceDetailsDialog.show(
                  context,
                  req,
                  onPrint: () => LabInvoicePrinter.print(req),
                ),
                // الحذف مسموح فقط للفواتير "الجديدة" — الباك يرفض حذف أي فاتورة
                // بدأ تنفيذها (422)، فلا نعرض زر حذف يفشل دايماً.
                onDelete: req.status == MatRequestStatus.newRequest
                    ? () => _onDelete(context, req)
                    : null,
              ),
              const SizedBox(height: AppSizes.spaceMD),
            ],
        ],
      ),
    );
  }

  /// خطوة اختيار نوع الفاتورة ثم الفورم المناسب، وإرسالها عبر الـ Cubit.
  Future<void> _onNewInvoice(BuildContext context) async {
    final cubit = context.read<LabMaterialRequestsCubit>();
    final l10n = context.l10n;

    final type = await LabInvoiceTypeChooserDialog.show(context);
    if (type == null || !context.mounted) return;

    bool ok;
    if (type == LabInvoiceType.warehouse) {
      final r = await LabInvoiceFromWarehouseDialog.show(
        context,
        catalog: cubit.state.catalog,
        catalogError: cubit.state.catalogError,
        onRetryCatalog: cubit.loadCatalog,
      );
      if (r == null || !context.mounted) return;
      ok = await cubit.addRequestFromWarehouse(items: r.items, notes: r.notes);
    } else {
      final r = await LabInvoiceFromCompanyDialog.show(context);
      if (r == null || !context.mounted) return;
      ok = await cubit.addRequestFromCompany(
        companyName: r.companyName,
        items: r.items,
        notes: r.notes,
      );
    }

    if (!context.mounted) return;
    if (ok) {
      GlassToast.show(context, message: l10n.labReqSentSuccess, icon: Icons.check_circle_rounded);
    } else {
      GlassToast.show(context, message: cubit.state.errorMessage ?? l10n.error);
    }
  }

  /// تأكيد ثم حذف فاتورة عبر الـ Cubit.
  Future<void> _onDelete(BuildContext context, MatRequest req) async {
    final cubit = context.read<LabMaterialRequestsCubit>();
    final l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labReqDeleteTitle),
        content: Text(l10n.labReqDeleteConfirm(req.id)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await cubit.delete(req.id);
    if (!ok && context.mounted) {
      GlassToast.show(context, message: cubit.state.errorMessage ?? l10n.error);
    }
  }
}

class _MatRequestsError extends StatelessWidget {
  const _MatRequestsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/lab/presentation/pages/lab_material_requests_page.dart
git commit -m "feat(lab): اربط صفحة الفواتير بخطوة اختيار النوع + الفورمين الجديدين + تفاصيل/طباعة الفاتورة"
```

---

### Task 12: تحقّق نهائي — كامل الاختبارات + analyze + screenshots

**Files:** لا تعديل كود — تحقّق فقط.

- [ ] **Step 1: تشغيل كامل مجموعة الاختبارات**

Run: `flutter test`
Expected: PASS بالكامل — بما فيها كل الاختبارات القديمة (لا انحدار) + كل الاختبارات الجديدة من المهام 1-10.

- [ ] **Step 2: `flutter analyze` نظيف بالكامل**

Run: `flutter analyze lib/`
Expected: No issues found — تحقّق خاص: لا `unused_import`/`unused_element` (مثال: أي استيراد لـ `lab_mat_request_dialog.dart` أو `LabMaterialRequestResult` نُسي بمكان ما).

- [ ] **Step 3: بناء نسخة الويب Release**

Run: `flutter build web --release --no-web-resources-cdn --no-wasm-dry-run`
Expected: بناء ناجح.

- [ ] **Step 4: screenshots للتحقق البصري (استخدم مهارة `run-dt-teeth`)**

Run: `node .claude\skills\run-dt-teeth\driver.mjs --serve build\web /lab/material-requests`
Expected: `✓`، وصورة تُظهر:
- عنوان الصفحة "الفواتير" وزر "+ طلب فاتورة جديدة".
- فتح الزر يعرض خطوة اختيار (بطاقتين: من المستودع / من شركة).
- بطاقات الفواتير (لو فيه بيانات mock/حقيقية) تعرض عدد المواد ونوع الفاتورة.

(لو الصفحة فاضية من بيانات حقيقية بالبيئة المحلية، افتح الفورمين يدوياً عبر الزر وتأكد بصرياً من: إضافة أكتر من مادة بفورم المستودع (سلة)، وإضافة أكتر من صف مادة بفورم الشركة (`+ إضافة مادة`) مع بقاء اسم الشركة حقل واحد فوق.)

- [ ] **Step 5: لو في أي مشكلة — أصلحها بنفس الملف المعني من مهمة 1-11، ثم أعد الخطوات 1-4**

---

## Self-Review

**تغطية السبك:** القسم "عقد الباك إند" ↔ Task 2/3 (JSON مو FormData، `_fromJson` كامل). القسم 1 (التسمية) ↔ Task 5. القسم 2 (الكيانات) ↔ Task 1. القسم 3 (الـ Repository) ↔ Task 2/3. القسم 4 (الـ Datasource) ↔ Task 2. القسم 5 (الـ Cubit/State) ↔ Task 4. القسم 6 (الواجهة) ↔ Task 6/7/8/9/11. القسم 7 (الطباعة) ↔ Task 10. القسم "خارج النطاق" — لم يُلمَس بأي مهمة، متوافق.

**فحص Placeholders:** لا "TBD"/"لاحقاً" بأي خطوة — كل كتلة كود كاملة. تحقّقت مسبقاً (`grep` على `pubspec.yaml`) إن `mocktail` هي الحزمة الوحيدة المتاحة لاختبارات mock/cubit بهالمشروع — كل اختبارات Task 2 و4 مبنية عليها مباشرة (`Mock implements Dio` بما إن `Dio` نسخة 5.8.0 صنف `abstract class` قابل للـ mock)، بلا حاجة لأي حزمة جديدة أو مسار بديل مبهم.

**اتساق الأنواع:** `({int materialId, int quantity, String? notes})` و`({String materialName, int quantity, String unit, String? reason})` (records) تُستخدم بنفس التوقيع بالضبط بين Repository (Task 2/3)، Cubit (Task 4)، الفورمات (Task 7/8)، والصفحة (Task 11) — تم التحقق يدوياً من كل استخدام.
