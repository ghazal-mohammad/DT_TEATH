package com.example.dt_teath

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

/**
 * FLAG_SECURE أمنيّاً على مستوى النظام:
 *   - يمنع التقاط الشاشة وتسجيل الفيديو للواجهة (بيانات مرضى/طبية).
 *   - يُظهر شاشة فارغة في معاينة "التطبيقات الأخيرة" (recents).
 * دائم التفعيل — بيانات العيادة حسّاسة على كل الشاشات (دخول + مخبري + مستودع).
 */
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
    }
}
