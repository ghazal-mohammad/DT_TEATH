// ════════════════════════════════════════════════════════════════════════════
// fake_warehouse_backend.dart
//
// Minimal fake local HTTP backend (pure dart:io, no packages) implementing
// just enough of the real `warehouseManager/*` endpoints (see
// lib/core/network/endpoints.dart) to let the real app reach the warehouse
// dashboard and materials-list screens over a real socket — no Dart-side
// mocking, no Dio interception.
//
// Endpoints implemented (verified by reading the real repositories/
// datasources that call them — see warehouse_flow_test.dart for the trace):
//   GET /api/warehouseManager/showALLMaterials        (materials list page +
//                                                       dashboard badge reuse)
//   GET /api/warehouseManager/mostRequestedMaterials   (InventoryCubit.load)
//   GET /api/warehouseManager/expiringSoonMaterials    (InventoryCubit.load)
//   GET /api/warehouseManager/lowStockMaterials        (InventoryCubit.load)
//   GET /api/warehouseManager/showAllMaterialRequests  (WarehouseRequestsCubit)
//
// Anything else 404s loudly (with the path logged to stdout) so a wrong
// assumption about what the app actually calls surfaces as a real test
// failure instead of a silent pass.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:io';

class FakeWarehouseBackend {
  FakeWarehouseBackend({this.port = 8011});

  final int port;
  HttpServer? _server;

  /// When true, GET showALLMaterials returns a 500 with a malformed body
  /// instead of the seeded materials — used for the fail→pass proof that the
  /// integration test genuinely exercises the fake backend's response.
  bool failMaterialsEndpoint = false;

  /// Seeded materials — shape matches the backend's `formatMaterial` contract
  /// consumed by WarehouseMaterial.fromJson (lib/features/warehouse/domain/
  /// entities/warehouse_material.dart): id, name, name_en, company_name,
  /// price_per_unit, dosage, unit, category(clinic|lab|both), total_stock,
  /// batches_count.
  final List<Map<String, dynamic>> _materials = [
    {
      'id': 1,
      'name': 'قفازات لاتكس M',
      'name_en': 'Latex Gloves M',
      'company_name': 'MedSupply Co',
      'category': 'clinic',
      'price_per_unit': 1500.0,
      'dosage': null,
      'unit': 'علبة',
      'total_stock': 240,
      'batches_count': 3,
    },
    {
      'id': 2,
      'name': 'راتنج تعبئة مركّب',
      'name_en': 'Composite Resin',
      'company_name': '3M Dental',
      'category': 'lab',
      'price_per_unit': 85000.0,
      'dosage': '4g',
      'unit': 'أنبوب',
      'total_stock': 36,
      'batches_count': 2,
    },
    {
      'id': 3,
      'name': 'كحول طبي 70%',
      'name_en': 'Medical Alcohol 70%',
      'company_name': 'Al-Shifa Pharma',
      'category': 'both',
      'price_per_unit': 3200.0,
      'dosage': null,
      'unit': 'لتر',
      'total_stock': 18,
      'batches_count': 1,
    },
  ];

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    // ignore: avoid_print
    print('[FakeWarehouseBackend] listening on http://127.0.0.1:$port');
    _server!.listen(
      _handle,
      onError: (Object e) {
        // ignore: avoid_print
        print('[FakeWarehouseBackend] listen error: $e');
      },
    );
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest request) async {
    final path = request.uri.path;
    final method = request.method;
    try {
      switch ('$method $path') {
        case 'GET /api/warehouseManager/showALLMaterials':
          await _handleMaterials(request);
          break;

        case 'GET /api/warehouseManager/mostRequestedMaterials':
          await _respondJson(request, 200, {
            'data': [
              {
                'material_id': '1',
                'name': 'قفازات لاتكس M',
                'unit': 'علبة',
                'request_count': 5,
                'total_quantity': 50,
              },
            ],
          });
          break;

        case 'GET /api/warehouseManager/expiringSoonMaterials':
          await _respondJson(request, 200, {
            'data': {
              'batches': [
                {
                  'batch_id': '101',
                  'material_id': '3',
                  'name': 'كحول طبي 70%',
                  'unit': 'لتر',
                  'quantity': 5,
                  'expiration_date': DateTime.now()
                      .add(const Duration(days: 12))
                      .toIso8601String(),
                  'days_remaining': 12,
                },
              ],
            },
          });
          break;

        case 'GET /api/warehouseManager/lowStockMaterials':
          await _respondJson(request, 200, {
            'data': {
              'items': [
                {
                  'material_id': '3',
                  'name': 'كحول طبي 70%',
                  'unit': 'لتر',
                  'total_quantity': 18,
                  'is_out': false,
                },
              ],
            },
          });
          break;

        case 'GET /api/warehouseManager/showAllMaterialRequests':
          await _respondJson(request, 200, {
            'data': [
              {
                'id': 501,
                'status': 'new',
                'requester': {'name': 'Lab Manager Test'},
                'requester_type': 'lab',
                'items': [
                  {
                    'id': 1,
                    'material': 'قفازات لاتكس M',
                    'quantity_requested': 10,
                    'status': 'new',
                  },
                ],
                'new_items': <Map<String, dynamic>>[],
                'notes': null,
                'created_at': DateTime.now().toIso8601String(),
              },
            ],
          });
          break;

        default:
          // ignore: avoid_print
          print(
            '[FakeWarehouseBackend] UNHANDLED $method $path — the real '
            'app requested a route the fake backend does not implement.',
          );
          await _respondJson(request, 404, {
            'message': 'Not found: $method $path',
          });
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[FakeWarehouseBackend] ERROR handling $method $path: $e\n$st');
      try {
        request.response.statusCode = 500;
        await request.response.close();
      } catch (_) {
        /* connection already gone */
      }
    }
  }

  Future<void> _handleMaterials(HttpRequest request) async {
    if (failMaterialsEndpoint) {
      request.response.statusCode = 500;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{not-valid-json');
      await request.response.close();
      return;
    }
    await _respondJson(request, 200, {'data': _materials});
  }

  Future<void> _respondJson(
    HttpRequest request,
    int status,
    Map<String, dynamic> body,
  ) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    await request.response.close();
  }
}
