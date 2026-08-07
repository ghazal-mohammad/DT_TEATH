// ════════════════════════════════════════════════════════════════════════════
// outbox_entry.dart
//
// عنصر واحد في طابور الصادر (outbox): عملية كتابة (create/update/delete) عُمِلت
// أثناء انقطاع الاتصال، محفوظة على القرص لإعادة إرسالها للباك عند رجوع الشبكة.
//
// مستقل عن أي مورد: يحمل الفعل (HTTP method)، المسار، الجسم، ومفتاح المورد +
// معرّف الكيان المحلّي (لمصالحة الكاش عند النجاح).
// ════════════════════════════════════════════════════════════════════════════

/// نوع عملية الكتابة المؤجَّلة.
enum OutboxMethod { post, put, delete }

extension OutboxMethodX on OutboxMethod {
  String get wire => switch (this) {
        OutboxMethod.post => 'POST',
        OutboxMethod.put => 'PUT',
        OutboxMethod.delete => 'DELETE',
      };

  static OutboxMethod fromWire(String v) => switch (v.toUpperCase()) {
        'PUT' => OutboxMethod.put,
        'DELETE' => OutboxMethod.delete,
        _ => OutboxMethod.post,
      };
}

/// عملية كتابة مؤجَّلة واحدة.
class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.resource,
    required this.method,
    required this.path,
    required this.createdAt,
    this.body,
    this.localEntityId,
    this.attempts = 0,
  });

  /// معرّف فريد للعملية نفسها (لإزالتها بعد النجاح).
  final String id;

  /// مفتاح المورد (مثل 'warehouse_materials') — لمصالحة الكاش.
  final String resource;

  /// الفعل.
  final OutboxMethod method;

  /// مسار الباك النسبي (endpoint).
  final String path;

  /// جسم الطلب (لـ POST/PUT) — null لـ DELETE.
  final Map<String, dynamic>? body;

  /// المعرّف المحلّي للكيان المتأثّر (اختياري — لمطابقة العناصر التفاؤلية).
  final String? localEntityId;

  /// وقت الإنشاء (للترتيب FIFO).
  final DateTime createdAt;

  /// عدد محاولات الإرسال الفاشلة (لتفادي حلقة لا نهائية على خطأ دائم).
  final int attempts;

  OutboxEntry copyWith({int? attempts}) => OutboxEntry(
        id: id,
        resource: resource,
        method: method,
        path: path,
        body: body,
        localEntityId: localEntityId,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'resource': resource,
        'method': method.wire,
        'path': path,
        if (body != null) 'body': body,
        if (localEntityId != null) 'local_entity_id': localEntityId,
        'created_at': createdAt.toIso8601String(),
        'attempts': attempts,
      };

  factory OutboxEntry.fromJson(Map<String, dynamic> j) => OutboxEntry(
        id: j['id'].toString(),
        resource: (j['resource'] ?? '').toString(),
        method: OutboxMethodX.fromWire((j['method'] ?? 'POST').toString()),
        path: (j['path'] ?? '').toString(),
        body: j['body'] is Map
            ? Map<String, dynamic>.from(j['body'] as Map)
            : null,
        localEntityId: j['local_entity_id']?.toString(),
        createdAt:
            DateTime.tryParse('${j['created_at']}') ?? DateTime.now(),
        attempts: (j['attempts'] as num?)?.toInt() ?? 0,
      );
}
