// ════════════════════════════════════════════════════════════════════════════
// app_data_table.dart
//
// جدول البيانات الموحّد — `.tbl`, `.tbl thead th`, `.tbl tbody td`
// المرجع: DT_Teeth_Lab_v12_Enhanced.html — الأسطر 741–755
//
// القواعد الأصلية:
//   .tbl { width:100%; border-collapse:collapse }
//   .tbl thead th {
//     text-align:right; padding:12px 18px;
//     font-size:11.5px; font-weight:700; color:var(--t4);
//     letter-spacing:0.8px; text-transform:uppercase;
//     background:rgba(158,251,236,0.06);
//     border-bottom:1px solid var(--cyan-brd);
//   }
//   .tbl tbody td {
//     padding:14px 18px;
//     border-bottom:1px solid rgba(158,251,236,0.06);
//     font-size:15px; vertical-align:middle;
//   }
//   .tbl tbody tr:last-child td { border-bottom:none }
//   .tbl tbody tr:hover td { background:rgba(158,251,236,0.04) }
//
// مزايا إضافية (ما في HTML الأصلي لكن محتاجها المطوّر):
//   - Sorting تصاعدي/تنازلي عند النقر على الـ header
//   - Empty state مع أيقونة ورسالة
//   - Loading state (shimmer على الصفوف)
//   - الـ column يمكن أن تكون flex أو ثابت العرض
//   - horizontal scroll إذا كان الـ content أكبر من الـ width
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';

/// تعريف عمود في الجدول.
class AppDataColumn<T> {
  const AppDataColumn({
    required this.label,
    required this.cellBuilder,
    this.width,
    this.flex,
    this.sortable = false,
    this.sortValue,
    this.alignment = Alignment.centerRight, // RTL default
  }) : assert(
         width != null || flex != null,
         'Either width or flex must be provided',
       );

  /// عنوان العمود (يظهر في thead).
  final String label;

  /// بنّاء الخلية — يستقبل العنصر ويُرجع Widget.
  final Widget Function(T item) cellBuilder;

  /// العرض الثابت بالـ pixels (اختر flex OR width).
  final double? width;

  /// Flex factor لتوزيع المساحة المتاحة.
  final int? flex;

  /// هل يُمكن الفرز حسب هذا العمود؟
  final bool sortable;

  /// دالّة استخراج القيمة للفرز (مطلوبة عند sortable=true).
  final Comparable Function(T item)? sortValue;

  /// محاذاة النص في الخلية (الافتراضي يمين للـ RTL).
  final Alignment alignment;
}

/// حالة الفرز.
class _SortState {
  const _SortState({required this.columnIndex, required this.ascending});
  final int columnIndex;
  final bool ascending;
}

/// جدول بيانات موحّد للنظام.
///
/// مثال:
/// ```dart
/// AppDataTable<Material>(
///   data: materials,
///   columns: [
///     AppDataColumn(
///       label: 'المادة',
///       flex: 3,
///       cellBuilder: (m) => Text(m.name),
///       sortable: true,
///       sortValue: (m) => m.name,
///     ),
///     AppDataColumn(
///       label: 'الكمية',
///       width: 100,
///       cellBuilder: (m) => Text('${m.quantity}'),
///     ),
///     AppDataColumn(
///       label: 'الحالة',
///       width: 140,
///       cellBuilder: (m) => AppBadge(...),
///     ),
///   ],
///   emptyMessage: 'لا توجد مواد حالياً',
///   emptyIcon: Icons.inventory_2_outlined,
/// )
/// ```
class AppDataTable<T> extends StatefulWidget {
  const AppDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.isLoading = false,
    this.emptyMessage = 'لا توجد بيانات',
    this.emptyIcon = Icons.inbox_outlined,
    this.onRowTap,
    this.rowHeight,
  });

  final List<T> data;
  final List<AppDataColumn<T>> columns;
  final bool isLoading;
  final String emptyMessage;
  final IconData emptyIcon;
  final ValueChanged<T>? onRowTap;
  final double? rowHeight;

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  _SortState? _sortState;

  List<T> get _sortedData {
    if (_sortState == null) return widget.data;
    final col = widget.columns[_sortState!.columnIndex];
    if (col.sortValue == null) return widget.data;
    final sorted = [...widget.data];
    sorted.sort((a, b) {
      final cmp = col.sortValue!(a).compareTo(col.sortValue!(b));
      return _sortState!.ascending ? cmp : -cmp;
    });
    return sorted;
  }

  void _onHeaderTap(int index) {
    final col = widget.columns[index];
    if (!col.sortable) return;
    setState(() {
      if (_sortState?.columnIndex == index) {
        _sortState = _SortState(
          columnIndex: index,
          ascending: !_sortState!.ascending,
        );
      } else {
        _sortState = _SortState(columnIndex: index, ascending: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty && !widget.isLoading) return _buildEmptyState();

    // نستخدم LayoutBuilder لالتقاط العرض المتاح (محدود دائماً لأن الجدول
    // يُوضع داخل Column أو Container ذي عرض مقيّد من الـ scaffold/shell).
    // نمرر هذا العرض إلى SizedBox بدلاً من ConstrainedBox(minWidth فقط)
    // حتى يحصل Column على قيود محدودة من الجانبين ولا يحاول التمدد للانهاية.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 600.0; // عرض افتراضي آمن عند Infinity

        final List<Widget> rows = widget.isLoading
            ? [
                _buildHeader(),
                ...List.generate(5, (i) => _buildSkeletonRow(i == 4)),
              ]
            : [
                _buildHeader(),
                ..._sortedData.asMap().entries.map((entry) {
                  final isLast = entry.key == _sortedData.length - 1;
                  return _buildRow(entry.value, isLast);
                }),
              ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          // SizedBox بعرض محدد يمنح Column قيوداً مقيّدة من الجانبين
          // فلا يتلقى maxWidth=Infinity الذي كان يسبب الـ crash.
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x0F9EFBEC), // rgba(158,251,236,0.06)
        border: Border(
          bottom: BorderSide(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
      ),
      child: Row(
        children: List.generate(widget.columns.length, (i) {
          final col = widget.columns[i];
          final isSorted = _sortState?.columnIndex == i;

          return _wrapColumn(
            col,
            InkWell(
              onTap: col.sortable ? () => _onHeaderTap(i) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                alignment: col.alignment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        col.label.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isLight
                              ? AppColors.lightText4
                              : AppColors.darkText4,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (col.sortable) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isSorted
                            ? (_sortState!.ascending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                            : Icons.unfold_more,
                        size: 12,
                        color: isSorted
                            ? AppColors.accent
                            : (isLight
                                  ? AppColors.lightText4
                                  : AppColors.darkText4),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRow(T item, bool isLast) {
    return _DataTableRow<T>(
      item: item,
      columns: widget.columns,
      isLast: isLast,
      onTap: widget.onRowTap,
      rowHeight: widget.rowHeight,
      wrapColumn: _wrapColumn,
    );
  }

  /// يحدّد كيفية تخصيص العرض لعمود (Expanded بـ flex أو SizedBox ثابت).
  Widget _wrapColumn(AppDataColumn<T> col, Widget child) {
    if (col.width != null) {
      return SizedBox(width: col.width, child: child);
    }
    return Expanded(flex: col.flex!, child: child);
  }

  Widget _buildEmptyState() {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.emptyIcon,
              size: 56,
              color: isLight
                  ? AppColors.lightText4.withValues(alpha: 0.5)
                  : AppColors.darkText4.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              widget.emptyMessage,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isLight ? AppColors.lightText3 : AppColors.darkText3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonRow(bool isLast) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : const Color(0x0F9EFBEC), // 0.06
          ),
        ),
      ),
      child: Row(
        children: widget.columns.map((c) {
          return _wrapColumn(
            c,
            Container(
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: (isLight ? Colors.black : Colors.white).withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// صف فردي مع hover state.
///
/// مُستخرج في كلاس منفصل لأن كل صف يحتاج state خاص بالـ hover.
class _DataTableRow<T> extends StatefulWidget {
  const _DataTableRow({
    required this.item,
    required this.columns,
    required this.isLast,
    required this.onTap,
    required this.rowHeight,
    required this.wrapColumn,
  });

  final T item;
  final List<AppDataColumn<T>> columns;
  final bool isLast;
  final ValueChanged<T>? onTap;
  final double? rowHeight;
  final Widget Function(AppDataColumn<T>, Widget) wrapColumn;

  @override
  State<_DataTableRow<T>> createState() => _DataTableRowState<T>();
}

class _DataTableRowState<T> extends State<_DataTableRow<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Widget row = AnimatedContainer(
      duration: const Duration(milliseconds: 120), // transition 0.12s
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: _isHovered
            ? const Color(0x0A9EFBEC) // rgba(158,251,236,0.04)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: widget.isLast
                ? Colors.transparent
                : const Color(0x0F9EFBEC), // 0.06
          ),
        ),
      ),
      child: Row(
        children: widget.columns.map((col) {
          return widget.wrapColumn(
            col,
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              alignment: col.alignment,
              child: col.cellBuilder(widget.item),
            ),
          );
        }).toList(),
      ),
    );

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.item) : null,
        behavior: HitTestBehavior.opaque,
        child: row,
      ),
    );
  }
}
