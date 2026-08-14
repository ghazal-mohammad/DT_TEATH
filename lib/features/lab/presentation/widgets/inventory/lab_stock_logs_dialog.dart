// ════════════════════════════════════════════════════════════════════════════
// lab_stock_logs_dialog.dart
//
// حوار "سجلّ حركات المخزون" — يعرض حركات الإضافة/الخصم (showLabStockLogs).
// يجلب السجلّ عند الفتح مباشرةً عبر LabStockRepository.getLogs (قراءة فقط، بلا
// Cubit)، مع حالات تحميل/خطأ/فراغ موحّدة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/l10n/build_context_l10n.dart';
import '../../../../../core/network/failure.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/lab_stock_log.dart';
import '../../../domain/repositories/lab_stock_repository.dart';

/// حوار عرض سجلّ حركات مخزون المخبر.
class LabStockLogsDialog extends StatefulWidget {
  const LabStockLogsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const LabStockLogsDialog(),
    );
  }

  @override
  State<LabStockLogsDialog> createState() => _LabStockLogsDialogState();
}

class _LabStockLogsDialogState extends State<LabStockLogsDialog> {
  List<LabStockLog>? _logs; // null = قيد التحميل
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final logs = await sl<LabStockRepository>().getLogs();
      if (mounted) setState(() => _logs = logs);
    } catch (e) {
      if (mounted) setState(() => _error = userMessageFromError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: isLight ? Colors.white : AppColors.darkSurface,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width > 640 ? 560 : size.width * 0.95,
          maxHeight: size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.spaceLG, AppSizes.spaceLG, AppSizes.spaceSM,
                  AppSizes.spaceMD),
              child: Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 20,
                      color:
                          isLight ? AppColors.primary : AppColors.darkText1),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.stockLogsTitle,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color:
                            isLight ? AppColors.lightText1 : AppColors.darkText1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
            Flexible(child: _content(isLight)),
          ],
        ),
      ),
    );
  }

  Widget _content(bool isLight) {
    final l10n = context.l10n;
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.space2XL),
        child: Center(
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      );
    }
    final logs = _logs;
    if (logs == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.space3XL),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.space2XL),
        child: Center(
          child: Text(
            l10n.stockLogsEmpty,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLight ? AppColors.lightText3 : AppColors.darkText3,
            ),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSM),
      itemCount: logs.length,
      separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder),
      itemBuilder: (context, i) => _LogRow(log: logs[i], isLight: isLight),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log, required this.isLight});

  final LabStockLog log;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final Color accent = log.isAdd ? AppColors.statusSuccess : AppColors.error;
    final String sign = log.isAdd ? '+' : '−';
    final sub = [
      if (log.reason.isNotEmpty) log.reason,
      if (log.notes.isNotEmpty) log.notes,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spaceLG, vertical: AppSizes.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              log.isAdd
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.materialName.isEmpty ? '—' : log.materialName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isLight ? AppColors.lightText1 : AppColors.darkText1,
                  ),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isLight ? AppColors.lightText3 : AppColors.darkText3,
                    ),
                  ),
                ],
                if (log.createdAt.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _shortDate(log.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color:
                          isLight ? AppColors.lightText4 : AppColors.darkText4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$sign${log.quantity.abs()}'
            '${log.unit.isEmpty ? '' : ' ${log.unit}'}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  /// يقصّ الطابع الزمني إلى "yyyy-MM-dd HH:mm".
  static String _shortDate(String raw) =>
      raw.length >= 16 ? raw.substring(0, 16) : raw;
}
