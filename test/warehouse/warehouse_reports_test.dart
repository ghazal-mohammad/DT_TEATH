import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_purchases_report.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_stock_movement_report.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/warehouse_material_requests_report.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/warehouse_reports_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/warehouse_reports_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements WarehouseReportsRepository {}

void main() {
  group('WarehousePurchasesReport.fromJson', () {
    test('يقرأ الملخّص + الإنفاق حسب المورّد والشهر', () {
      final r = WarehousePurchasesReport.fromJson({
        'data': {
          'summary': {'total_invoices': 6, 'total_spending': '315000'},
          'by_supplier': [
            {'supplier': 'الأمل', 'invoice_count': 4, 'total_spending': 200000},
            {'supplier': 'النهضة', 'invoice_count': 2, 'total_spending': 115000},
          ],
          'by_month': [
            {'month': '2026-05', 'invoice_count': 6, 'total_spending': 315000},
          ],
        }
      });
      expect(r.totalInvoices, 6);
      expect(r.totalSpending, 315000);
      expect(r.bySupplier.length, 2);
      expect(r.bySupplier.first.label, 'الأمل');
      expect(r.bySupplier.first.spending, 200000);
      expect(r.byMonth.single.label, '2026-05');
    });

    test('استجابة فارغة ⇒ أصفار وقوائم فارغة', () {
      final r = WarehousePurchasesReport.fromJson({});
      expect(r.totalInvoices, 0);
      expect(r.bySupplier, isEmpty);
      expect(r.byMonth, isEmpty);
    });
  });

  group('WarehouseReportsCubit', () {
    late _MockRepo repo;
    setUp(() {
      repo = _MockRepo();
      when(() => repo.getPurchasesReport(
              from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => const WarehousePurchasesReport(
                totalInvoices: 3,
                totalSpending: 1000,
                bySupplier: [],
                byMonth: [],
              ));
    });

    test('load ينجح ⇒ loaded مع التقرير', () async {
      final cubit = WarehouseReportsCubit(repo);
      await cubit.load();
      expect(cubit.state.status, ReportsStatus.loaded);
      expect(cubit.state.report?.totalInvoices, 3);
    });

    test('changePeriod يبدّل الفترة ويعيد التحميل', () async {
      final cubit = WarehouseReportsCubit(repo);
      await cubit.load(0);
      cubit.changePeriod(3); // سنوي
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.period, 3);
      verify(() => repo.getPurchasesReport(
          from: any(named: 'from'), to: any(named: 'to'))).called(2);
    });

    test('load يفشل ⇒ error برسالة', () async {
      when(() => repo.getPurchasesReport(
              from: any(named: 'from'), to: any(named: 'to')))
          .thenThrow(const NetworkFailure());
      final cubit = WarehouseReportsCubit(repo);
      await cubit.load();
      expect(cubit.state.status, ReportsStatus.error);
    });

    test('loadStockMovement ينجح ⇒ stockMovementReport محمّل', () async {
      when(() => repo.getStockMovementReport(
              from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => const WarehouseStockMovementReport(
                totalIncoming: 500,
                totalOutgoing: 320,
                totalMovements: 47,
                incoming: [],
                outgoing: [],
              ));
      final cubit = WarehouseReportsCubit(repo);
      await cubit.loadStockMovement();
      expect(cubit.state.stockMovementReport?.totalMovements, 47);
      expect(cubit.state.stockMovementError, isNull);
    });

    test('loadStockMovement يفشل ⇒ stockMovementError برسالة', () async {
      when(() => repo.getStockMovementReport(
              from: any(named: 'from'), to: any(named: 'to')))
          .thenThrow(const NetworkFailure());
      final cubit = WarehouseReportsCubit(repo);
      await cubit.loadStockMovement();
      expect(cubit.state.stockMovementReport, isNull);
      expect(cubit.state.stockMovementError, isNotNull);
    });

    test('loadMaterialRequests ينجح ⇒ materialRequestsReport محمّل', () async {
      when(() => repo.getMaterialRequestsReport(
              from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => const WarehouseMaterialRequestsReport(
                totalRequests: 32,
                fulfilledCount: 0,
                rejectedCount: 3,
                pendingCount: 5,
                fulfillmentRate: '0%',
                byRequester: [],
                requests: [],
              ));
      final cubit = WarehouseReportsCubit(repo);
      await cubit.loadMaterialRequests();
      expect(cubit.state.materialRequestsReport?.totalRequests, 32);
      expect(cubit.state.materialRequestsError, isNull);
    });
  });
}
