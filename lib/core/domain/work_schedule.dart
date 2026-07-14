// ════════════════════════════════════════════════════════════════════════════
// work_schedule.dart (core/domain)
//
// نموذج جدول الدوام المشترك — يستخدمه المخبر (جدول الفنّي) والملف الشخصي
// (جدول دوام الموظف). مُرقّى إلى core لأنّه مفهوم عابر للميزات (تجنّب تشابك
// الميزات: profile لا يستورد من lab والعكس).
//
// أيام العمل بقيم الباك (day_of_week): saturday..friday، بترتيب الأسبوع العربي.
// ════════════════════════════════════════════════════════════════════════════

import '../l10n/generated/app_localizations.dart';

/// أيام الأسبوع لجدول الدوام — الاسم يطابق قيمة الباك (day_of_week).
enum WorkDay { saturday, sunday, monday, tuesday, wednesday, thursday, friday }

extension WorkDayX on WorkDay {
  /// القيمة المُرسَلة/المستقبَلة من الباك (saturday, sunday, ...).
  String get apiValue => name;

  /// يحوّل قيمة الباك إلى [WorkDay] (null إن لم تُطابق).
  static WorkDay? fromApi(String? v) {
    final s = (v ?? '').trim().toLowerCase();
    for (final d in WorkDay.values) {
      if (d.name == s) return d;
    }
    return null;
  }
}

/// اسم اليوم المُترجَم (مصدر واحد لكل الشاشات).
String workDayLabel(AppLocalizations l10n, WorkDay day) => switch (day) {
      WorkDay.saturday => l10n.daySaturday,
      WorkDay.sunday => l10n.daySunday,
      WorkDay.monday => l10n.dayMonday,
      WorkDay.tuesday => l10n.dayTuesday,
      WorkDay.wednesday => l10n.dayWednesday,
      WorkDay.thursday => l10n.dayThursday,
      WorkDay.friday => l10n.dayFriday,
    };

/// فترة دوام ليوم واحد — الوقت بصيغة "HH:mm" (تطابق H:i بالباك).
class WorkShift {
  const WorkShift({
    required this.day,
    required this.start,
    required this.end,
  });

  final WorkDay day;
  final String start;
  final String end;

  WorkShift copyWith({String? start, String? end}) => WorkShift(
        day: day,
        start: start ?? this.start,
        end: end ?? this.end,
      );

  /// يبني فترة من عنصر schedule الخام للباك ({day|day_of_week, start_time, end_time}).
  static WorkShift? fromRaw(Map<String, dynamic> raw) {
    final day = WorkDayX.fromApi('${raw['day'] ?? raw['day_of_week'] ?? ''}');
    if (day == null) return null;
    return WorkShift(
      day: day,
      start: _hm('${raw['start_time'] ?? ''}'),
      end: _hm('${raw['end_time'] ?? ''}'),
    );
  }

  /// العنصر بصيغة الباك للإرسال (updateTechnicianWorkSchedule).
  Map<String, String> toApi() => {
        'day_of_week': day.apiValue,
        'start_time': start,
        'end_time': end,
      };

  /// يقصّ الوقت إلى "HH:mm" (الباك قد يرجّع "HH:mm:ss").
  static String _hm(String t) => t.length >= 5 ? t.substring(0, 5) : t;
}
