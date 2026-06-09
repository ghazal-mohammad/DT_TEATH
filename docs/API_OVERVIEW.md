# 📡 DT.Teeth — نظرة عامة على كل الـ API المطلوبة من الباك-اند

> **للفريق الباك-اند** — نظرة عامة (high-level) فقط.
> هاد الملف بيعطيكي **قائمة شاملة بكل الـ endpoints** يلي الفرونت محتاجها، مقسّمة حسب القسم.
> **التفاصيل** (شكل الـ request/response بالضبط، الحقول، رموز الأخطاء) منرسلها endpoint-by-endpoint لما نوصلها.
> تاريخ: 2026-06-06 — Base URL الحالي (Dev): `http://localhost:8000`

---

## 🟢 جاهز ومربوط فعلاً (موثّق بالكامل)

هاي الـ endpoints الفرونت مربوط عليها وشغّالة. مرجع التفاصيل: [`API_CONTRACT_AUTH.md`](API_CONTRACT_AUTH.md).

### 1) المصادقة (Auth) — للموظفين (مخبر + مستودع + باقي الأدوار)
| # | Endpoint | Method | الوظيفة |
|---|----------|--------|---------|
| 1 | `/api/employee/sendVerification` | POST | إرسال كود تحقق للإيميل عند أول تسجيل |
| 2 | `/api/employee/verifyCode` | POST | التحقق من الكود وتعليم الإيميل "مؤكَّد" |
| 3 | `/api/employee/setPassword` | POST | تعيين كلمة المرور بعد التحقق |
| 4 | `/api/employee/login` | POST | تسجيل الدخول (يرجع token + role للتوجيه) |
| 5 | `/api/employee/logout` | POST | تسجيل الخروج (محمي بـ Bearer) |

### 2) الملف الشخصي (Profile) — نفس الـ endpoints للمخبر والمستودع
| # | Endpoint | Method | الوظيفة |
|---|----------|--------|---------|
| 6 | `/api/employee/showProfile` | GET | جلب بيانات الموظف الحالي (محمي) |
| 7 | `/api/employee/editProfile` | POST (multipart) | تعديل البيانات + رفع صورة بروفايل |

---

## 🟡 مطلوبة — لسا شغّالين على بيانات وهمية (mock) ومحتاجينها

كل القسمين تحت (المستودع + المخبر) حالياً بيشتغلوا على mock data. هاي العمليات يلي بدنا API لها.
الأسماء مقترحة — حكيلي شو الأسماء الفعلية بالـ Laravel routes ومنحدّثها عندنا.

### 3) المستودع — المواد (Materials) · CRUD كامل
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/warehouse/materials` | GET | جلب كل المواد (مع دعم فلترة بالفئة/الحالة + بحث) |
| `/api/warehouse/materials/{id}` | GET | جلب مادة واحدة |
| `/api/warehouse/materials` | POST | إضافة مادة جديدة |
| `/api/warehouse/materials/{id}` | PUT/PATCH | تعديل مادة |
| `/api/warehouse/materials/{id}` | DELETE | حذف مادة |

> **حقول المادة:** name، category، quantity، unit، min_stock، expiry_date (اختياري)، supplier (اختياري)، price (اختياري)، notes (اختياري). الحالة (متوفر/ينفد/نفد) تُحسب من quantity مقابل min_stock.

### 4) المستودع — لوحة التحكم (Dashboard)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/warehouse/dashboard/stats` | GET | عدّادات: إجمالي المواد، نفاد مخزون، طلبيات واردة، قرب انتهاء صلاحية |
| `/api/warehouse/dashboard/top-requested` | GET | جدول "المواد الأكثر طلباً" |
| `/api/warehouse/dashboard/expiring` | GET | جدول "مواد ستنتهي صلاحيتها قريباً" |

### 5) المستودع — الطلبيات (Orders)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/warehouse/orders` | GET | قائمة الطلبيات (فلترة بالحالة: جديد/مُلبّى/ناقص) |
| `/api/warehouse/orders/{id}` | GET | تفاصيل طلبية |
| `/api/warehouse/orders/{id}/status` | PUT/PATCH | تغيير حالة الطلبية (موافقة/تلبية/رفض) |

> **حقول الطلبية:** order_number، material_name، quantity، unit، requester (اسم الطالب)، date، status، notes.

### 6) المستودع — الفواتير (Invoices)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/warehouse/invoices` | GET | قائمة الفواتير (نوع: شراء/استهلاك) + ملخص أسبوعي |
| `/api/warehouse/invoices/{id}` | GET | تفاصيل فاتورة |
| `/api/warehouse/invoices` | POST | إنشاء فاتورة |

> **حقول الفاتورة:** invoice_number، type (purchase/usage)، material_name، quantity، unit، unit_price، total، date، supplier (اختياري)، notes.
> **ملخص أسبوعي:** إجمالي المشتريات، إجمالي الاستهلاك، خسائر (انتهاء صلاحية).

### 7) المستودع — التقارير (Reports)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/warehouse/reports/top-materials` | GET | أكثر 10 مواد طلباً (rank، اسم، فئة، عدد طلبات، تكلفة) |
| `/api/warehouse/reports/monthly-orders` | GET | عدد الطلبيات شهرياً (للرسم البياني) |
| `/api/warehouse/reports/financial-summary` | GET | ملخص مالي (مشتريات/استهلاك/خسائر) |

### 8) المخبر — لوحة التحكم (Dashboard)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/lab/dashboard/stats` | GET | عدّادات: عاجل اليوم، جاهز، قيد التصنيع، طلبات جديدة + نسبة الإنجاز |
| `/api/lab/dashboard/today-orders` | GET | جدول طلبات اليوم (فلترة: الكل/جديد/قيد التصنيع/جاهز) |
| `/api/lab/dashboard/due-today` | GET | طلبات تنتهي اليوم (التنبيه العلوي) |

### 9) المخبر — طلبات الأطباء (Doctor Orders)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/lab/orders` | GET | قائمة الطلبات (فلترة بالحالة والأولوية) |
| `/api/lab/orders/{id}` | GET | تفاصيل طلب |
| `/api/lab/orders/{id}/status` | PUT/PATCH | تغيير الحالة (جديد → قيد التصنيع → جاهز) |

> **حقول الطلب:** order_id، doctor_name، type (تلبيسة/جسر/طقم…)، material (PFM/Zirconia/E-max…)، tooth، due_date، priority (urgent/medium/normal)، status.

### 10) المخبر — إدارة المخبريين (Technicians)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/lab/technicians` | GET | قائمة المخبريين (اسم، الوردية، المهمة الحالية، مشغول/متاح) |
| `/api/lab/technicians/{id}` | GET | تفاصيل مخبري |
| `/api/lab/technicians` | POST | إضافة مخبري |
| `/api/lab/technicians/{id}` | PUT/PATCH | تعديل مخبري |
| `/api/lab/technicians/{id}` | DELETE | حذف/تعطيل مخبري |

### 11) المخبر — التقارير (Reports)
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/lab/reports` | GET | بيانات تقارير المخبر (إنتاجية، إنجاز، حسب الطبيب/النوع) |

---

## 🔔 مشترك بين القسمين — الإشعارات (Notifications)

نفس البنية للمخبر والمستودع (تختلف الفئات فقط).
| Endpoint مقترح | Method | الوظيفة |
|----------------|--------|---------|
| `/api/notifications` | GET | قائمة الإشعارات (مقروء/غير مقروء) + عدّاد |
| `/api/notifications/{id}/read` | PUT/PATCH | تعليم إشعار كمقروء |
| `/api/notifications/read-all` | PUT/PATCH | تعليم الكل كمقروء |

> **فئات إشعارات المستودع:** نفاد مخزون، قرب انتهاء صلاحية، طلبية جديدة، عام.
> **حقول الإشعار:** title، body، time، category، is_read، action_label (اختياري).

---

## ⚙️ الإعدادات (Settings) — للتأكيد

في صفحات إعدادات للمخبر والمستودع. بدنا نعرف:
- هل في إعدادات بتنحفظ بالسيرفر (مثلاً حد أدنى افتراضي، تفضيلات تنبيهات)؟ → بدها endpoints `GET/PUT /api/settings`.
- أو كلها client-side (لغة/ثيم محلية)؟ → ما بدها API.

---

## 📌 ملاحظات عامة للربط
1. **التوكن:** كل الـ endpoints المحمية بتاخد `Authorization: Bearer <token>` (عنا interceptor بيضيفه تلقائياً).
2. **اللغة:** منرسل `Accept-Language: ar | en` — يا ريت الرسائل والبيانات النصية تتأثر فيها لو ممكن.
3. **شكل الـ response:** يا ريت موحّد — `{ "data": ... }` للنجاح، و`{ "message": ... }` للأخطاء (مثل ما هو بالـ profile).
4. **الترقيم (pagination):** القوائم الطويلة (مواد، طلبيات، فواتير، إشعارات) يا ريت تدعم `page` و`per_page`.
5. **التواريخ:** بصيغة ISO 8601 (`2026-05-10` أو كامل مع الوقت).

---

**أولوية الربط القادمة (مقترحة):** المواد (CRUD) → طلبيات المستودع → لوحات التحكم → الإشعارات → الفواتير/التقارير.
