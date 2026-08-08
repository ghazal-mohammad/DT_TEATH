import 'package:dt_teeth/core/network/failure.dart';
import 'package:dt_teeth/features/warehouse/domain/entities/purchase_invoice.dart';
import 'package:dt_teeth/features/warehouse/domain/repositories/purchase_invoices_repository.dart';
import 'package:dt_teeth/features/warehouse/presentation/bloc/purchase_invoices_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements PurchaseInvoicesRepository {}

void main() {
  group('PurchaseInvoice.fromJson (formatInvoice)', () {
    test('يقرأ المورّد + الإجمالي (نصّي) + البنود', () {
      final inv = PurchaseInvoice.fromJson({
        'id': 3,
        'supplier_name': 'شركة الأمل',
        'invoice_date': '2026-05-10',
        'total_amount': '150000.00',
        'created_by': 'أحمد',
        'items': [
          {'id': 1, 'material': 'قفازات', 'unit': 'كرتونة', 'quantity': 10, 'unit_price': '15000', 'total_price': '150000'},
        ],
        'created_at': '2026-05-10 12:00:00',
      });
      expect(inv.id, '3');
      expect(inv.supplierName, 'شركة الأمل');
      expect(inv.totalAmount, 150000);
      expect(inv.createdBy, 'أحمد');
      expect(inv.itemsCount, 1);
      expect(inv.items.single.unitPrice, 15000);
      expect(inv.items.single.totalPrice, 150000);
    });

    test('بنود غائبة ⇒ قائمة فارغة', () {
      final inv = PurchaseInvoice.fromJson({'id': 1, 'supplier_name': 'x', 'total_amount': 0});
      expect(inv.items, isEmpty);
      expect(inv.itemsCount, 0);
    });
  });

  group('PurchaseInvoicesCubit', () {
    late _MockRepo repo;
    setUpAll(() {
      registerFallbackValue(DateTime(2026, 1, 1));
      registerFallbackValue(<PurchaseInvoiceItemInput>[]);
    });
    setUp(() => repo = _MockRepo());

    PurchaseInvoice inv(String id, double total) => PurchaseInvoice(
          id: id,
          supplierName: 'مورّد',
          totalAmount: total,
          items: const [],
        );

    test('load ينجح ⇒ العدد والإجمالي محسوبان', () async {
      when(() => repo.getAll())
          .thenAnswer((_) async => [inv('1', 100), inv('2', 250)]);
      final cubit = PurchaseInvoicesCubit(repo);
      await cubit.load();
      expect(cubit.state.status, InvoicesStatus.loaded);
      expect(cubit.state.count, 2);
      expect(cubit.state.totalAmount, 350);
    });

    test('load يفشل ⇒ error برسالة', () async {
      when(() => repo.getAll())
          .thenThrow(const ServerFailure('خطأ', code: '500'));
      final cubit = PurchaseInvoicesCubit(repo);
      await cubit.load();
      expect(cubit.state.status, InvoicesStatus.error);
      expect(cubit.state.errorMessage, 'خطأ');
    });

    test('create ينجح ⇒ يعيد تحميل القائمة وstatus=loaded', () async {
      when(() => repo.create(
            supplierName: any(named: 'supplierName'),
            invoiceDate: any(named: 'invoiceDate'),
            items: any(named: 'items'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async => inv('9', 500));
      when(() => repo.getAll()).thenAnswer((_) async => [inv('9', 500)]);

      final cubit = PurchaseInvoicesCubit(repo);
      final ok = await cubit.create(
        supplierName: 'مورّد جديد',
        invoiceDate: DateTime(2026, 8, 8),
        items: const [
          PurchaseInvoiceItemInput(
              materialId: '1',
              materialName: 'قفازات',
              quantity: 5,
              unitPrice: 100),
        ],
      );

      expect(ok, isTrue);
      expect(cubit.state.saving, isFalse);
      expect(cubit.state.status, InvoicesStatus.loaded);
      expect(cubit.state.count, 1);
    });

    test('create يفشل ⇒ actionError برسالة ولا يغيّر القائمة', () async {
      when(() => repo.create(
            supplierName: any(named: 'supplierName'),
            invoiceDate: any(named: 'invoiceDate'),
            items: any(named: 'items'),
            notes: any(named: 'notes'),
          )).thenThrow(const ServerFailure('فشل الإنشاء', code: '422'));

      final cubit = PurchaseInvoicesCubit(repo);
      final ok = await cubit.create(
        supplierName: 'مورّد',
        invoiceDate: DateTime(2026, 8, 8),
        items: const [
          PurchaseInvoiceItemInput(
              materialId: '1',
              materialName: 'قفازات',
              quantity: 5,
              unitPrice: 100),
        ],
      );

      expect(ok, isFalse);
      expect(cubit.state.saving, isFalse);
      expect(cubit.state.actionError, 'فشل الإنشاء');
      expect(cubit.state.invoices, isEmpty);
    });

    test('update ينجح ⇒ يعيد تحميل القائمة', () async {
      when(() => repo.update(
            any(),
            supplierName: any(named: 'supplierName'),
            invoiceDate: any(named: 'invoiceDate'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async => inv('1', 100));
      when(() => repo.getAll()).thenAnswer((_) async => [inv('1', 100)]);

      final cubit = PurchaseInvoicesCubit(repo);
      final ok = await cubit.update('1', supplierName: 'مورّد محدَّث');

      expect(ok, isTrue);
      expect(cubit.state.status, InvoicesStatus.loaded);
    });
  });
}
