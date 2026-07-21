// ════════════════════════════════════════════════════════════════════════════
// command_palette.dart
//
// مركز الأوامر / البحث العالمي (Ctrl+K أو زر التوب-بار). لوحة تُفتح فوق أي
// صفحة، تبحث فوريًا عبر التنقّل + بيانات الكاش (AppSearch)، وتقفز للنتيجة.
//
// تنقّل بلوحة المفاتيح: ↑/↓ للتنقّل، Enter للفتح، Esc للإغلاق. يحترم الثيمين.
// يحلّ مشكلة Ctrl+K المتصفّح لأنّه يعترض الاختصار داخل النظام.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/build_context_l10n.dart';
import '../../../core/search/app_search.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  /// يفتح مركز الأوامر فوق الصفحة الحالية.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const CommandPalette(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _q = TextEditingController();
  late final FocusNode _focus = FocusNode(onKeyEvent: _handleKey);
  final ScrollController _scroll = ScrollController();

  List<SearchHit> _results = AppSearch.query('');
  int _selected = 0;

  @override
  void dispose() {
    _q.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() {
      _results = AppSearch.query(v);
      _selected = 0;
    });
  }

  void _move(int delta) {
    if (_results.isEmpty) return;
    setState(() {
      _selected = (_selected + delta).clamp(0, _results.length - 1);
    });
    // إبقاء العنصر المحدّد مرئيًا (تقريبي — ارتفاع الصف ~56).
    if (_scroll.hasClients) {
      _scroll.animateTo(
        (_selected * 56.0 - 120).clamp(0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    }
  }

  void _activate() {
    if (_results.isEmpty) return;
    final hit = _results[_selected];
    Navigator.of(context).pop();
    context.go(hit.route);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _move(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        _activate();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Color surface = isLight ? Colors.white : AppColors.darkBg1;
    final Color border =
        isLight ? AppColors.lightBorder : AppColors.darkBorder;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 520),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.12 : 0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _searchField(isLight),
              Divider(height: 1, color: border),
              Flexible(child: _resultsList(isLight)),
              Divider(height: 1, color: border),
              _footer(isLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField(bool isLight) {
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _q,
              focusNode: _focus,
              autofocus: true,
              onChanged: _onChanged,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isLight ? AppColors.lightText1 : AppColors.darkText1,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.commandPaletteHint,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: (isLight ? AppColors.lightBg1 : AppColors.darkBg2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            ),
            child: Text('Esc',
                style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isLight ? AppColors.lightText3 : AppColors.darkText3)),
          ),
        ],
      ),
    );
  }

  Widget _resultsList(bool isLight) {
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Text(
            context.l10n.commandPaletteEmpty,
            style: AppTextStyles.bodyMedium.copyWith(
                color: isLight ? AppColors.lightText3 : AppColors.darkText3),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 6),
      shrinkWrap: true,
      itemCount: _results.length,
      itemBuilder: (context, i) => _row(_results[i], i == _selected, isLight),
    );
  }

  Widget _row(SearchHit hit, bool selected, bool isLight) {
    final Color accent = isLight ? AppColors.primary : AppColors.brand;
    final Color selBg = accent.withValues(alpha: isLight ? 0.08 : 0.16);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _selected = _results.indexOf(hit)),
      child: GestureDetector(
        onTap: _activate,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? selBg : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          child: Row(
            children: [
              Icon(hit.icon,
                  size: 18,
                  color: selected
                      ? accent
                      : (isLight
                          ? AppColors.lightText3
                          : AppColors.darkText3)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isLight
                              ? AppColors.lightText1
                              : AppColors.darkText1,
                        )),
                    if (hit.subtitle.isNotEmpty)
                      Text(hit.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: isLight
                                  ? AppColors.lightText3
                                  : AppColors.darkText3)),
                  ],
                ),
              ),
              _categoryChip(hit.category, isLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(SearchCategory c, bool isLight) {
    final label = switch (c) {
      SearchCategory.navigation => context.l10n.commandCatNav,
      SearchCategory.order => context.l10n.commandCatOrder,
      SearchCategory.product => context.l10n.commandCatProduct,
      SearchCategory.technician => context.l10n.commandCatTechnician,
      SearchCategory.material => context.l10n.commandCatMaterial,
      SearchCategory.request => context.l10n.commandCatRequest,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightBg1 : AppColors.darkBg2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: AppTextStyles.badge.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3)),
    );
  }

  Widget _footer(bool isLight) {
    final Color c = isLight ? AppColors.lightText3 : AppColors.darkText3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.keyboard_arrow_up_rounded, size: 16, color: c),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: c),
          const SizedBox(width: 6),
          Text(context.l10n.commandPaletteNavHint,
              style: AppTextStyles.bodySmall.copyWith(color: c)),
        ],
      ),
    );
  }
}
