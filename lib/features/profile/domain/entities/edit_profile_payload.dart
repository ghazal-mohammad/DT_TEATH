// ════════════════════════════════════════════════════════════════════════════
// edit_profile_payload.dart
//
// حمولة تعديل الملف الشخصي. تبني FormData (multipart) بالحقول المرسلة فقط
// (null = لا تُرسل) مطابقةً لـ UpdateEmployeeProfileRequest في الباك:
//   name, phone, date_of_birth, address, gender(1|2),
//   profile_picture(ملف), secondary_phone, marital_status.
// ════════════════════════════════════════════════════════════════════════════

import 'dart:typed_data';

import 'package:dio/dio.dart';

class EditProfilePayload {
  const EditProfilePayload({
    this.name,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.secondaryPhone,
    this.maritalStatus,
    this.imageBytes,
    this.imageFilename,
  });

  final String? name;
  final String? phone;

  /// صيغة تاريخ يقبلها Laravel (مثل yyyy-MM-dd).
  final String? dateOfBirth;
  final String? address;

  /// 1 = ذكر، 2 = أنثى.
  final int? gender;
  final String? secondaryPhone;
  final String? maritalStatus;

  /// بايتات صورة البروفايل (web) — تُرسل كـ profile_picture.
  final Uint8List? imageBytes;
  final String? imageFilename;

  FormData toFormData() {
    final map = <String, dynamic>{};

    void put(String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      map[key] = value;
    }

    put('name', name);
    put('phone', phone);
    put('date_of_birth', dateOfBirth);
    put('address', address);
    put('gender', gender);
    put('secondary_phone', secondaryPhone);
    put('marital_status', maritalStatus);

    if (imageBytes != null && imageBytes!.isNotEmpty) {
      map['profile_picture'] = MultipartFile.fromBytes(
        imageBytes!,
        filename: imageFilename ?? 'profile_picture.jpg',
      );
    }

    return FormData.fromMap(map);
  }

  /// هل يوجد أي حقل فعلي للإرسال؟
  bool get isEmpty => toFormData().fields.isEmpty && toFormData().files.isEmpty;
}
