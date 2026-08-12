// ════════════════════════════════════════════════════════════════════════════
// lab_orders_cubit.dart
//
// Cubit لإدارة state صفحة طلبات الأطباء — يطابق نمط MaterialsCubit.
// المسؤوليات: تحميل الطلبات، الفلترة، معالجة طلب (حالة/منفّذ).
//
// ملاحظة فصل: استهلاك المخزون (LabStockRepository) يبقى side-effect بالصفحة،
// فالـ Cubit مسؤول عن الطلبات فقط (single responsibility).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import 'lab_orders_state.dart';

/// Cubit لإدارة صفحة طلبات الأطباء.
class LabOrdersCubit extends Cubit<LabOrdersState> {
  LabOrdersCubit({required LabOrdersRepository repository})
      : _repository = repository,
        super(const LabOrdersState.initial());

  final LabOrdersRepository _repository;
  StreamSubscription<List<LabOrderFull>>? _subscription;

  /// يبدأ تحميل الطلبات. عند إعادة الزيارة يعرض الكاش فوراً (بلا شيمر) ثم يحدّث
  /// صامتاً (stale-while-revalidate)، ويشترك بالـ stream للتحديث التلقائي.
  Future<void> load() async {
    final cached = _repository.cached;
    if (cached != null) {
      emit(state.copyWith(
          status: LabOrdersStatus.loaded, orders: cached, clearError: true));
    } else {
      emit(state.copyWith(status: LabOrdersStatus.loading, clearError: true));
    }
    try {
      final orders = await _repository.getAll();
      emit(state.copyWith(
        status: LabOrdersStatus.loaded,
        orders: orders,
        clearError: true,
      ));
    } catch (e) {
      // لا نُظهر خطأ فوق بيانات كاش صالحة.
      if (cached == null) {
        emit(state.copyWith(
          status: LabOrdersStatus.error,
          errorMessage: userMessageFromError(e),
        ));
      }
    }
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (list) => emit(state.copyWith(orders: list)),
      onError: (Object e) => emit(state.copyWith(
        status: LabOrdersStatus.error,
        errorMessage: userMessageFromError(e),
      )),
    );
  }

  /// تغيير الفلتر النشط.
  void setFilter(String filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  /// تحديث نص البحث المُوجَّه لهذه الصفحة.
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  /// تبديل وضع "طلبات اليوم". عند التفعيل يجلب طلبات اليوم من الباك
  /// (showAllTodayLabOrders). يرجّع false عند فشل الجلب (يعود للكل).
  Future<bool> setTodayOnly(bool value) async {
    if (value == state.todayOnly) return true;
    if (!value) {
      // العودة للكل — قائمة orders محدّثة أصلاً من الـ stream.
      emit(state.copyWith(todayOnly: false, clearError: true));
      return true;
    }
    try {
      final today = await _repository.getToday();
      emit(state.copyWith(
          todayOnly: true, todayOrders: today, clearError: true));
      return true;
    } catch (e) {
      emit(state.copyWith(
        todayOnly: false,
        errorMessage: userMessageFromError(e),
      ));
      return false;
    }
  }

  /// معالجة طلب: تحديث الحالة + المخبري المنفّذ.
  /// (الـ stream يحدّث القائمة تلقائياً بعد التطبيق.) يُرجع false عند الفشل
  /// (الباك رفض الانتقال مثلاً) كي تُظهر الصفحة رسالة واضحة — لا فشل صامت.
  Future<bool> processOrder({
    required String id,
    required LabOrderBadgeVariant status,
    String? technician,
  }) async {
    try {
      await _repository.processOrder(
        id: id,
        status: status,
        technician: technician,
      );
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: LabOrdersStatus.error,
        errorMessage: userMessageFromError(e),
      ));
      return false;
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
