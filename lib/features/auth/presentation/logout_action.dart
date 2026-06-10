// ════════════════════════════════════════════════════════════════════════════
// logout_action.dart
//
// إجراء تسجيل الخروج المشترك (مخبر + مستودع) — تأكيد ثم استدعاء
// AuthRepository.logout (يمسح التوكن ويستدعي POST /api/employee/logout)
// ثم الرجوع لشاشة تسجيل الدخول.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/router/route_names.dart';
import '../domain/repositories/auth_repository.dart';

/// يعرض تأكيداً ثم يسجّل الخروج ويرجّع لشاشة الدخول.
Future<void> performLogout(BuildContext context) async {
  final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isAr ? 'تسجيل الخروج' : 'Sign out'),
      content: Text(
        isAr
            ? 'هل تريد تسجيل الخروج من حسابك؟'
            : 'Are you sure you want to sign out?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(isAr ? 'إلغاء' : 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(isAr ? 'خروج' : 'Sign out'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  // logout() يمسح التوكن محلياً حتى لو فشل طلب الـ API — فما في داعي try/catch.
  await sl<AuthRepository>().logout();
  if (context.mounted) context.go(RouteNames.login);
}
