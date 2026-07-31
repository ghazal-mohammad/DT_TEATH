// ════════════════════════════════════════════════════════════════════════════
// warehouse_order_details_parts.dart
//
// أجزاء عرض تفاصيل طلب المستودع (عنوان قسم/بطاقة معلومات/خط زمني) — مُستخرَجة
// من warehouse_order_details_dialog.dart ضمن تقسيم الملفات العملاقة (>25KB).
// ════════════════════════════════════════════════════════════════════════════

part of 'warehouse_order_details_dialog.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.lightText1,
          ),
        ),
      ],
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.label,
    required this.value,
    this.urgent = false,
    this.showUrgentBadge = false,
  });

  final String label;
  final String value;
  final bool urgent;
  final bool showUrgentBadge;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightText1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _buildInfoRow(rows[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoRow r) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          r.label,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.lightText3,
          ),
        ),
        const Spacer(),
        if (r.showUrgentBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: r.urgent
                  ? AppColors.statusUrgent.withValues(alpha: 0.12)
                  : AppColors.borderNeutralLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              r.value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: r.urgent
                    ? AppColors.statusUrgent
                    : AppColors.lightText3,
              ),
            ),
          )
        else
          Text(
            r.value,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.lightText1,
            ),
          ),
      ],
    );
  }
}

// ── Timeline widget ─────────────────────────────────────────────────────
enum _TimelineState { done, current, pending }

class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.state,
    this.date,
  });
  final String label;
  final _TimelineState state;
  final String? date;
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps});
  final List<_TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            height: 28,
            child: Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  _buildDot(steps[i].state),
                  if (i < steps.length - 1)
                    Expanded(
                      child: _buildConnector(
                        steps[i].state,
                        steps[i + 1].state,
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                _buildLabel(steps[i]),
                if (i < steps.length - 1) const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(_TimelineState s) {
    final isDone = s == _TimelineState.done;
    final isCurrent = s == _TimelineState.current;
    final size = isCurrent ? 24.0 : 22.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.primary
            : isCurrent
                ? Colors.white
                : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone || isCurrent
              ? AppColors.primary
              : AppColors.lightBorder,
          width: isCurrent ? 2.5 : 1.5,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }

  Widget _buildConnector(_TimelineState left, _TimelineState right) {
    final filled =
        left == _TimelineState.done && right != _TimelineState.pending;
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: filled ? AppColors.primary : AppColors.lightBorder,
    );
  }

  Widget _buildLabel(_TimelineStep s) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Text(
            s.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12,
              fontWeight: s.state == _TimelineState.pending
                  ? FontWeight.w600
                  : FontWeight.w800,
              color: s.state == _TimelineState.pending
                  ? AppColors.lightText4
                  : AppColors.lightText1,
            ),
          ),
          if (s.date != null) ...[
            const SizedBox(height: 2),
            Text(
              s.date!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
