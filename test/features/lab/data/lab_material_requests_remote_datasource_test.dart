import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dt_teeth/core/network/endpoints.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_material_requests_remote_datasource.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late LabMaterialRequestsRemoteDataSource ds;

  setUp(() {
    dio = _MockDio();
    ds = LabMaterialRequestsRemoteDataSource(dio);
  });

  test('create يرسل الجسم كـ Map مباشرة لـ Dio.post (بلا FormData)', () async {
    when(() => dio.post<dynamic>(
          ApiEndpoints.labManagerAddMaterialRequest,
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.labManagerAddMaterialRequest),
          data: {'data': <String, dynamic>{}},
          statusCode: 200,
        ));

    final body = {
      'items': [
        {'material_id': 1, 'quantity_requested': 10},
      ],
    };
    await ds.create(body);

    final captured = verify(() => dio.post<dynamic>(
          ApiEndpoints.labManagerAddMaterialRequest,
          data: captureAny(named: 'data'),
        )).captured.single;
    expect(captured, isA<Map<String, dynamic>>());
    expect(captured, isNot(isA<FormData>()));
    expect((captured as Map)['items'], body['items']);
  });

  test('getOne يستدعي showMaterialRequest/{id}', () async {
    when(() => dio.get<dynamic>(ApiEndpoints.labManagerShowMaterialRequest(7))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.labManagerShowMaterialRequest(7)),
        data: {'data': {'id': 7}},
        statusCode: 200,
      ),
    );
    final res = await ds.getOne(7);
    expect(res['id'], 7);
  });

  test('getWarehouseMaterial يستدعي showWarehouseMaterial/{id}', () async {
    when(() => dio.get<dynamic>(ApiEndpoints.labManagerShowWarehouseMaterial(3))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiEndpoints.labManagerShowWarehouseMaterial(3)),
        data: {'data': {'id': 3, 'material_id': 3}},
        statusCode: 200,
      ),
    );
    final res = await ds.getWarehouseMaterial(3);
    expect(res['material_id'], 3);
  });
}
