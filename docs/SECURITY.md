# الأمان — DT.Teeth (المخبر + المستودع)

بيانات طبية/مرضى ⇒ الأمان أولوية. هذا المستند يوثّق **ما نفّذناه في الواجهة**،
و**ما يجب أن يوفّره الخادم/الباك** (خط الدفاع الأساسي).

> حقيقة هندسية: تطبيق الويب الأمامي لا يمكن جعله «غير قابل للاختراق» — كل كوده على
> جهاز المستخدم. الحماية الحقيقية للبيانات الطبية في **الباك** (تفويض كل endpoint،
> تحقّق المدخلات، تشفير، تدقيق). الواجهة = دفاع في العمق.

## 1) رؤوس الأمان (مستوى الخادم)
مطبّقة عبر `web/_headers` (Netlify/Cloudflare Pages). لـ nginx أضِف في الـ server block:

```nginx
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=(), payment=()" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://<API_HOST>; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; form-action 'self'; upgrade-insecure-requests" always;
```
- استبدل `<API_HOST>` بمضيف الـ API الحقيقي.
- **اختبر على staging** — CSP صارم خاطئ = شاشة Flutter بيضاء.
- ابنِ CanvasKit محليًا (`flutter build web`) كي يبقى `connect-src` ضيّقاً بلا gstatic.

## 2) ما نفّذته الواجهة (دفاع في العمق)
- **حجب الاعتمادات في السجلّات**: مُعترِض Dio يحجب Authorization/كلمات المرور/الأكواد؛ لا لوغ إنتاج.
- **اختيار البيئة وقت البناء** (`--dart-define=APP_ENV`) — لا يشحن الإنتاج localhost/http.
- **انتهاء الجلسة (401)**: مسح محلّي (توكن+مستخدم+كواش) وتوجيه للدخول، مرّة واحدة.
- **قفل الخمول**: تسجيل خروج تلقائي بعد 15 دقيقة بلا نشاط (أجهزة مشتركة).
- **مسح كواش الجلسة عند الخروج** (SessionCacheRegistry) — منع تسريب بيانات مستخدم لآخر.
- **إخفاء الحقول الحسّاسة** (الراتب) مع زرّ إظهار.
- **حدود طول المدخلات** على النماذج، وHTTPS في staging/production.
- **Referrer-Policy: no-referrer** (meta) — لا تسريب روابط.

## 3) المطلوب من الباك (خط الدفاع الأساسي)
- تفويض (authorization) على **كل** endpoint حسب الدور — لا الاعتماد على إخفاء الواجهة.
- تحقّق مدخلات صارم + rate-limiting على الدخول/الحسّاس.
- توكنات قصيرة العمر + إبطال عند الخروج (لدينا logout يستدعي employee/logout).
- تشفير البيانات الحسّاسة عند التخزين + سجلّ تدقيق (من الوصول لبيانات المرضى).
- HTTPS إلزامي + رفض HTTP.
- ضبط CORS على مضيف الواجهة فقط.

## 4) مخاطر مقبولة/موثّقة
- تخزين التوكن على الويب عبر flutter_secure_storage ليس تخزين OS-keychain (قيد المنصّة)؛
  يخفّفه قِصَر عمر التوكن + قفل الخمول + مسح الخروج. الأمثل مستقبلاً: كوكي httpOnly (قرار باك).
