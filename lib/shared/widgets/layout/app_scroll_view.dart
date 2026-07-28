// ════════════════════════════════════════════════════════════════════════════
// app_scroll_view.dart
//
// تمرير عمودي موحّد مع Scrollbar — يملك ScrollController ويتخلّص منه بشكل صحيح.
//
// يستبدل النمط المكرّر الخاطئ في صفحات المستودع:
//   Builder(builder: (_) { final c = ScrollController(); return Scrollbar(...) })
// الذي كان يُنشئ متحكّماً جديداً كل إعادة بناء بلا dispose = تسرّب ذاكرة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../core/theme/app_sizes.dart';

/// تمرير عمودي مع شريط تمرير مرئي، يدير دورة حياة المتحكّم داخلياً.
class AppScrollView extends StatefulWidget {
  const AppScrollView({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.spaceLG),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  State<AppScrollView> createState() => _AppScrollViewState();
}

class _AppScrollViewState extends State<AppScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}
