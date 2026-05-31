// ════════════════════════════════════════════════════════════════════════════
// profile_remote_datasource.dart
//
// مصدر بيانات الملف الشخصي للموظف — يتصل مباشرة بـ Dio.
// التوكن يُضاف تلقائياً عبر interceptor في DioClient.
// ════════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';

import '../../../../core/network/endpoints.dart';
import '../../domain/entities/edit_profile_payload.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);

  final Dio _dio;

  /// GET /api/employee/showProfile
  Future<Map<String, dynamic>> showProfile() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.employeeShowProfile);
    return _asMap(response.data);
  }

  /// POST /api/employee/editProfile (multipart/form-data)
  Future<Map<String, dynamic>> editProfile(EditProfilePayload payload) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.employeeEditProfile,
      data: payload.toFormData(),
    );
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
