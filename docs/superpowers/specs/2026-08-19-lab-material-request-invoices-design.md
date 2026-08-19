# فواتير طلب المواد بالمخبر (Lab Material Request Invoices) — Design

**التاريخ:** 2026-08-19
**النطاق:** نظام المخبر فقط (Lab). لا تعديل على نظام المستودع — الميزة تستهلك نفس الموارد الموجودة أصلاً بالباك إند من جهة المخبر (`labManager/*`).

## المشكلة

صفحة "طلبات المستودع" الحالية بالمخبر (`/lab/material-requests`) عندها قيود اصطناعية غير موجودة بالباك إند:

1. **فورم إضافة طلب واحد بمادة وحدة بس** — بينما الباك إند (`POST labManager/addMaterialRequest`) بيقبل مصفوفتين بنفس الطلب: `items[]` (مواد من كتالوج المستودع، بـ `material_id`) و`new_items[]` (مواد جديدة من شركة، بـ `material_name`+`company_name`).
2. **قراءة الرد بتاخد أول مادة بس وترمي الباقي** (`_fromJson` بملف `remote_lab_material_requests_repository.dart`) — فلو الطلب فيه أكتر من مادة، المخبري ما بيقدر يشوفها.
3. **الطلب بينترسل كـ `FormData` (multipart)** بينما التوثيق الرسمي (Hoppscotch collection، مثال حقيقي لـ `labManager/addMaterialRequest`) بيحدد `Content-Type: application/json` بجسم JSON خام — تعارض فعلي بين الكود والتوثيق.
4. لو فشل تحميل كتالوج مواد المستودع (`showAllWarehouseMaterials`)، الفشل بينتبلع بصمت والمستخدم ما بيعرف ليش "خيار المستودع" مش شغّال — هيك الموضوع يلي وصف المستخدم إنه "ما بيقدر ياخد من المستودع".
5. **endpoint مفرد اتنين معرّفين بالباك إند وغير مستخدمين إطلاقاً**: `labManager/showWarehouseMaterial/{id}` و`labManager/showMaterialRequest/{id}`.

**لا يوجد أي API جديد مطلوب من الباك إند.** التحقق تم بقراءة كامل ملف Hoppscotch collection المرفق (300 endpoint، من أوله لآخره) + لقطات شاشة من كولكشن "Lab Leader" أكّدت تطابق نفس القائمة بالضبط. الـ 6 endpoints يلي يلزمها "ربط" هي:

| Endpoint | Method | الحالة الحالية |
|---|---|---|
| `labManager/showAllWarehouseMaterials` | GET | مستخدم، فشله بيتبلع بصمت |
| `labManager/showWarehouseMaterial/{id}` | GET | **غير مستخدم إطلاقاً** |
| `labManager/showAllMaterialRequests` | GET | مستخدم، بس بيقص لأول مادة |
| `labManager/addMaterialRequest` | POST | مستخدم، بس FormData + مادة وحدة |
| `labManager/showMaterialRequest/{id}` | GET | **غير مستخدم إطلاقاً** |
| `labManager/deleteMaterialRequest/{id}` | POST | مستخدم وسليم — بلا تعديل |

## عقد الباك إند (موثّق، مو تخمين)

### إنشاء فاتورة — `POST /api/labManager/addMaterialRequest`

`Content-Type: application/json` (مو FormData). مثال حقيقي من التوثيق:

```json
{
    "notes": "طلب مواد شهري",
    "items": [
        { "material_id": 1, "quantity_requested": 10, "notes": "يفضل نفس الشركة السابقة" },
        { "material_id": 2, "quantity_requested": 5, "notes": null }
    ],
    "new_items": [
        {
            "material_name": "صمغ طبي خاص",
            "quantity": 3,
            "unit": "علبة",
            "company_name": "شركة دنتال سوريا",
            "reason": "نحتاج هذه المادة لطلبات جديدة"
        }
    ]
}
```

كل الحقول عدا `material_id`/`material_name`/`quantity`/`quantity_requested` اختيارية. `items[]` و`new_items[]` يقدروا ينبعتوا سوا تقنياً — **بس القرار المعتمد (تأكد مع المستخدم): كل فاتورة بهالتطبيق نوع واحد بس** (إما `items[]` فيها مواد فقط، أو `new_items[]` فيها مواد فقط، مو الاثنين سوا بنفس الطلب).

### قراءة الفواتير — `GET /api/labManager/showAllMaterialRequests` و`GET /api/labManager/showMaterialRequest/{id}`

الشكل موثّق ومُتحقّق منه فعلياً عبر كود جهة المستودع الشغّال حالياً (`lib/features/warehouse/domain/entities/warehouse_request.dart` — نفس المورد الخلفي `MaterialRequestResource`، فقط برؤية مختلفة labManager/warehouseManager):

```json
{
  "id": 12,
  "status": "new",
  "requester": { "name": "..." },
  "requester_type": "...",
  "notes": "طلب مواد شهري",
  "items": [
    { "id": 1, "material": "اسم المادة", "quantity_requested": 10, "status": "...", "notes": "..." }
  ],
  "new_items": [
    { "id": 1, "material_name": "صمغ طبي خاص", "quantity": 3, "unit": "علبة",
      "company_name": "شركة دنتال سوريا", "reason": "...", "status": "..." }
  ],
  "created_at": "2026-08-19 10:00:00"
}
```

ملاحظة أسماء الحقول: `items[].material` (بلا `_name`) مقابل `new_items[].material_name` — فرق حقيقي موجود بالباك إند، مو خطأ نسخ.

`status` نفس قيم enum الباك إند الموجودة أصلاً (`new`/`pending`/`completed`/`rejected`/`cancelled`) — يبقى نفس `_mapStatus` الحالي بـ `remote_lab_material_requests_repository.dart` بلا تغيير (`pending→inProgress`, `completed→delivered`, `rejected→unavailable`, `cancelled→cancelled`, غير ذلك→`newRequest`).

### حذف — `POST /api/labManager/deleteMaterialRequest/{id}`

بلا تغيير عن الحالي.

## التصميم

### 1) التسمية

أسماء الكلاسات/الملفات بالكود (`MatRequest`, `LabMaterialRequestsRepository`, `lab_material_requests_*.dart`...) **تبقى كما هي** — تطابق اسم المورد بالباك إند (`materialRequest`)، وتغييرها كان diff ضخم بلا فائدة حقيقية. **كل نص يواجه المستخدم يتغيّر لـ "فاتورة"**:

| المكان | النص الحالي | الجديد |
|---|---|---|
| عنوان الصفحة / السايدبار | "طلبات المستودع" | "الفواتير" |
| زر الإضافة | "+ طلب مادة جديدة" | "+ طلب فاتورة جديدة" |
| بطاقة الطلب | — | تُعرض كـ "فاتورة #12" بدل "طلب #12" |

مفاتيح l10n الحالية (`materialRequests`, `labReqNewRequest`, ...) تُحدَّث نصوصها العربية مباشرة (بلا حاجة لمفاتيح جديدة إلا لعناصر الواجهة الجديدة فعلاً — قائمة أدناه).

### 2) الكيانات (Domain Entities) — إعادة بناء لتحمل كل عناصر الفاتورة

بملف `lib/features/lab/domain/entities/lab_material_request.dart` — استبدال `MatRequest` المسطّح (مادة واحدة) بثلاث كلاسات تطابق شكل `WarehouseRequest`/`WarehouseRequestItem`/`WarehouseNewItem` (نفس المورد الخلفي بالضبط، فقط جهة labManager):

```dart
enum MatRequestStatus { newRequest, inProgress, delivered, unavailable, cancelled } // بلا تغيير

class MatRequestItem {              // مادة من كتالوج المستودع (items[])
  final String id;
  final String materialName;        // من json['material']
  final int quantityRequested;
  final String status;
  final String? notes;
}

class MatRequestNewItem {           // مادة جديدة من شركة (new_items[])
  final String id;
  final String materialName;        // من json['material_name']
  final int quantity;
  final String unit;
  final String? companyName;
  final String? reason;
  final String? status;
}

class MatRequest {
  final String id;
  final MatRequestStatus status;
  final String requestedBy;         // من json['requester']['name']
  final String requesterType;       // من json['requester_type']
  final String date;                // من json['created_at']، نفس منطق .split(' ').first الحالي
  final String? notes;              // ملاحظة الفاتورة العامة (top-level)
  final List<MatRequestItem> items;
  final List<MatRequestNewItem> newItems;

  int get itemsCount => items.length + newItems.length;
  bool get isFromWarehouse => items.isNotEmpty;   // لعرض أيقونة/تصنيف النوع بالبطاقة
  bool get isFromCompany => newItems.isNotEmpty;
}
```

**كسر توافقي متعمّد:** `MatRequest.material`/`.quantity`/`.unit`/`.company`/`.reason`/`.labOrderId` (الحقول المسطّحة القديمة) تُحذف نهائياً — كل مستهلك لهاي الحقول (البطاقة، الديالوغ القديم) يُعاد بناؤه بنفس المهمة. لا حاجة لإبقاء توافق خلفي هون لأنه لا يوجد استخدام خارج هالميزة (تحقّق بالخطة عبر grep).

`WarehouseMaterialRef` (كتالوج مواد المستودع للمخبري) يبقى كما هو — يُستخدم لتعبئة قائمة الاختيار بمسار "من المستودع".

### 3) الـ Repository — عمليات إنشاء منفصلة لكل نوع

```dart
abstract class LabMaterialRequestsRepository {
  List<MatRequest>? get cached;
  Future<List<MatRequest>> getAll();
  Future<MatRequest> getOne(String id);                    // NEW — يستهلك showMaterialRequest/{id}
  Future<List<WarehouseMaterialRef>> getWarehouseMaterials();
  Future<WarehouseMaterialRef> getWarehouseMaterial(int id); // NEW — يستهلك showWarehouseMaterial/{id}

  Future<void> addRequestFromWarehouse({
    required List<({int materialId, int quantity, String? notes})> items,
    String? notes,
  });

  Future<void> addRequestFromCompany({
    required String companyName,
    required List<({String materialName, int quantity, String unit, String? reason})> items,
    String? notes,
  });

  Future<void> delete(String id);
  Stream<List<MatRequest>> watchAll();
}
```

`addRequestFromWarehouse` تبني `{ if (notes...) 'notes': notes, 'items': [...] }`. `addRequestFromCompany` تبني `{ if (notes...) 'notes': notes, 'new_items': [ {material_name, quantity, unit, company_name: companyName (نفس القيمة مكرّرة بكل عنصر), if (reason...) 'reason': reason} ] }` — اسم الشركة يُكتب مرة وحدة بالواجهة، ويتكرّر تلقائياً بكل عنصر بجسم الطلب (هيك الباك إند طالبها بالضبط — حقل لكل عنصر).

### 4) الـ Datasource — JSON مو FormData

بملف `lab_material_requests_remote_datasource.dart`: دالة `create` تتغيّر من:
```dart
_dio.post(ApiEndpoints.labManagerAddMaterialRequest, data: FormData.fromMap(body));
```
لـ:
```dart
_dio.post(ApiEndpoints.labManagerAddMaterialRequest, data: body); // Dio يشفّر Map كـ JSON افتراضياً لما contentType = application/json (مضبوطة أصلاً بـ DioClient.build())
```
مع التحقّق (بخطة التنفيذ) إن `DioClient` الأساسي فعلاً مضبوط بـ `Content-Type: application/json` افتراضياً (الأرجح نعم — باقي المستودع بيرسل JSON بنفس الطريقة لـ `addPurchaseInvoice` مثلاً).

إضافة دالتين:
```dart
Future<Map<String, dynamic>> getOne(Object id) => _dio.get(ApiEndpoints.labManagerShowMaterialRequest(id)) ...;
Future<Map<String, dynamic>> getWarehouseMaterial(Object id) => _dio.get(ApiEndpoints.labManagerShowWarehouseMaterial(id)) ...;
```
(الـ endpoints الاتنين معرّفين أصلاً بـ `endpoints.dart` — بلا حاجة لإضافة شي هناك.)

### 5) الـ Cubit/State

`LabMaterialRequestsCubit` يفقد `addRequest(...)` القديمة، ويكسب `addRequestFromWarehouse(...)`/`addRequestFromCompany(...)` (نفس نمط `Future<bool>` + تحديث `filterIndex: 0` بعد النجاح). كمان: **فشل تحميل الكتالوج ما عاد يتبلع بصمت** — `LabMaterialRequestsState` يكسب حقل `catalogError` منفصل عن `errorMessage` (الأخير خاص بتحميل قائمة الفواتير نفسها)، وتظهر رسالة واضحة بخطوة "من المستودع" لو الكتالوج فشل بالتحميل، مع زر إعادة محاولة.

### 6) الواجهة

**صفحة القائمة** (`lab_material_requests_page.dart`): العنوان "الفواتير"، الزر "+ طلب فاتورة جديدة". `LabMatRequestCard` تُعاد كتابتها لتعرض: رقم الفاتورة، badge الحالة، badge النوع (مستودع/شركة عبر `isFromWarehouse`/`isFromCompany`)، عدد المواد (`itemsCount`)، تاريخ ومقدّم الطلب. الدوس على البطاقة يفتح `LabInvoiceDetailsDialog` (جديد) يعرض كل عناصر `items`/`newItems` بالكامل (نفس نمط `WarehouseRequestDetailsDialog` الموجود بالمستودع، بدون أزرار إجراءات لأن المخبري هون مُنشئ الطلب مو مُنفّذه). زر الحذف يبقى بنفس شرط `status == newRequest`.

**فتح "طلب فاتورة جديدة"** يعرض خطوة اختيار أولى (بطاقتين): "من مواد المستودع" / "من شركة (مادة جديدة)".

**فورم "من المستودع"** (`LabInvoiceFromWarehouseDialog`، جديد): حقل بحث فوق قائمة `catalog` (من `WarehouseMaterialsCubit`/الكتالوج المحمّل)، كل صف بزر "+ إضافة" يضيفه لسلة أسفل الشاشة مع حقل كمية رقمي قابل للتعديل وزر حذف من السلة. حقل ملاحظات عام اختياري. زر الإرسال معطّل لحد ما يصير فيه عنصر واحد ع الأقل بكمية > 0.

**فورم "من شركة"** (`LabInvoiceFromCompanyDialog`، جديد): حقل اسم الشركة (إلزامي، مرة وحدة أعلى الفورم)، تحته قائمة صفوف قابلة للتكرار (زر "+ إضافة مادة" يضيف صف جديد، كل صف: اسم المادة إلزامي + كمية إلزامية + وحدة (dropdown من `kMatRequestUnits` الموجودة) + سبب اختياري لكل صف)، بحد أدنى صف واحد. حقل ملاحظات عام اختياري.

`LabMaterialRequestDialog` القديم (مادة وحدة) **يُحذف بالكامل** ويستبدل بالثلاثة أعلاه (خطوة الاختيار + الفورمين).

### 7) طباعة الفاتورة

المشروع عنده أصلاً حزمتا `pdf`/`printing` (مستخدمتان بـ `lib/shared/widgets/reports/report_export.dart` لتصدير التقارير) — بلا حاجة لحزمة جديدة، نفس النمط بالضبط:

- زر "طباعة" جديد داخل `LabInvoiceDetailsDialog` (تفاصيل الفاتورة).
- ملف جديد `lib/features/lab/presentation/widgets/material_requests/lab_invoice_printer.dart` — دالة `LabInvoicePrinter.print(MatRequest invoice)`:
  - يحمّل نفس خط `assets/fonts/NotoNaskhArabic-Regular.ttf` (نفس آلية `_loadFont` بـ `ReportExporter` — كاش ثابت بالذاكرة).
  - يبني `pw.Document` بصفحة واحدة RTL: ترويسة (رقم الفاتورة `#id`، الحالة، التاريخ، مقدّم الطلب)، ثم جدول المواد (`pw.TableHelper.fromTextArray`) — أعمدة تختلف حسب النوع:
    - فاتورة مستودع (`items`): المادة، الكمية المطلوبة، ملاحظة.
    - فاتورة شركة (`newItems`): المادة، الكمية، الوحدة، اسم الشركة (يُطبع مرة وحدة بالترويسة إذا كانت نفس القيمة لكل العناصر — الحالة الشائعة)، السبب.
  - ملاحظة الفاتورة العامة (`notes`) إن وُجدت، أسفل الجدول.
  - يستدعي `Printing.layoutPdf(onLayout: (format) async => doc.save(), name: 'فاتورة_${invoice.id}.pdf')` — يفتح حوار الطباعة الأصلي للمتصفح/النظام مباشرة (طباعة فعلية أو حفظ PDF)، بخلاف `sharePdf` المستخدمة بالتقارير (تلك تفتح قائمة مشاركة/حفظ، مو حوار طباعة).
- اختبار: تحقّق إن `LabInvoicePrinter.print` يُستدعى عند الضغط على الزر (mock/stub على مستوى الاستدعاء — بلا حاجة لفحص محتوى PDF الفعلي، بما إنه لا يوجد اختبار مشابه لـ `ReportExporter` بالمشروع أصلاً لنفس السبب: توليد PDF حقيقي بطيء وهش بالاختبارات).

### 8) الاختبارات

كل التغييرات مغطّاة بـ widget/unit tests جديدة (مطابقة لأسلوب المشروع الحالي — `mocktail` + تسجيل/إلغاء تسجيل بـ `sl`، أمثلة موجودة بـ `test/lab_order_process_dialog_test.dart` ومشابهاتها):
- Entity parsing: `MatRequest.fromJson`/`MatRequestItem.fromJson`/`MatRequestNewItem.fromJson` على أمثلة JSON حقيقية (من هالسبك) — يشمل حالة فاتورة بعدة مواد (يتأكد ما عاد يقتصر على أول عنصر).
- Repository: `addRequestFromWarehouse`/`addRequestFromCompany` يبنو جسم الطلب الصحيح (JSON مو FormData، مفاتيح مطابقة تماماً للتوثيق).
- Cubit: نجاح/فشل كل عملية، `catalogError` عند فشل تحميل الكتالوج.
- Widget: كل من فورمي الإضافة (تحقق الحقول، تفعيل/تعطيل زر الإرسال، بناء السلة بمسار المستودع)، `LabMatRequestCard` (عرض عدد المواد والنوع)، `LabInvoiceDetailsDialog`.

## خارج النطاق

- أي تعديل على جهة المستودع (`WarehouseRequest*`, صفحة `warehouse_orders_page.dart`) — الباك إند نفسه، والمستودع أصلاً بيعرض كل العناصر بشكل صحيح.
- دمج `items[]` و`new_items[]` بنفس الفاتورة — قرار معتمد: نوع واحد لكل فاتورة.
- ترجمة إنجليزية لأي نص جديد بهالميزة تتبع نفس نمط ملفات `app_en.arb`/`app_ar.arb` الموجود، بلا تصميم إضافي.
- أي منطق تسعير/فوترة مالية حقيقية — "فاتورة" هون مصطلح واجهة فقط لنفس مورد `materialRequest`، مو نظام محاسبي جديد.
