// ════════════════════════════════════════════════════════════════════════════
// fake_lab_backend.dart
//
// Minimal, real dart:io HttpServer standing in for the Laravel backend during
// the lab-manager black-box integration test. It implements only the real
// endpoint the lab dashboard + doctor-orders-list screens actually call on
// load — GET /api/labManager/showAllLabOrders (see
// lib/features/lab/data/repositories/remote_lab_orders_repository.dart and
// lib/features/lab/presentation/bloc/lab_dashboard_cubit.dart, which both
// resolve to LabOrdersRepository.getAll() -> LabOrdersRemoteDataSource.getAll()
// -> GET ApiEndpoints.labManagerShowAllLabOrders).
//
// Everything else 404s on purpose. AppSearchWarmup (core/search/app_search_warmup.dart)
// fires a handful of other lab endpoints fire-and-forget on dashboard load
// (showAllLabItems, showAllTechnicians, showAllMaterialRequests, showLabStock)
// but swallows all errors, so a 404 there is invisible to the UI and does not
// affect the flow under test — it's a deliberate simplification, not a gap.
//
// Response shape matches RemoteLabOrdersRepository._fromJson exactly:
//   {success, data: [ {id, status, delivery_date_requested, notes, total_cost,
//     dentist:{name}, technician:{id,name}|null,
//     items:[{tooth_number, price, notes, type:{name,type,material}}]} ]}
// ════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:io';

/// Fake local stand-in for the lab-manager slice of the real Laravel backend.
class FakeLabBackend {
  HttpServer? _server;

  /// When true, GET showAllLabOrders returns a 500 with a malformed body —
  /// used only for the mandatory fail-then-pass proof, flipped by hand during
  /// verification (not exposed to the test itself).
  bool failOrders = false;

  int get port => _server?.port ?? 0;

  /// Seeded doctor-orders — realistic shape, matched field-for-field against
  /// the real backend contract documented in remote_lab_orders_repository.dart.
  List<Map<String, dynamic>> get _seededOrders => [
        {
          'id': 424201,
          'status': 'new',
          'delivery_date_requested': '2026-08-25',
          'notes': 'فحص أولي قبل التصنيع',
          'total_cost': 180000,
          'dentist': {'name': 'د. سارة السيد'},
          'technician': null,
          'items': [
            {
              'tooth_number': 14,
              'price': 180000,
              'notes': '',
              'type': {'name': 'تاج', 'type': 'crown', 'material': 'زيركون'},
            },
          ],
        },
        {
          'id': 424202,
          'status': 'in_progress',
          'delivery_date_requested': '2026-08-22',
          'notes': '',
          'total_cost': 220000,
          'dentist': {'name': 'د. عمر خليل'},
          'technician': {'id': 3, 'name': 'مازن الفني'},
          'items': [
            {
              'tooth_number': 21,
              'price': 220000,
              'notes': '',
              'type': {'name': 'جسر', 'type': 'bridge', 'material': 'خزف'},
            },
          ],
        },
        {
          'id': 424203,
          'status': 'completed',
          'delivery_date_requested': '2026-08-10',
          'notes': '',
          'total_cost': 95000,
          'dentist': {'name': 'د. لينا حداد'},
          'technician': {'id': 5, 'name': 'رامي الفني'},
          'items': [
            {
              'tooth_number': 36,
              'price': 95000,
              'notes': '',
              'type': {'name': 'حشوة', 'type': 'filling', 'material': 'كومبوزيت'},
            },
          ],
        },
        {
          'id': 424204,
          'status': 'cancelled',
          'delivery_date_requested': '2026-08-05',
          'notes': 'ألغي بطلب الطبيب',
          'total_cost': 0,
          'dentist': {'name': 'د. كريم عاصي'},
          'technician': null,
          'items': [
            {
              'tooth_number': 11,
              'price': 0,
              'notes': '',
              'type': {'name': 'قشرة', 'type': 'veneer', 'material': 'زيركون'},
            },
          ],
        },
      ];

  /// Starts listening on 127.0.0.1:[requestedPort] (default 8012 — reserved
  /// for the lab flow to avoid colliding with the auth (8010) and warehouse
  /// (8011) fake backends running concurrently in other agents' sessions).
  Future<void> start({int requestedPort = 8012}) async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, requestedPort);
    _server!.listen(_handle);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest request) async {
    final path = request.uri.path;
    final method = request.method;

    try {
      if (method == 'GET' && path == '/api/labManager/showAllLabOrders') {
        if (failOrders) {
          await _respond(
            request,
            HttpStatus.internalServerError,
            // Malformed on purpose too: not the {success,data:[...]} shape the
            // real parser expects, so a genuine parse-shaped failure surfaces
            // even if a caller ignored the status code.
            '{"message":"forced failure for fail-then-pass proof"}',
          );
          return;
        }
        await _respond(
          request,
          HttpStatus.ok,
          jsonEncode({'success': true, 'data': _seededOrders}),
        );
        return;
      }

      // Everything else: real 404 — surfaces any wrong assumption about what
      // the dashboard/orders screens call as a loud, visible test failure
      // rather than a silently-passing stub.
      await _respond(
        request,
        HttpStatus.notFound,
        jsonEncode({'message': 'fake_lab_backend: no handler for $method $path'}),
      );
    } catch (e) {
      await _respond(
        request,
        HttpStatus.internalServerError,
        jsonEncode({'message': 'fake_lab_backend internal error: $e'}),
      );
    }
  }

  Future<void> _respond(HttpRequest request, int status, String body) async {
    request.response
      ..statusCode = status
      ..headers.contentType = ContentType.json
      ..write(body);
    await request.response.close();
  }
}
