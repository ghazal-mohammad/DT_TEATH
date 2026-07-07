// ════════════════════════════════════════════════════════════════════════════
// offline_banner.dart
//
// شريط علوي يظهر عند انقطاع الاتصال (NetworkStatus) ويختفي بسلاسة عند عودته.
// يلفّ [child] ويدفعه للأسفل بارتفاع الشريط فقط عند الظهور — بلا تغطية محتوى.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/network/network_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// يلفّ محتوى التطبيق ويعرض شريط "لا يوجد اتصال" أعلاه عند انقطاع الشبكة.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NetworkStatus.instance,
      builder: (context, _) {
        final bool offline = !NetworkStatus.instance.isOnline;
        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: offline
                  ? const _OfflineBar()
                  : const SizedBox(width: double.infinity),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  context.l10n.networkOfflineBanner,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
