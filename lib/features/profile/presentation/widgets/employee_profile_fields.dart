// ════════════════════════════════════════════════════════════════════════════
// employee_profile_fields.dart
//
// نماذج الحقول القابلة للتعديل (_RowSpec + _FieldPill) — part of
// employee_profile_content.dart، مفصولة عن بطاقات الإحصاء/الأقسام لتقليل حجم
// الملف (تقسيم الصفحات العملاقة) وتحسين التماسك.
// ════════════════════════════════════════════════════════════════════════════

part of 'employee_profile_content.dart';

class _RowSpec {
  _RowSpec({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.options,
    this.editable = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  /// لو موجودة، يُعرض الحقل كقائمة منسدلة (بدل إدخال نصّي حر) عند التعديل.
  final List<String>? options;

  /// لو true، يُعرض كحقل تاريخ يفتح Date Picker عند الضغط (بدل إدخال حر).
  final bool isDate = false;

  /// لو false، الحقل للقراءة فقط (يديره الأدمن/السكرتيرة أو ثابت) — لا يُعدَّل
  /// من الموظف حتى بوضع التعديل. يطابق عقد editProfile بالباك.
  final bool editable;
}

class _FieldPill extends StatefulWidget {
  const _FieldPill({
    required this.spec,
    required this.editing,
    required this.pink,
  });

  final _RowSpec spec;
  final bool editing;
  final bool pink;

  @override
  State<_FieldPill> createState() => _FieldPillState();
}

class _FieldPillState extends State<_FieldPill> {
  late TextEditingController _controller;

  /// عرض محلي لحقل التاريخ بعد اختيار من الـ Date Picker (يطغى على spec.value).
  String? _dateDisplay;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.spec.value);
  }

  @override
  void didUpdateWidget(_FieldPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editing != widget.editing) {
      _controller.text = widget.spec.value;
      _dateDisplay = null;
    }
  }

  Future<void> _pickDate(Color accent) async {
    final current = _dateDisplay ?? widget.spec.value;
    DateTime initial = DateTime(2000, 1, 1);
    final api = AppDate.toApi(current);
    if (api != null) {
      final parsed = DateTime.tryParse(api);
      if (parsed != null) initial = parsed;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final iso =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    final shown = AppDate.display(iso);
    setState(() => _dateDisplay = shown);
    widget.spec.onChanged(shown);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.pink ? _Palette.of(context).pinkAccent : _Palette.of(context).blueAccent;
    final iconBg = widget.pink ? _Palette.of(context).pinkIconBg : _Palette.of(context).blueIconBg;

    // نستخدم Stack بدلاً من IntrinsicHeight: الشريط اللوني يتمدّد عمودياً عبر
    // Positioned (top/bottom:0) فيأخذ ارتفاع المحتوى تلقائياً — وهذا يتفادى
    // رمي IntrinsicHeight لخطأ عند احتواء TextField أثناء التعديل.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: _Palette.of(context).cardBorder),
      ),
      child: Stack(
        children: [
          // الشريط اللوني على الطرف الأيسر (يمتد لكامل الارتفاع).
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Container(width: 4, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.spec.icon, size: 18, color: accent),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.spec.label,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _Palette.of(context).label,
                            ),
                          ),
                          // قفل صغير للحقول غير القابلة للتعديل (عند وضع التعديل).
                          if (widget.editing && !widget.spec.editable) ...[
                            const SizedBox(width: 5),
                            Icon(Icons.lock_outline_rounded,
                                size: 11, color: _Palette.of(context).label),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.editing &&
                          widget.spec.editable &&
                          widget.spec.isDate)
                        GestureDetector(
                          onTap: () => _pickDate(accent),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.profileSurface,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              border:
                                  Border.all(color: _Palette.of(context).cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (_dateDisplay ?? widget.spec.value)
                                            .trim()
                                            .isEmpty
                                        ? context.l10n.profilePickDate
                                        : (_dateDisplay ?? widget.spec.value),
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: (_dateDisplay ?? widget.spec.value)
                                              .trim()
                                              .isEmpty
                                          ? _Palette.of(context).label
                                          : AppColors.lightText1,
                                    ),
                                  ),
                                ),
                                Icon(Icons.calendar_month_rounded,
                                    size: 18, color: accent),
                              ],
                            ),
                          ),
                        )
                      else if (widget.editing &&
                          widget.spec.editable &&
                          widget.spec.options != null)
                        AppDropdownMenuTheme(
                          child: DropdownButtonFormField<String>(
                          initialValue: widget.spec.options!
                                  .contains(widget.spec.value)
                              ? widget.spec.value
                              : null,
                          isDense: true,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: accent),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLG),
                          dropdownColor: Colors.white,
                          elevation: 3,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightText1,
                          ),
                          items: widget.spec.options!
                              .map((o) => DropdownMenuItem<String>(
                                    value: o,
                                    child: Text(
                                      o,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.lightText1,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) widget.spec.onChanged(v);
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            filled: true,
                            fillColor: AppColors.profileSurface,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide:
                                  BorderSide(color: _Palette.of(context).cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide: BorderSide(color: accent, width: 1.6),
                            ),
                          ),
                        ),
                        )
                      else if (widget.editing && widget.spec.editable)
                        TextField(
                          controller: _controller,
                          onChanged: widget.spec.onChanged,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightText1,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            filled: true,
                            fillColor: AppColors.profileSurface,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide:
                                  BorderSide(color: _Palette.of(context).cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              borderSide: BorderSide(color: accent, width: 1.6),
                            ),
                          ),
                        )
                      else
                        Text(
                          widget.spec.value,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lightText1,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
