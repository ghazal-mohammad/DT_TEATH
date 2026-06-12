// ════════════════════════════════════════════════════════════════════════════
// lab_order_process_dialog.dart
//
// مودال "معالجة الطلبية" — يطابق متطلبات التقرير (UC69 + تسجيل التكلفة + UC70):
//   - تغيير الحالة: قيد التصنيع / جاهز للتسليم / غير متوفر (radio cards).
//   - تسجيل تكلفة الطلبية (ل.س).
//   - تسجيل المخبري المنفّذ (اختياري).
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/forms/app_form_select.dart';
import '../../data/lab_inventory_store.dart';
import '../../data/mock/lab_dashboard_mock_data.dart';
import 'lab_order_models.dart';

/// نتيجة معالجة الطلبية المُعادة من المودال.
class LabProcessResult {
  LabProcessResult({
    required this.status,
    this.cost,
    this.technician,
    this.consumption = const [],
  });

  /// الحالة الجديدة المختارة.
  final LabOrderBadgeVariant status;

  /// تكلفة الطلبية بالليرة (null لو ما أُدخلت).
  final int? cost;

  /// المخبري المنفّذ (null لو ما حُدِّد).
  final String? technician;

  /// المواد المستهلكة (تُنقص من مخزون المخبر) — تُملأ عند الإنجاز.
  final List<LabConsumptionLine> consumption;
}

/// سطر استهلاك قابل للتعديل داخل المودال.
class _ConsumeRow {
  _ConsumeRow();
  String? materialId;
  final TextEditingController qty = TextEditingController();
}

class LabOrderProcessDialog extends StatefulWidget {
  const LabOrderProcessDialog({super.key, required this.order});

  final LabOrderFull order;

  static Future<LabProcessResult?> show(
    BuildContext context,
    LabOrderFull order,
  ) {
    return showDialog<LabProcessResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabOrderProcessDialog(order: order),
    );
  }

  @override
  State<LabOrderProcessDialog> createState() => _LabOrderProcessDialogState();
}

class _LabOrderProcessDialogState extends State<LabOrderProcessDialog> {
  final LabInventoryStore _store = LabInventoryStore.instance;
  late LabOrderBadgeVariant _status;
  late final TextEditingController _cost;
  String? _technician;
  final List<_ConsumeRow> _rows = [];
  bool _costEdited = false; // هل عدّل المستخدم التكلفة يدوياً؟
  bool _technicianError = false; // محاولة حفظ بدون اختيار المخبري المنفّذ.

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    // الحالة الافتراضية: الحالية إن كانت من الثلاثة، وإلا "قيد التصنيع".
    _status = (o.statusVariant == LabOrderBadgeVariant.ready ||
            o.statusVariant == LabOrderBadgeVariant.manufacturing)
        ? o.statusVariant
        : LabOrderBadgeVariant.manufacturing;
    _cost = TextEditingController(text: o.cost?.toString() ?? '');
    if (o.cost != null) _costEdited = true;
    _technician = o.assignedTechnician;
  }

  @override
  void dispose() {
    _cost.dispose();
    for (final r in _rows) {
      r.qty.dispose();
    }
    super.dispose();
  }

  /// أسطر الاستهلاك الصالحة (مادة محدّدة + كمية موجبة).
  List<LabConsumptionLine> get _validLines {
    final out = <LabConsumptionLine>[];
    for (final r in _rows) {
      final id = r.materialId;
      final q = int.tryParse(r.qty.text.trim()) ?? 0;
      if (id != null && q > 0) {
        out.add(LabConsumptionLine(materialId: id, quantity: q));
      }
    }
    return out;
  }

  /// يحدّث حقل التكلفة تلقائياً من تكلفة المواد ما لم يعدّله المستخدم.
  void _refreshAutoCost() {
    if (_costEdited) return;
    final total = _store.costOf(_validLines);
    _cost.text = total == 0 ? '' : total.toString();
  }

  /// خطأ سطر استهلاك: الكمية أكبر من المتوفر بالمخزون.
  String? _qtyError(_ConsumeRow r) {
    final id = r.materialId;
    if (id == null) return null;
    final q = int.tryParse(r.qty.text.trim()) ?? 0;
    if (q <= 0) return null;
    final avail = _store.byId(id)?.quantity ?? 0;
    if (q > avail) return context.l10n.labInvConsumeExceeds;
    return null;
  }

  bool get _hasConsumeError =>
      _status == LabOrderBadgeVariant.ready &&
      _rows.any((r) => _qtyError(r) != null);

  void _save() {
    // الحالة لا تتغير من "جديد" إلا بتوكيل مخبري (قرار الفريق 2026-06-12):
    // قيد التصنيع/جاهز ⇒ اسم المخبري المنفّذ إلزامي.
    if (_technician == null) {
      setState(() => _technicianError = true);
      return;
    }
    // منع الحفظ لو في كمية مستهلكة أكبر من المتوفر.
    if (_hasConsumeError) {
      setState(() {});
      return;
    }
    final raw = _cost.text.trim();
    final isReady = _status == LabOrderBadgeVariant.ready;
    Navigator.of(context).pop(LabProcessResult(
      status: _status,
      cost: raw.isEmpty ? null : int.tryParse(raw),
      technician: _technician,
      consumption: isReady ? _validLines : const [],
    ));
  }

  void _addRow() => setState(() => _rows.add(_ConsumeRow()));

  void _removeRow(_ConsumeRow r) {
    setState(() => _rows.remove(r));
    r.qty.dispose();
    _refreshAutoCost();
  }

  List<Widget> _buildConsumeRows() {
    if (_rows.isEmpty) {
      return [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            context.l10n.labProcessNoMaterials,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              color: AppColors.lightText4,
            ),
          ),
        ),
      ];
    }
    final items = _store.items;
    return [
      for (final r in _rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // اختيار المادة
              Expanded(
                flex: 3,
                child: AppDropdownMenuTheme(
                  child: DropdownButtonFormField<String>(
                  initialValue: r.materialId,
                  isExpanded: true,
                  isDense: true,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: context.l10n.labProcessSelectMaterial,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                  ),
                  items: [
                    for (final m in items)
                      DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          '${m.name} (${m.quantity} ${m.unit})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() => r.materialId = v);
                    _refreshAutoCost();
                  },
                ),
                ),
              ),
              const SizedBox(width: 8),
              // الكمية
              SizedBox(
                width: 84,
                child: TextField(
                  controller: r.qty,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  onChanged: (_) {
                    setState(() {});
                    _refreshAutoCost();
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: context.l10n.colQuantity,
                    // errorText='' → يلوّن الحقل أحمر بدون نص (الرسالة موحّدة تحت).
                    errorText: _qtyError(r) != null ? '' : null,
                    errorStyle: const TextStyle(height: 0, fontSize: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppColors.statusUrgent,
                onPressed: () => _removeRow(r),
                splashRadius: 18,
              ),
            ],
          ),
        ),
    ];
  }

  Widget _materialsCostBar() {
    final total = _store.costOf(_validLines);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      ),
      child: Row(
        children: [
          Text(
            context.l10n.labProcessMaterialsCost,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.lightText2,
            ),
          ),
          const Spacer(),
          Text(
            '${_formatMoney(total)} ل.س',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double dialogWidth = width > 700 ? 640 : width * 0.95;
    final double maxHeight = MediaQuery.of(context).size.height * 0.9;
    final order = widget.order;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: dialogWidth, maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _summary(order),
                      const SizedBox(height: 18),
                      _sectionLabel(context.l10n.labProcessUpdateStatus),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ChoiceCard(
                              icon: Icons.build_circle_outlined,
                              iconColor: AppColors.statusProgress,
                              iconBg: AppColors.statusProgressBg,
                              title: context.l10n.statusManufacturing,
                              subtitle:
                                  context.l10n.labProcessManufacturingDesc,
                              selected: _status ==
                                  LabOrderBadgeVariant.manufacturing,
                              onTap: () => setState(() => _status =
                                  LabOrderBadgeVariant.manufacturing),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ChoiceCard(
                              icon: Icons.check_rounded,
                              iconColor: AppColors.statusSuccess,
                              iconBg: AppColors.statusSuccessBg,
                              title: context.l10n.labProcessReadyTitle,
                              subtitle: context.l10n.labProcessDeliveredDesc,
                              selected:
                                  _status == LabOrderBadgeVariant.ready,
                              onTap: () => setState(
                                  () => _status = LabOrderBadgeVariant.ready),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ChoiceCard(
                              icon: Icons.close_rounded,
                              iconColor: AppColors.statusUrgent,
                              iconBg: AppColors.statusUrgentBg,
                              title: context.l10n.whOrderFilterMissing,
                              subtitle: context.l10n.labProcessMissingDesc,
                              selected:
                                  _status == LabOrderBadgeVariant.newOrder,
                              onTap: () => setState(() =>
                                  _status = LabOrderBadgeVariant.newOrder),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // المخبري المنفّذ — إلزامي: تغيير الحالة = توكيل مخبري.
                      _field(
                        label: context.l10n.labProcessTechnician,
                        child: AppDropdownMenuTheme(
                          child: DropdownButtonFormField<String?>(
                          initialValue: _technician,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLG),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: context.l10n.labProcessTechnicianNone,
                            errorText: _technicianError
                                ? context.l10n.labProcessTechnicianRequired
                                : null,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                            ),
                          ),
                          items: [
                            for (final name in kLabTechnicianNames)
                              DropdownMenuItem<String?>(
                                value: name,
                                child: Text(name),
                              ),
                          ],
                          onChanged: (v) => setState(() {
                            _technician = v;
                            _technicianError = false;
                          }),
                        ),
                        ),
                      ),
                      // قسم المواد المستهلكة + التكلفة — فقط عند "جاهز" (الإنجاز)
                      if (_status == LabOrderBadgeVariant.ready) ...[
                        const SizedBox(height: 18),
                        _sectionLabel(context.l10n.labProcessConsumedSection),
                        const SizedBox(height: 4),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            context.l10n.labProcessConsumedHint,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11,
                              color: AppColors.lightText3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._buildConsumeRows(),
                        if (_hasConsumeError) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.statusUrgent
                                  .withValues(alpha: 0.08),
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusSM),
                              border: Border.all(
                                  color: AppColors.statusUrgent
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    size: 16, color: AppColors.statusUrgent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    context.l10n.labInvConsumeExceeds,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.statusUrgent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _AddMaterialButton(onTap: _addRow),
                        ),
                        const SizedBox(height: 14),
                        _materialsCostBar(),
                        const SizedBox(height: 12),
                        _field(
                          label: context.l10n.labProcessCost,
                          child: TextField(
                            controller: _cost,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (_) => _costEdited = true,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: context.l10n.labProcessCostHint,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusSM),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _OutlineButton(
                      label: context.l10n.cancel,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    _PrimaryButton(
                      label: context.l10n.save,
                      onTap: _save,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.lightText1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      );

  Widget _field({required String label, required Widget child}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      );

  Widget _header(BuildContext context) {
    final order = widget.order;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(22, 16, 16, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.labProcessTitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${order.id} — ${order.doctor}',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText3,
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(LabOrderFull o) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _summaryCell(context.l10n.colOrderNumber, o.id)),
              Expanded(child: _summaryCell(context.l10n.colDoctor, o.doctor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryCell(
                    context.l10n.colMaterial, '${o.material} · ${o.tooth}'),
              ),
              Expanded(child: _summaryCell(context.l10n.colDate, o.date)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.lightText3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.lightText1,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  CHOICE CARD (radio-like)
// ══════════════════════════════════════════════════════════════════════════

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.lightBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const Spacer(),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.lightText4,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightText3,
                  height: 1.35,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  BUTTONS
// ══════════════════════════════════════════════════════════════════════════

class _AddMaterialButton extends StatelessWidget {
  const _AddMaterialButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                context.l10n.labProcessAddMaterial,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightBorder),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.lightText1,
            ),
          ),
        ),
      ),
    );
  }
}
