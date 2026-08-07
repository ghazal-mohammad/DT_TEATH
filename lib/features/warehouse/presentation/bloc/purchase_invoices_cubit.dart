// ════════════════════════════════════════════════════════════════════════════
// purchase_invoices_cubit.dart
//
// Cubit فواتير الشراء (عرض): تحميل + ملخّص (العدد + الإجمالي).
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/purchase_invoice.dart';
import '../../domain/repositories/purchase_invoices_repository.dart';

enum InvoicesStatus { initial, loading, loaded, error }

class PurchaseInvoicesState extends Equatable {
  const PurchaseInvoicesState({
    this.status = InvoicesStatus.initial,
    this.invoices = const [],
    this.errorMessage,
  });

  final InvoicesStatus status;
  final List<PurchaseInvoice> invoices;
  final String? errorMessage;

  int get count => invoices.length;
  double get totalAmount =>
      invoices.fold(0, (sum, inv) => sum + inv.totalAmount);

  PurchaseInvoicesState copyWith({
    InvoicesStatus? status,
    List<PurchaseInvoice>? invoices,
    String? errorMessage,
  }) =>
      PurchaseInvoicesState(
        status: status ?? this.status,
        invoices: invoices ?? this.invoices,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, invoices, errorMessage];
}

class PurchaseInvoicesCubit extends Cubit<PurchaseInvoicesState> {
  PurchaseInvoicesCubit(this._repo) : super(const PurchaseInvoicesState());

  final PurchaseInvoicesRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: InvoicesStatus.loading));
    try {
      final list = await _repo.getAll();
      emit(state.copyWith(status: InvoicesStatus.loaded, invoices: list));
    } on Failure catch (f) {
      emit(state.copyWith(
          status: InvoicesStatus.error, errorMessage: f.message));
    }
  }
}
