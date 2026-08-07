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
  });
}
