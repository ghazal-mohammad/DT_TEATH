// ════════════════════════════════════════════════════════════════════════════
// warehouse_settings_content.dart
//
// محتوى صفحة إعدادات المستودع — مطابقة كاملة لـ mockup التصميم.
//
// 🎯 البنية:
//   - Sidebar عمودي يميناً (RTL) بـ 3 تابات: الأمان / الإشعارات / التفضيلات
//   - محتوى التاب في العمود الأيسر (Expanded) كبطاقات متعددة
//
// التابات:
//   1. الأمان        → تغيير كلمة المرور + المصادقة الثنائية + الخروج من كل الأجهزة
//   2. الإشعارات     → تفضيلات الإشعارات (5 toggles) + قنوات الإشعار (2 toggles)
//   3. التفضيلات    → السمة (3 خيارات) + اللغة (خياران) + العرض والأداء (toggles)
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../shared/bloc/theme_cubit.dart';
import '../../../../../shared/widgets/primitives/app_theme_option.dart';
import '../../../../../shared/widgets/settings/app_text_size_selector.dart';
import '../../../../../shared/bloc/locale_cubit.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/forms/app_form_field.dart';
import '../../../../../shared/widgets/primitives/app_button.dart';
import '../../../../profile/presentation/widgets/employee_profile_content.dart';

part 'warehouse_settings_nav.dart';
part 'warehouse_settings_security_tab.dart';
part 'warehouse_settings_notifications_tab.dart';
part 'warehouse_settings_preferences_tab.dart';
part 'warehouse_settings_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════
//  CONSTANTS
// ══════════════════════════════════════════════════════════════════════════

const double _kSidebarWidth = 220;
const double _kSidebarGap = 18;
const double _kCardGap = 18;

enum _SettingsTab { security, notifications, preferences, profile }

extension on _SettingsTab {
  String label(BuildContext context) {
    switch (this) {
      case _SettingsTab.security:
        return context.l10n.settingsTabSecurity;
      case _SettingsTab.notifications:
        return context.l10n.notifications;
      case _SettingsTab.preferences:
        return context.l10n.settingsTabPreferences;
      case _SettingsTab.profile:
        return context.l10n.labProfile;
    }
  }

  IconData get icon {
    switch (this) {
      case _SettingsTab.security:
        return Icons.lock_outline_rounded;
      case _SettingsTab.notifications:
        return Icons.notifications_outlined;
      case _SettingsTab.preferences:
        return Icons.tune_rounded;
      case _SettingsTab.profile:
        return Icons.person_outline_rounded;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  MAIN CONTENT
// ══════════════════════════════════════════════════════════════════════════

class WarehouseSettingsContent extends StatefulWidget {
  const WarehouseSettingsContent({super.key, this.initialTab});

  /// اسم التبويب المبدئي ("profile" فقط مدعوم حالياً؛ أي قيمة تانية أو null
  /// تفتح على تبويب الأمان الافتراضي) — يُمرَّر من الراوتر عبر `?tab=` لما
  /// يوصل المستخدم من نتيجة بحث "الملف الشخصي" أو من إعادة توجيه
  /// `/warehouse/profile` القديم.
  final String? initialTab;

  @override
  State<WarehouseSettingsContent> createState() =>
      _WarehouseSettingsContentState();
}

_SettingsTab _settingsTabFromQuery(String? tab) =>
    tab == 'profile' ? _SettingsTab.profile : _SettingsTab.security;

class _WarehouseSettingsContentState extends State<WarehouseSettingsContent> {
  late _SettingsTab _activeTab = _settingsTabFromQuery(widget.initialTab);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;
        if (isNarrow) {
          return _buildNarrowLayout(isLight);
        }
        return _buildWideLayout(isLight);
      },
    );
  }

  // ── Wide layout: sidebar + content ───────────────────────────────────
  // RTL: أوّل child=يمين، آخر=يسار.
  // المطلوب: Sidebar يمين، Content يسار → [Sidebar, Gap, Content].
  Widget _buildWideLayout(bool isLight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _kSidebarWidth,
          child: _Sidebar(
            isLight: isLight,
            active: _activeTab,
            onSelect: (t) => setState(() => _activeTab = t),
          ),
        ),
        const SizedBox(width: _kSidebarGap),
        Expanded(child: _buildTabContent(isLight)),
      ],
    );
  }

  // ── Narrow layout: top tab bar + content ─────────────────────────────
  Widget _buildNarrowLayout(bool isLight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NarrowTabBar(
          isLight: isLight,
          active: _activeTab,
          onSelect: (t) => setState(() => _activeTab = t),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildTabContent(isLight)),
      ],
    );
  }

  Widget _buildTabContent(bool isLight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: switch (_activeTab) {
        _SettingsTab.security => _SecurityTabContent(isLight: isLight),
        _SettingsTab.notifications =>
          _NotificationsPrefsTabContent(isLight: isLight),
        _SettingsTab.preferences => _PreferencesTabContent(isLight: isLight),
        _SettingsTab.profile => const EmployeeProfileContent(),
      },
    );
  }
}

