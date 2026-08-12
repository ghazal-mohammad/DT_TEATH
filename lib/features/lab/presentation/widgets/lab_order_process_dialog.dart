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
import '../../domain/entities/lab_stock.dart';
import 'lab_order_models.dart';

part 'order_process/lab_order_process_parts.dart';

/// نتيجة معالجة الطلبية المُعادة من المودال.
class LabProcessResult {
  LabProcessResult({
    required this.status,
    this.technician,
    this.consumption = const [],
  });

  /// الحالة الجديدة المختارة.
  final LabOrderBadgeVariant status;

  /// المخبري المنفّذ (null لو ما حُدِّد).
  final String? technician;

  /// المواد المستهلكة (تُنقص من مخزون المخبر) — تُملأ عند الإنجاز.
  final List<LabConsumptionLine> consumption;
}

/// سطر استهلاك واحد — [stockId] هو معرّف سجل المخزون (LabStock.id) المطلوب
/// لاستدعاء subtractQuantity، لا معرّف المادة الأصل.
class LabConsumptionLine {
  const LabConsumptionLine({required this.stockId, required this.quantity});
  final String stockId;
  final int quantity;
}

/// سطر استهلاك قابل للتعديل داخل المودال.
class _ConsumeRow {
  _ConsumeRow();
  String? stockId;
  final TextEditingController qty = TextEditingController();
}

class LabOrderProcessDialog extends StatefulWidget {
  const LabOrderProcessDialog({
    super.key,
    required this.order,
    this.technicianNames = const [],
    this.stock = const [],
  });

  final LabOrderFull order;

  /// أسماء الفنّيين الحقيقيين (من الباك) لقائمة التعيين. فارغة ⇒ بلا تعيين.
  final List<String> technicianNames;

  /// مخزون المخبر الحقيقي (من LabStockRepository) لقائمة اختيار المواد
  /// المستهلكة عند الإنجاز. فارغة ⇒ قسم المواد يبقى فارغاً بلا خيارات.
  final List<LabStock> stock;

  static Future<LabProcessResult?> show(
    BuildContext context,
    LabOrderFull order, {
    List<String> technicianNames = const [],
    List<LabStock> stock = const [],
  }) {
    return showDialog<LabProcessResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => LabOrderProcessDialog(
        order: order,
        technicianNames: technicianNames,
        stock: stock,
      ),
    );
  }

  @override
  State<LabOrderProcessDialog> createState() => _LabOrderProcessDialogState();
}

class _LabOrderProcessDialogState extends State<LabOrderProcessDialog> {
  late LabOrderBadgeVariant _status;
  String? _technician;
  final List<_ConsumeRow> _rows = [];
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
    _technician = o.assignedTechnician;
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.qty.dispose();
    }
    super.dispose();
  }

  /// أسطر الاستهلاك الصالحة (مادة محدّدة + كمية موجبة).
  List<LabConsumptionLine> get _validLines {
    final out = <LabConsumptionLine>[];
    for (final r in _rows) {
      final id = r.stockId;
      final q = int.tryParse(r.qty.text.trim()) ?? 0;
      if (id != null && q > 0) {
        out.add(LabConsumptionLine(stockId: id, quantity: q));
      }
    }
    return out;
  }

  LabStock? _stockById(String id) {
    for (final s in widget.stock) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// خطأ سطر استهلاك: الكمية أكبر من المتوفر بالمخزون.
  String? _qtyError(_ConsumeRow r) {
    final id = r.stockId;
    if (id == null) return null;
    final q = int.tryParse(r.qty.text.trim()) ?? 0;
    if (q <= 0) return null;
    final avail = _stockById(id)?.quantity ?? 0;
    if (q > avail) return context.l10n.labInvConsumeExceeds;
    return null;
  }

  bool get _hasConsumeError =>
      _status == LabOrderBadgeVariant.ready &&
      _rows.any((r) => _qtyError(r) != null);

  /// أسماء الفنّيين الحقيقيين للقائمة، مع ضمّ المنفّذ الحالي إن كان خارجها (اسم
  /// قادم من الباك) — وإلا ينهار DropdownButtonFormField (value not in items).
  List<String> get _techNames {
    final t = _technician;
    if (t != null && t.isNotEmpty && !widget.technicianNames.contains(t)) {
      return [t, ...widget.technicianNames];
    }
    return widget.technicianNames;
  }

  void _save() {
    // المخبري المنفّذ إلزامي فقط لحالة "قيد التصنيع" — هي الوحيدة التي تعيّن
    // فنّياً في الباك (setInProgress يتطلّب technician_id). أما "جاهز للتسليم"
    // و"غير موجود" فلا تحتاج اختيار فنّي.
    if (_status == LabOrderBadgeVariant.manufacturing && _technician == null) {
      setState(() => _technicianError = true);
      return;
    }
    // منع الحفظ لو في كمية مستهلكة أكبر من المتوفر.
    if (_hasConsumeError) {
      setState(() {});
      return;
    }
    final isReady = _status == LabOrderBadgeVariant.ready;
    Navigator.of(context).pop(LabProcessResult(
      status: _status,
      technician: _technician,
      consumption: isReady ? _validLines : const [],
    ));
  }

  void _addRow() => setState(() => _rows.add(_ConsumeRow()));

  void _removeRow(_ConsumeRow r) {
    setState(() => _rows.remove(r));
    r.qty.dispose();
  }

  List<Widget> _buildConsumeRows() {
    if (_rows.isEmpty) {
      return [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            context.l10n.labProcessNoMaterials,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              color: AppColors.lightText4,
            ),
          ),
        ),
      ];
    }
    final items = widget.stock;
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
                  initialValue: r.stockId,
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
                          '${m.material} (${m.quantity} ${m.unit})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => r.stockId = v),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(() {}),
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
              _ProcessHeader(order: order),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OrderSummary(order: order),
                      const SizedBox(height: 18),
                      _SectionLabel(context.l10n.labProcessUpdateStatus),
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
                              subtitle: order.statusVariant ==
                                      LabOrderBadgeVariant.manufacturing
                                  ? context.l10n.labProcessDeliveredDesc
                                  : context.l10n.labProcessReadyRequiresInProgress,
                              selected:
                                  _status == LabOrderBadgeVariant.ready,
                              enabled: order.statusVariant ==
                                  LabOrderBadgeVariant.manufacturing,
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
                                  _status == LabOrderBadgeVariant.cancelled,
                              onTap: () => setState(() =>
                                  _status = LabOrderBadgeVariant.cancelled),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // المخبري المنفّذ — إلزامي: تغيير الحالة = توكيل مخبري.
                      _FieldColumn(
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
                            for (final name in _techNames)
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
                        _SectionLabel(context.l10n.labProcessConsumedSection),
                        const SizedBox(height: 4),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            context.l10n.labProcessConsumedHint,
                            style: const TextStyle(
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
                        // للعرض فقط — الباك يحسب total_cost تلقائياً (مجموع
                        // أسعار بنود الطلبية التي حدّدها الطبيب عند الإنشاء)،
                        // ولا يقبل قيمة يدوية من المخبري.
                        _FieldColumn(
                          label: context.l10n.labProcessCost,
                          child: Text(
                            order.cost != null
                                ? '${_formatMoney(order.cost!)} ل.س'
                                : '—',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.lightText1,
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

}

