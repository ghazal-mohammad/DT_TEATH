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
    this.saving = false,
    this.actionError,
  });

  final InvoicesStatus status;
  final List<PurchaseInvoice> invoices;
  final String? errorMessage;

  /// جارٍ إنشاء/تعديل فاتورة الآن (لتعطيل زر الحفظ).
  final bool saving;
  final String? actionError;

  int get count => invoices.length;
  double get totalAmount =>
      invoices.fold(0, (sum, inv) => sum + inv.totalAmount);

  PurchaseInvoicesState copyWith({
    InvoicesStatus? status,
    List<PurchaseInvoice>? invoices,
    String? errorMessage,
    bool? saving,
    String? actionError,
    bool clearActionError = false,
  }) =>
      PurchaseInvoicesState(
        status: status ?? this.status,
        invoices: invoices ?? this.invoices,
        errorMessage: errorMessage ?? this.errorMessage,
        saving: saving ?? this.saving,
        actionError: clearActionError ? null : (actionError ?? this.actionError),
      );

  @override
  List<Object?> get props =>
      [status, invoices, errorMessage, saving, actionError];
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

  Future<bool> create({
    required String supplierName,
    required DateTime invoiceDate,
    required List<PurchaseInvoiceItemInput> items,
    String? notes,
  }) =>
      _save(() => _repo.create(
            supplierName: supplierName,
            invoiceDate: invoiceDate,
            items: items,
            notes: notes,
          ));

  Future<bool> update(
    String id, {
    String? supplierName,
    DateTime? invoiceDate,
    String? notes,
  }) =>
      _save(() => _repo.update(
            id,
            supplierName: supplierName,
            invoiceDate: invoiceDate,
            notes: notes,
          ));

  Future<bool> _save(Future<PurchaseInvoice> Function() action) async {
    emit(state.copyWith(saving: true, clearActionError: true));
    try {
      await action();
      final list = await _repo.getAll();
      emit(state.copyWith(
          saving: false, status: InvoicesStatus.loaded, invoices: list));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(saving: false, actionError: f.message));
      return false;
    }
  }
}
