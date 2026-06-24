// ════════════════════════════════════════════════════════════════════════════
// verify_lab_products.dart  — اختبار تكامل يدوي (لا يُشحَن)
//
// يشغّل مسار الكود الفعلي للفرونت (LabProductsRemoteDataSource →
// RemoteLabProductsRepository → mapping) ضد الباك الحي لإثبات المطابقة.
//
// التشغيل:
//   dart run tool/verify_lab_products.dart <TOKEN> [baseUrl]
// ════════════════════════════════════════════════════════════════════════════

// ignore_for_file: avoid_print  — أداة تحقّق CLI، الطباعة مقصودة.
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:dt_teeth/features/lab/data/datasources/lab_products_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_orders_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_material_requests_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/datasources/lab_remote_datasource.dart';
import 'package:dt_teeth/features/lab/data/repositories/remote_lab_products_repository.dart';
import 'package:dt_teeth/features/lab/data/repositories/remote_lab_orders_repository.dart';
import 'package:dt_teeth/features/lab/data/repositories/remote_lab_material_requests_repository.dart';
import 'package:dt_teeth/features/lab/data/repositories/lab_repository_impl.dart';
import 'package:dt_teeth/features/lab/domain/entities/lab_product.dart';

Future<void> main(List<String> args) async {
  // التوكن من LAB_TOKEN بالبيئة (آمن مع | في sanctum tokens)، أو args[0].
  final token = Platform.environment['LAB_TOKEN'] ??
      (args.isNotEmpty ? args[0] : '');
  if (token.isEmpty) {
    print('Set LAB_TOKEN env var (or pass token as arg).');
    return;
  }
  final baseUrl = Platform.environment['LAB_BASE'] ?? 'http://127.0.0.1:8000';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ));

  final repo = RemoteLabProductsRepository(LabProductsRemoteDataSource(dio));

  print('── getAll() عبر LabProductsRepository ───────────────────────────');
  final products = await repo.getAll();
  print('عدد المنتجات: ${products.length}');
  for (final p in products.take(4)) {
    print('  • #${p.id} ${p.name} | ${p.type}/${p.material} '
        '| ${p.price} ل.س | ${p.productionDays} يوم');
  }

  // الكتابة لا تُنفَّذ افتراضياً (تجنّباً لتلويث الداتا) — فعّلها بـ VERIFY_WRITE=1.
  if (Platform.environment['VERIFY_WRITE'] == '1') {
    print('\n── create() منتج جديد ─────────────────────────────────────────');
    final created = await repo.create(const LabProduct(
      id: '',
      name: 'منتج تحقّق الربط (احذفني)',
      type: 'تلبيسة',
      material: 'E-max',
      price: 88000,
      productionDays: 2,
    ));
    print('أُنشئ: #${created.id} ${created.name} '
        '| ${created.price} ل.س | ${created.productionDays} يوم');
  }

  print('\n── getAll() عبر LabOrdersRepository ─────────────────────────────');
  final ordersRepo = RemoteLabOrdersRepository(
    LabOrdersRemoteDataSource(dio),
    LabRepositoryImpl(LabRemoteDataSource(dio)),
  );
  final orders = await ordersRepo.getAll();
  print('عدد الطلبات: ${orders.length}');
  for (final o in orders.take(4)) {
    print('  • #${o.id} ${o.doctor} | ${o.type}/${o.material} '
        '${o.tooth} | ${o.statusVariant.name} | ${o.cost} ل.س '
        '| فنّي: ${o.assignedTechnician ?? "—"}');
  }

  print('\n── getAll() عبر LabMaterialRequestsRepository ──────────────────');
  final mrRepo = RemoteLabMaterialRequestsRepository(
    LabMaterialRequestsRemoteDataSource(dio),
  );
  final reqs = await mrRepo.getAll();
  print('عدد طلبات المواد: ${reqs.length}');
  for (final r in reqs.take(4)) {
    print('  • #${r.id} ${r.material} ×${r.quantity} ${r.unit} '
        '| ${r.status.name} | شركة: ${r.company ?? "—"}');
  }

  print('\n✅ مسار الفرونت يطابق الباك الحي.');
}
