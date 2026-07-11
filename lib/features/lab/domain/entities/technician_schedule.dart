// ════════════════════════════════════════════════════════════════════════════
// technician_schedule.dart
//
// كيانات جدول دوام الفنّي (domain) — أيام الأسبوع + فترة الدوام.
// أيام العمل بقيم الباك (day_of_week): saturday..friday، بترتيب الأسبوع العربي
// (السبت أولاً). نقي (pure Dart) بلا اعتماد على Flutter.
// ════════════════════════════════════════════════════════════════════════════

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

  /// يبني فترة من عنصر schedule الخام للباك ({day, start_time, end_time}).
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
