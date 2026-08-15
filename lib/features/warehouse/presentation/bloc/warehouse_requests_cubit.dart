// ════════════════════════════════════════════════════════════════════════════
// warehouse_requests_cubit.dart
//
// Cubit طلبات المواد الواردة للمستودع: تحميل، فلترة بالحالة، تلبية/رفض. بعد كل
// إجراء ناجح يُعيد التحميل ليعكس الحالة الجديدة.
// ════════════════════════════════════════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/warehouse_request.dart';
import '../../domain/repositories/warehouse_requests_repository.dart';

enum RequestsStatus { initial, loading, loaded, error }

/// فلتر الحالة (الكل + الحالات الأربع).
enum RequestsFilter { all, newReq, inProgress, completed, rejected }

class WarehouseRequestsState extends Equatable {
  const WarehouseRequestsState({
    this.status = RequestsStatus.initial,
    this.requests = const [],
    this.filter = RequestsFilter.all,
    this.errorMessage,
    this.busyId,
    this.actionError,
  });

  final RequestsStatus status;
  final List<WarehouseRequest> requests;
  final RequestsFilter filter;
  final String? errorMessage;

  /// معرّف الطلب الذي تجري عليه عملية الآن (لتعطيل أزراره).
  final String? busyId;
  final String? actionError;

  List<WarehouseRequest> get filtered {
    switch (filter) {
      case RequestsFilter.all:
        return requests;
      case RequestsFilter.newReq:
        return requests
            .where((r) => r.status == WarehouseRequestStatus.newReq)
            .toList();
      case RequestsFilter.inProgress:
        return requests
            .where((r) => r.status == WarehouseRequestStatus.inProgress)
            .toList();
      case RequestsFilter.completed:
        return requests
            .where((r) => r.status == WarehouseRequestStatus.completed)
            .toList();
      case RequestsFilter.rejected:
        return requests
            .where((r) => r.status == WarehouseRequestStatus.rejected)
            .toList();
    }
  }

  int countOf(RequestsFilter f) {
    if (f == RequestsFilter.all) return requests.length;
    return WarehouseRequestsState(requests: requests, filter: f)
        .filtered
        .length;
  }

  WarehouseRequestsState copyWith({
    RequestsStatus? status,
    List<WarehouseRequest>? requests,
    RequestsFilter? filter,
    String? errorMessage,
    String? busyId,
    String? actionError,
    bool clearBusy = false,
    bool clearActionError = false,
  }) {
    return WarehouseRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
      busyId: clearBusy ? null : (busyId ?? this.busyId),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, requests, filter, errorMessage, busyId, actionError];
}

class WarehouseRequestsCubit extends Cubit<WarehouseRequestsState> {
  WarehouseRequestsCubit(this._repo) : super(const WarehouseRequestsState());

  final WarehouseRequestsRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: RequestsStatus.loading, clearActionError: true));
    try {
      final list = await _repo.getAll();
      emit(state.copyWith(status: RequestsStatus.loaded, requests: list));
    } on Failure catch (f) {
      emit(state.copyWith(
          status: RequestsStatus.error, errorMessage: f.message));
    }
  }

  void setFilter(RequestsFilter filter) => emit(state.copyWith(filter: filter));

  Future<bool> fulfill(String id, {String? notes}) =>
      _act(id, () => _repo.fulfill(id, notes: notes));

  Future<bool> reject(String id, {required String reason}) =>
      _act(id, () => _repo.reject(id, reason: reason));

  Future<bool> markPending(String id) => _act(id, () => _repo.markPending(id));

  Future<bool> _act(String id, Future<void> Function() action) async {
    emit(state.copyWith(busyId: id, clearActionError: true));
    try {
      await action();
      await load();
      emit(state.copyWith(clearBusy: true));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(clearBusy: true, actionError: f.message));
      return false;
    }
  }
}
