# 📡 API Contract — Auth Flow (Feature 3)

> **للفريق الباك-اند** — الإصدار 1.0 — 2026-04-24
> المسؤولة: شام
> المرجع: `DT_Teeth_Technical_Decision_Guide_v5.md`

---

## 📋 نظرة عامة

هذا المستند يحدّد بدقة **كل الـ endpoints** اللي يحتاجها الفرونت لتنفيذ Auth flow في DT.Teeth.

**الـ Flow الكامل:**
```
Splash → Email Entry → Verify OTP → Set Password → Dashboard
         (1 API)       (1 API)     (1 API)        (redirect)
```

**عدد الـ endpoints المطلوبة:** 4 (+ 1 refresh اختياري)

**Base URL المقترح:** `https://api.dtteeth.com/v1`

---

## 🔒 مبادئ أمنية

1. **لا كشف وجود الإيميل**: حتى لو الإيميل غير مسجّل، الـ response لـ `/request-code` يكون موحّد (200 OK).
2. **Rate limiting إجباري**:
   - `/request-code`: 5 محاولات/ساعة لكل IP
   - `/verify-code`: 10 محاولات/ساعة لكل IP + قفل بعد 5 محاولات فاشلة متتالية
   - `/set-password`: 3 محاولات/ساعة لكل temp_token
3. **Tokens**: JWT مع expiration مناسب
   - `access_token`: 15 دقيقة
   - `refresh_token`: 30 يوم
   - `temp_token` (بين verify و set-password): 10 دقائق
4. **OTP**:
   - 6 أرقام (0-9)
   - صلاحية 5 دقائق
   - استخدام مرة واحدة فقط (invalidate بعد verify ناجح)

---

## 🛣️ Endpoints

### 1️⃣ `POST /auth/request-code` — إرسال OTP للإيميل

**المستخدم يطلب كود تحقق للإيميل.**

#### Request

```http
POST /api/v1/auth/request-code
Content-Type: application/json
Accept-Language: ar  (أو en)
X-Client-Version: 1.0.0

{
  "email": "user@example.com"
}
```

#### Response — 200 OK (دائماً، حتى لو الإيميل غير موجود)

```json
{
  "status": "ok",
  "message": "إذا كان هذا البريد مسجّلاً، فقد تم إرسال كود التحقق",
  "expires_in": 300
}
```

**ملاحظة مهمة:**
- لو الإيميل موجود → الباك-اند يرسل إيميل فعلياً مع الكود
- لو الإيميل غير موجود → الباك-اند يرجع نفس الـ response **بدون إرسال أي إيميل**
- **لا تكشف المعلومة للمستخدم** — security by obscurity

#### Response — 429 Too Many Requests

```json
{
  "status": "rate_limited",
  "message": "محاولات كثيرة. حاول مرة أخرى بعد ساعة.",
  "retry_after": 3600
}
```

#### Response — 400 Bad Request (إيميل غير صحيح الصيغة)

```json
{
  "status": "invalid_email",
  "message": "صيغة البريد الإلكتروني غير صحيحة"
}
```

---

### 2️⃣ `POST /auth/verify-code` — التحقق من OTP

**بعد استلام الكود بالإيميل، المستخدم يدخله هنا.**

#### Request

```http
POST /api/v1/auth/verify-code
Content-Type: application/json

{
  "email": "user@example.com",
  "code": "123456"
}
```

#### Response — 200 OK (نجاح)

```json
{
  "status": "ok",
  "temp_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 600,
  "user_preview": {
    "full_name": "شام المحمد",
    "role": "lab_manager"
  }
}
```

**الـ temp_token:**
- صالح لمدة 10 دقائق فقط
- يُستخدم **فقط** في `/set-password` القادم
- لا يعطي صلاحية الوصول لأي endpoint آخر

**`user_preview`** (اختياري لكن موصى):
- يعرض اسم المستخدم في شاشة Set Password (UX أفضل)
- لا يحتوي معلومات حسّاسة

#### Response — 400 Bad Request (كود خطأ)

```json
{
  "status": "invalid_code",
  "message": "الكود غير صحيح. يرجى التحقق والمحاولة مجدداً.",
  "attempts_remaining": 3
}
```

#### Response — 410 Gone (كود انتهت صلاحيته)

```json
{
  "status": "code_expired",
  "message": "انتهت صلاحية الكود. الرجاء طلب كود جديد."
}
```

#### Response — 423 Locked (تم قفل المحاولات)

```json
{
  "status": "locked",
  "message": "تم قفل الحساب مؤقّتاً لكثرة المحاولات الفاشلة. حاول بعد 15 دقيقة.",
  "locked_until": "2026-04-24T14:30:00Z"
}
```

---

### 3️⃣ `POST /auth/set-password` — إنشاء كلمة المرور + تسجيل دخول

**الخطوة الأخيرة في الـ flow — المستخدم ينشئ كلمة سر ويدخل للنظام.**

#### Request

```http
POST /api/v1/auth/set-password
Content-Type: application/json
Authorization: Bearer <temp_token>

{
  "password": "MyStr0ngP@ss",
  "password_confirmation": "MyStr0ngP@ss"
}
```

**الشروط من الفرونت (محققة مسبقاً):**
- `password.length >= 8`
- `password == password_confirmation`

**الشروط المطلوبة من الباك-اند (additional):**
- `password` ليست في قائمة كلمات المرور الشائعة (top 10,000)
- hashing بـ `bcrypt` أو `argon2` (لا SHA!)

#### Response — 200 OK

```json
{
  "status": "ok",
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci...",
  "expires_at": "2026-04-24T15:15:00Z",
  "user": {
    "id": "usr_abc123",
    "email": "user@example.com",
    "full_name": "شام المحمد",
    "role": "lab_manager",
    "avatar_url": null
  }
}
```

**الـ `role` القيم المتاحة:**
- `lab_manager` → يُوجّه إلى `/lab/dashboard`
- `warehouse_manager` → يُوجّه إلى `/warehouse/dashboard`
- `admin` → يُوجّه إلى `/lab/dashboard` (افتراضياً، مع إمكانية التبديل)
- `dentist` → reserved for later phases
- `secretary` → reserved for later phases

#### Response — 400 Bad Request (كلمة سر ضعيفة)

```json
{
  "status": "weak_password",
  "message": "كلمة المرور يجب أن تكون 8 أحرف على الأقل",
  "details": {
    "min_length": 8,
    "current_length": 5
  }
}
```

#### Response — 401 Unauthorized (temp_token انتهت صلاحيته)

```json
{
  "status": "token_expired",
  "message": "انتهت جلسة التحقق. يرجى البدء من جديد.",
  "redirect_to": "/auth/email"
}
```

---

### 4️⃣ `POST /auth/refresh` — تجديد access_token (مستقبلي)

**يُستخدم تلقائياً من الـ Dio interceptor قبل انتهاء الـ access_token.**

#### Request

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGci..."
}
```

#### Response — 200 OK

```json
{
  "status": "ok",
  "access_token": "eyJhbGci...",
  "expires_at": "2026-04-24T15:30:00Z"
}
```

#### Response — 401 Unauthorized

```json
{
  "status": "refresh_expired",
  "message": "انتهت الجلسة. يرجى تسجيل الدخول مجدداً."
}
```

---

### 5️⃣ `POST /auth/logout` — تسجيل خروج (مستقبلي)

**إبطال الـ tokens في الباك-اند (للأمان).**

#### Request

```http
POST /api/v1/auth/logout
Authorization: Bearer <access_token>
Content-Type: application/json

{}
```

#### Response — 200 OK

```json
{
  "status": "ok",
  "message": "تم تسجيل الخروج بنجاح"
}
```

---

## 📊 جدول ملخّص

| Screen | API Endpoint | Method | Req Headers |
|--------|-------------|--------|-------------|
| Email Entry | `/auth/request-code` | POST | — |
| Verify OTP | `/auth/verify-code` | POST | — |
| Verify OTP (Resend) | `/auth/request-code` | POST | — |
| Set Password | `/auth/set-password` | POST | `Authorization: Bearer <temp_token>` |
| Dashboard (تلقائي) | `/auth/refresh` | POST | — |
| Logout | `/auth/logout` | POST | `Authorization: Bearer <access_token>` |

**إجمالي الـ endpoints المطلوبة في Phase 3:** **3 endpoints أساسية** (`request-code`, `verify-code`, `set-password`) + 2 إضافية لاحقاً.

---

## 🔐 Headers الموحّدة

كل requests تتضمن:

```http
Accept-Language: ar  # أو en — من LocaleCubit
X-Client-Version: 1.0.0
X-Platform: web  # أو ios/android لاحقاً
```

---

## ⚠️ ملاحظات للفريق الباك-اند

1. **ترتيب الأمان**: استخدم `helmet` للـ Node.js أو `django-ratelimit` للـ Python.
2. **Email delivery**: SendGrid أو AWS SES — **ليس SMTP مباشر** (غير موثوق).
3. **Template الإيميل**: يحتوي الكود بخط كبير + رسالة واضحة (اجعله مترجم).
4. **Logging**: كل محاولة فشل تُسجّل في `audit_log` (القرار 21).
5. **HTTPS إجباري**: الـ tokens ما تنتقل بدون TLS.
6. **CORS**: السماح بـ `dtteeth.com` فقط في production.

---

## 🧪 اختبار الـ Flow (للـ QA)

```bash
# 1. طلب كود
curl -X POST https://api.dtteeth.com/v1/auth/request-code \
  -H "Content-Type: application/json" \
  -d '{"email": "test@dtteeth.com"}'

# 2. التحقق
curl -X POST https://api.dtteeth.com/v1/auth/verify-code \
  -H "Content-Type: application/json" \
  -d '{"email": "test@dtteeth.com", "code": "123456"}'

# 3. إنشاء كلمة المرور
curl -X POST https://api.dtteeth.com/v1/auth/set-password \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <temp_token>" \
  -d '{"password": "Secret123!", "password_confirmation": "Secret123!"}'
```

---

## 📞 تواصل

أي استفسار/اقتراح على الـ API → شام

**التحديث الأخير:** 2026-04-24

**النسخة:** 1.0 — Phase 3.1
