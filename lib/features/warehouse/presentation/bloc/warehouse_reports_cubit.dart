// ════════════════════════════════════════════════════════════════════════════
// warehouse_reports_cubit.dart
//
// Cubit تقرير مشتريات المستودع: يختار الفترة (شهري/أسبوعي/يومي/سنوي)، يحوّلها
// لنطاق from–to، ويحمّل التقرير. يوافق فترات ReportsView (0..3).
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/warehouse_dashboard_report.dart';
import '../../domain/entities/warehouse_purchases_report.dart';
import '../../domain/entities/warehouse_stock_movement_report.dart';
import '../../domain/repositories/warehouse_reports_repository.dart';

enum ReportsStatus { initial, loading, loaded, error }

class WarehouseReportsState extends Equatable {
  const WarehouseReportsState({
    this.status = ReportsStatus.initial,
    this.report,
    this.period = 0,
    this.errorMessage,
    this.stockMovementReport,
    this.stockMovementError,
    this.dashboardReport,
    this.dashboardError,
  });

  final ReportsStatus status;
  final WarehousePurchasesReport? report;

  /// 0=شهري · 1=أسبوعي · 2=يومي · 3=سنوي (يوافق ReportsView).
  final int period;
  final String? errorMessage;

  /// تبويب حركة المخزون (stock-movement) — تحميل مستقل عن تبويب المشتريات.
  final WarehouseStockMovementReport? stockMovementReport;
  final String? stockMovementError;

  /// تقرير التحليلات العام (تبويب "نظرة عامة") — تحميل مستقل عن باقي التبويبات.
  final WarehouseDashboardReport? dashboardReport;
  final String? dashboardError;

  WarehouseReportsState copyWith({
    ReportsStatus? status,
    WarehousePurchasesReport? report,
    int? period,
    String? errorMessage,
    bool clearErrorMessage = false,
    WarehouseStockMovementReport? stockMovementReport,
    String? stockMovementError,
    bool clearStockMovementError = false,
    WarehouseDashboardReport? dashboardReport,
    String? dashboardError,
    bool clearDashboardError = false,
  }) =>
      WarehouseReportsState(
        status: status ?? this.status,
        report: report ?? this.report,
        period: period ?? this.period,
        errorMessage:
            clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
        stockMovementReport: stockMovementReport ?? this.stockMovementReport,
        stockMovementError: clearStockMovementError
            ? null
            : (stockMovementError ?? this.stockMovementError),
        dashboardReport: dashboardReport ?? this.dashboardReport,
        dashboardError: clearDashboardError
            ? null
            : (dashboardError ?? this.dashboardError),
      );

  @override
  List<Object?> get props => [
        status,
        report,
        period,
        errorMessage,
        stockMovementReport,
        stockMovementError,
        dashboardReport,
        dashboardError,
      ];
}

class WarehouseReportsCubit extends Cubit<WarehouseReportsState> {
  WarehouseReportsCubit(this._repo) : super(const WarehouseReportsState());

  final WarehouseReportsRepository _repo;

  // ── حماية من نتائج قديمة تصل متأخّرة (race) ────────────────────────────
  //
  // تبديل الفترة (شهري/أسبوعي/يومي/سنوي) بسرعة يطلق أكثر من طلب لنفس التبويب
  // بالتوازي؛ لو رجعت النتيجة الأقدم بعد الأحدث (شبكة غير مضمونة الترتيب)،
  // كانت تكتب فوق بيانات الفترة الجديدة الصحيحة ببيانات الفترة القديمة بصمت.
  // كل تبويب معه عدّاد طلبات مستقل: يزيد عند بداية كل جلب، ونتجاهل أي نتيجة
  // ما عاد رقمها هو الأحدث عند وصولها.
  int _purchasesReq = 0;
  int _stockReq = 0;
  int _dashboardReq = 0;

  Future<void> load([int? period]) async {
    final p = period ?? state.period;
    final reqId = ++_purchasesReq;
    emit(state.copyWith(status: ReportsStatus.loading, period: p));
    final (from, to) = _range(p);
    try {
      final report = await _repo.getPurchasesReport(from: from, to: to);
      if (reqId != _purchasesReq) return; // فترة تغيّرت أثناء الجلب.
      emit(state.copyWith(status: ReportsStatus.loaded, report: report));
    } on Failure catch (f) {
      if (reqId != _purchasesReq) return;
      emit(state.copyWith(
          status: ReportsStatus.error, errorMessage: f.message));
    } catch (_) {
      // أي استثناء غير متوقع (شكل استجابة غير معروف مثلاً) — بلا هالسطر كان
      // الكيوبت يضل عالقاً على "جاري التحميل" للأبد بلا رسالة ولا زر إعادة
      // محاولة، هيك كانت الحالة الحقيقية وراء "ما بيفتح".
      if (reqId != _purchasesReq) return;
      emit(state.copyWith(status: ReportsStatus.error));
    }
  }

  void changePeriod(int period) {
    if (period == state.period) return;
    load(period);
  }

  /// تبويب حركة المخزون — يستخدم نفس نطاق الفترة الحالية (state.period).
  Future<void> loadStockMovement() async {
    final reqId = ++_stockReq;
    final (from, to) = _range(state.period);
    try {
      final report = await _repo.getStockMovementReport(from: from, to: to);
      if (reqId != _stockReq) return;
      emit(state.copyWith(
          stockMovementReport: report, clearStockMovementError: true));
    } on Failure catch (f) {
      if (reqId != _stockReq) return;
      emit(state.copyWith(stockMovementError: f.message));
    } catch (_) {
      if (reqId != _stockReq) return;
      emit(state.copyWith(
          stockMovementError: 'تعذّر جلب تقرير حركة المخزون.'));
    }
  }

  /// تبويب "نظرة عامة" (reports/dashboard) — الباك يقبل week|month فقط (لا
  /// يوافق مؤشّر الفترة 0..3 المستخدم بباقي التبويبات)، لذا افتراضياً 'month'.
  Future<void> loadDashboard([String period = 'month']) async {
    final reqId = ++_dashboardReq;
    try {
      final report = await _repo.getDashboardReport(period: period);
      if (reqId != _dashboardReq) return;
      emit(state.copyWith(
          dashboardReport: report, clearDashboardError: true));
    } on Failure catch (f) {
      if (reqId != _dashboardReq) return;
      emit(state.copyWith(dashboardError: f.message));
    } catch (_) {
      if (reqId != _dashboardReq) return;
      emit(state.copyWith(dashboardError: 'تعذّر جلب تقرير النظرة العامة.'));
    }
  }

  /// يحوّل مؤشّر الفترة إلى نطاق (from, to).
  (DateTime, DateTime) _range(int period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case 1: // أسبوعي — آخر 7 أيام.
        return (today.subtract(const Duration(days: 6)), today);
      case 2: // يومي — اليوم.
        return (today, today);
      case 3: // سنوي — من بداية السنة.
        return (DateTime(now.year, 1, 1), today);
      case 0: // شهري — من بداية الشهر.
      default:
        return (DateTime(now.year, now.month, 1), today);
    }
  }
}
