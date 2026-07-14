// ════════════════════════════════════════════════════════════════════════════
// lab_technicians_cubit.dart
//
// Cubit لإدارة شاشة المخبريين — يجلب الفنيين عبر LabRepository (الباك)، ويدير
// التوكيل والإيقاف محلياً (الحقول غير المدعومة بالباك).
//
// حدّ نظيف: التسميات المترجمة (الدور + "بانتظار التوكيل") تُمرَّر من الـ UI إلى
// [load] — الـ Cubit لا يلمس BuildContext.
// ════════════════════════════════════════════════════════════════════════════

import 'package:characters/characters.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../data/models/lab_technician.dart';
import '../../domain/entities/lab_order.dart';
import '../../domain/repositories/lab_repository.dart';
import '../widgets/technicians/lab_technician_view_data.dart';
import 'lab_technicians_state.dart';

/// Cubit إدارة فريق المخبر.
class LabTechniciansCubit extends Cubit<LabTechniciansState> {
  LabTechniciansCubit({required LabRepository repository})
      : _repository = repository,
        super(const LabTechniciansState.initial()) {
    _orders = _seedOrders();
  }

  final LabRepository _repository;
  late List<LabOrderFull> _orders;

  /// يجلب الفنيين من الباك ويمابّهم لنماذج العرض.
  /// [roleLabel] و [pendingLabel] تسميات مترجمة يحلّها الـ UI ويمرّرها.
  Future<void> load({
    required String roleLabel,
    required String pendingLabel,
  }) async {
    // عند إعادة الزيارة نعرض الكاش فوراً (بلا شيمر) ثم نحدّث صامتاً (SWR).
    final cachedTechs = _repository.cachedTechnicians;
    if (cachedTechs != null) {
      emit(state.copyWith(
        status: LabTechniciansStatus.loaded,
        technicians: _mapTechnicians(cachedTechs, roleLabel, pendingLabel),
        orders: _orders,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(
          status: LabTechniciansStatus.loading, clearError: true));
    }
    try {
      final techs = await _repository.getTechnicians();
      emit(state.copyWith(
        status: LabTechniciansStatus.loaded,
        technicians: _mapTechnicians(techs, roleLabel, pendingLabel),
        orders: _orders,
        clearError: true,
      ));
    } on Failure catch (f) {
      // لا نُظهر خطأ فوق بيانات كاش صالحة.
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

  /// يحوّل فنّيي الباك إلى نماذج عرض (التسميات المترجمة تُمرَّر من الـ UI).
  List<TechnicianItem> _mapTechnicians(
    List<LabTechnician> techs,
    String roleLabel,
    String pendingLabel,
  ) {
    return techs
        .map((t) => TechnicianItem(
              id: t.id,
              name: t.name,
              role: roleLabel,
              shift: '—', // غير متوفّر بالباك
              currentTask: pendingLabel,
              taskCount: 0,
              status: TechnicianStatus.available,
              initials: _computeInitials(t.name),
            ))
        .toList();
  }

  /// تحديث نص البحث المُوجَّه لهذه الصفحة.
  void setSearchQuery(String query) {
    if (query == state.searchQuery) return;
    emit(state.copyWith(searchQuery: query));
  }

  /// توكيل طلبية لمخبري: تسجيل المنفّذ على الطلب + نقله لقيد التصنيع +
  /// زيادة عدّاد مهام المخبري وجعله نشطاً (UC70/UC71).
  void assign(TechnicianItem tech, String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx].assignedTechnician = tech.name;
      if (_orders[idx].statusVariant == LabOrderBadgeVariant.newOrder) {
        _orders[idx].statusVariant = LabOrderBadgeVariant.manufacturing;
      }
    }
    tech.taskCount += 1;
    tech.status = TechnicianStatus.active;
    emit(state.copyWith(
      technicians: List.of(state.technicians),
      orders: List.of(_orders),
    ));
  }

  /// تبديل حالة المخبري بين نشط ومستراح.
  void togglePause(TechnicianItem tech) {
    if (tech.status == TechnicianStatus.onBreak ||
        tech.status == TechnicianStatus.available) {
      tech.status = TechnicianStatus.active;
    } else {
      tech.status = TechnicianStatus.onBreak;
    }
    emit(state.copyWith(technicians: List.of(state.technicians)));
  }

  static String _computeInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.firstOrNull ?? '?';
    return '${parts[0].characters.firstOrNull ?? ''}${parts[1].characters.firstOrNull ?? ''}';
  }

  static List<LabOrderFull> _seedOrders() => [
        LabOrderFull(
          id: 'LAB-045',
          doctor: 'د. سارة',
          type: 'تلبيسة',
          material: 'PFM',
          tooth: '#14',
          date: '27-03-2026',
          statusVariant: LabOrderBadgeVariant.newOrder,
        ),
        LabOrderFull(
          id: 'LAB-044',
          doctor: 'د. خالد',
          type: 'جسر',
          material: 'Zirconia',
          tooth: '#14-12',
          date: '28-03-2026',
          statusVariant: LabOrderBadgeVariant.manufacturing,
        ),
        LabOrderFull(
          id: 'LAB-042',
          doctor: 'د. سارة',
          type: 'وجه',
          material: 'E-max',
          tooth: '#21',
          date: '27-03-2026',
          statusVariant: LabOrderBadgeVariant.manufacturing,
        ),
        LabOrderFull(
          id: 'LAB-041',
          doctor: 'د. ليلى',
          type: 'طقم',
          material: 'Acrylic',
          tooth: '#كامل',
          date: '02-04-2026',
          statusVariant: LabOrderBadgeVariant.newOrder,
        ),
        LabOrderFull(
          id: 'LAB-040',
          doctor: 'د. خالد',
          type: 'تلبيسة',
          material: 'Zirconia',
          tooth: '#26',
          date: '29-03-2026',
          statusVariant: LabOrderBadgeVariant.manufacturing,
        ),
      ];
}
