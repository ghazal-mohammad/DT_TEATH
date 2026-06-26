// ════════════════════════════════════════════════════════════════════════════
// lab_dashboard_cubit.dart
//
// Cubit لوحة تحكم المخبر — يجلب قائمة الطلبات الحقيقية (LabOrdersRepository،
// singleton مع كاش) ويشتق منها عدّادات اللوحة. لا يعتمد على عدّادات الباك
// (countOrders…) لأنها ترجع أصفاراً حالياً.
// ════════════════════════════════════════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import 'lab_dashboard_state.dart';

class LabDashboardCubit extends Cubit<LabDashboardState> {
  LabDashboardCubit({required LabOrdersRepository ordersRepository})
      : _orders = ordersRepository,
        super(const LabDashboardState.initial());

  final LabOrdersRepository _orders;

  Future<void> load() async {
    emit(state.copyWith(status: LabDashboardStatus.loading, clearError: true));
    try {
      final orders = await _orders.getAll();
      emit(state.copyWith(status: LabDashboardStatus.loaded, orders: orders));
    } on Failure catch (f) {
      emit(state.copyWith(
          status: LabDashboardStatus.error, errorMessage: f.message));
    } catch (_) {
      emit(state.copyWith(status: LabDashboardStatus.error));
    }
  }
}
