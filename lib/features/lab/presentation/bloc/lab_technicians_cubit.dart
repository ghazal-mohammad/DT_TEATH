// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_cubit.dart
//
// Cubit لإدارة شاشة المخبريين — يجلب الفنيين عبر LabRepository والطلبات
// الحقيقية عبر LabOrdersRepository (لا قائمة مزروعة محلياً). "توكيل طلبية"
// يستدعي processOrder الحقيقي (setStatusInProgress بالباك) — نفس مسار معالجة
// الطلب المستخدم بصفحة الطلبات، لا نسخة موازية وهمية.
//
// حدّ نظيف: التسميات المترجمة (الدور + "بانتظار التوكيل") تُمرَّر من الـ UI إلى
// [load] — الـ Cubit لا يلمس BuildContext.
// ════════════════════════════════════════════════════════════════════════════

import 'package:characters/characters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../data/models/lab_technician.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_orders_repository.dart';
import '../../domain/repositories/lab_repository.dart';
import '../widgets/technicians/lab_technician_view_data.dart';
import 'lab_technicians_state.dart';

/// Cubit إدارة فريق المخبر.
class LabTechniciansCubit extends Cubit<LabTechniciansState> {
  LabTechniciansCubit({
    required LabRepository repository,
    required LabOrdersRepository ordersRepository,
  })  : _repository = repository,
        _ordersRepository = ordersRepository,
        super(const LabTechniciansState.initial());

  final LabRepository _repository;
  final LabOrdersRepository _ordersRepository;

  // آخر تسميات مترجمة مُمرَّرة لـ load — تُستخدم لإعادة البناء بعد assign
  // بلا حاجة نمرّرها من جديد من الصفحة.
  String _roleLabel = '';
  String _pendingLabel = '';

  /// يجلب الفنيين من الباك ويمابّهم لنماذج العرض + الطلبات الحقيقية القابلة
  /// للتوكيل (حالة "جديد" فقط — هي الوحيدة التي يقبلها الباك لـ setInProgress).
  /// [roleLabel] و [pendingLabel] تسميات مترجمة يحلّها الـ UI ويمرّرها.
  Future<void> load({
    required String roleLabel,
    required String pendingLabel,
  }) async {
    _roleLabel = roleLabel;
    _pendingLabel = pendingLabel;

    // عند إعادة الزيارة نعرض الكاش فوراً (بلا شيمر) ثم نحدّث صامتاً (SWR).
    final cachedTechs = _repository.cachedTechnicians;
    if (cachedTechs != null) {
      final cachedFetch = await _fetchOrders();
      emit(state.copyWith(
        status: LabTechniciansStatus.loaded,
        technicians: _mapTechnicians(
            cachedTechs, cachedFetch.orders, roleLabel, pendingLabel),
        orders: _assignable(cachedFetch.orders),
        clearError: true,
        ordersLoadFailed: cachedFetch.failed,
      ));
    } else {
      emit(state.copyWith(
          status: LabTechniciansStatus.loading, clearError: true));
    }
    try {
      final techs = await _repository.getTechnicians();
      final fetch = await _fetchOrders();
      emit(state.copyWith(
        status: LabTechniciansStatus.loaded,
        technicians:
            _mapTechnicians(techs, fetch.orders, roleLabel, pendingLabel),
        orders: _assignable(fetch.orders),
        clearError: true,
        ordersLoadFailed: fetch.failed,
      ));
    } on Failure catch (f) {
      if (cachedTechs == null) {
        emit(state.copyWith(
            status: LabTechniciansStatus.error, errorMessage: f.message));
      }
    } catch (_) {
      if (cachedTechs == null) {
        emit(state.copyWith(status: LabTechniciansStatus.error));
      }
    }

    // تقرير أداء الفنّيين (الشهر الحالي) — لا يحجب عرض الفريق، وفشله صامت.
    try {
      final perf = await _repository.getTechniciansPerformance();
      emit(state.copyWith(performance: perf));
    } catch (_) {/* تجاهل بصمت */}
  }

  /// يوكّل طلبية جديدة لفنّي عبر processOrder الحقيقي (setStatusInProgress).
  /// يُرجع false عند رفض الباك (فنّي مشغول، طلب غير "جديد"...) مع رسالة واضحة.
  Future<bool> assign(TechnicianItem tech, String orderId) async {
    try {
      await _ordersRepository.processOrder(
        id: orderId,
        status: LabOrderBadgeVariant.manufacturing,
        technician: tech.name,
      );
      await load(roleLabel: _roleLabel, pendingLabel: _pendingLabel);
      return true;
    } catch (e) {
      emit(state.copyWith(errorMessage: userMessageFromError(e)));
      return false;
    }
  }

  /// يجلب الطلبات، ويميّز صراحةً بين "لا طلبات" و"فشل الجلب" — حتى لا تُعرض
  /// حمل عمل الفنّيين كصفر (بانتظار التوكيل) وكأنها حقيقة مؤكّدة عند فشل شبكي.
  Future<({List<LabOrderFull> orders, bool failed})> _fetchOrders() async {
    try {
      return (orders: await _ordersRepository.getAll(), failed: false);
    } catch (_) {
      return (orders: const <LabOrderFull>[], failed: true);
    }
  }

  /// الطلبات "الجديدة" فقط — هي الوحيدة القابلة للتوكيل بحكم الباك.
  List<LabOrderFull> _assignable(List<LabOrderFull> orders) => orders
      .where((o) => o.statusVariant == LabOrderBadgeVariant.newOrder)
      .toList(growable: false);

  /// يحوّل فنّيي الباك إلى نماذج عرض. المهمة الحالية وعدّادها مُشتقّان من
  /// الطلبات الحقيقية المسندة لهذا الفنّي (قيد التصنيع)، لا قيمة وهمية.
  List<TechnicianItem> _mapTechnicians(
    List<LabTechnician> techs,
    List<LabOrderFull> orders,
    String roleLabel,
    String pendingLabel,
  ) {
    return techs.map((t) {
      final assigned = orders
          .where((o) =>
              o.assignedTechnician == t.name &&
              o.statusVariant == LabOrderBadgeVariant.manufacturing)
          .toList();
      return TechnicianItem(
        id: t.id,
        name: t.name,
        role: roleLabel,
        shift: '—', // غير متوفّر بالباك
        currentTask: assigned.isEmpty ? pendingLabel : assigned.first.type,
        taskCount: assigned.length,
        initials: _computeInitials(t.name),
      );
    }).toList();
  }

  /// تحديث نص البحث المُوجَّه لهذه الصفحة.
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  static String _computeInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.firstOrNull ?? '?';
    return '${parts[0].characters.firstOrNull ?? ''}${parts[1].characters.firstOrNull ?? ''}';
  }
}
