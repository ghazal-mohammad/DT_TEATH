// ════════════════════════════════════════════════════════════════════════════
// auth_flow_mode.dart
//
// نوع تدفّق المصادقة المشترك بين شاشات (email → verify → password).
// نفس الشاشات تخدم حالتين، والفرق فقط بالـ endpoint والخطوة الأخيرة:
//   • activation : تفعيل أول مرة — POST /api/employee/{sendVerification,
//                  verifyCode, setPassword}. الباك بيرجّع توكن → دخول مباشر.
//   • reset      : "نسيت كلمة السر" لحساب مفعّل — POST /api/forgotPassword/
//                  {sendCode, verifyCode, resetPassword}. ما بيرجّع توكن →
//                  نرجّع المستخدم لشاشة تسجيل الدخول.
// ════════════════════════════════════════════════════════════════════════════

enum AuthFlowMode { activation, reset }
