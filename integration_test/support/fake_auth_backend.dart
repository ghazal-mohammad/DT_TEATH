// ════════════════════════════════════════════════════════════════════════════
// fake_auth_backend.dart
//
// Minimal, pure-Dart (dart:io HttpServer) fake implementation of the real
// Laravel employee-auth endpoints, for use ONLY by integration_test/. It is
// NOT a mock of Dart code — the real app's real Dio client makes real HTTP
// requests over a real loopback socket to this server, exactly as it would
// to the real backend. This lets integration_test/auth_flow_test.dart drive
// the real widget tree through a real network round trip with zero mocking
// anywhere in lib/.
//
// Contract implemented (verified against the current Dart client code, not
// the (stale) docs/ markdown):
//   - lib/core/network/endpoints.dart          → the 5 real paths below.
//   - lib/features/auth/data/datasources/auth_remote_datasource.dart
//     → requests arrive as multipart FormData (email, verification_code,
//       password fields — never JSON).
//   - lib/core/auth/auth_models.dart           → EmployeeUser.fromJson's
//     dual response shape:
//       • login        → token/token_type INSIDE `user`.
//       • setPassword  → token/token_type at the JSON ROOT, alongside `user`
//                        (which itself has no token field).
//   - lib/features/auth/data/repositories/auth_repository_impl.dart
//     → errors are detected purely by HTTP status code (any non-2xx is
//       surfaced as a Failure with `body['message']` as the text).
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';

class FakeAuthBackend {
  FakeAuthBackend({this.port = 8010});

  final int port;
  HttpServer? _server;

  /// The one verification code the fake backend ever accepts.
  static const String fixedCode = '123456';

  /// The token returned by setPassword/login — the real app just needs any
  /// non-empty string (AuthRepositoryImpl throws UnexpectedFailure if empty).
  static const String fakeToken = 'fake-token-123';

  /// When true, /api/employee/login responds 401 with a deliberately wrong
  /// message instead of succeeding. Used ONLY for the fail→pass proof run —
  /// never true during the real passing run.
  bool forceLoginFailure = false;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server!.listen(_handle, onError: (Object _) {});
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final String path = request.uri.path;
      final Map<String, String> fields = await _parseMultipartFields(request);

      switch (path) {
        case '/api/employee/sendVerification':
          // Response body isn't parsed by the repository — any 200 is fine.
          _respond(request, 200, {'message': 'Verification code sent.'});
          break;

        case '/api/employee/verifyCode':
          final String? code = fields['verification_code'];
          if (code == fixedCode) {
            _respond(request, 200, {'message': 'Code verified.'});
          } else {
            _respond(request, 422, {'message': 'Invalid verification code.'});
          }
          break;

        case '/api/employee/setPassword':
          final String email = fields['email'] ?? '';
          // Token at ROOT, user WITHOUT token — matches EmployeeUser.fromJson
          // doc comment for the setPassword response shape.
          _respond(request, 200, {
            'message': 'Password set successfully.',
            'user': {
              'id': 1,
              'name': 'Test Lab Manager',
              'email': email,
              'role': 5, // 5 = lab manager (see EmployeeRole.fromApiId)
              'is_active': true,
            },
            'token': fakeToken,
            'token_type': 'Bearer',
          });
          break;

        case '/api/employee/login':
          if (forceLoginFailure) {
            _respond(request, 401, {'message': 'خطأ فعلي متعمد'});
            break;
          }
          final String email = fields['email'] ?? '';
          // Token INSIDE `user` — matches the real login response shape.
          _respond(request, 200, {
            'message': 'Login successful.',
            'user': {
              'id': 1,
              'name': 'Test Lab Manager',
              'email': email,
              'role': 5,
              'is_active': true,
              'token': fakeToken,
              'token_type': 'Bearer',
            },
          });
          break;

        case '/api/employee/logout':
          _respond(request, 200, {});
          break;

        default:
          _respond(request, 404, {'message': 'fake backend: no route for $path'});
      }
    } catch (e) {
      // Never let a parsing bug hang the request — surface it as a real
      // 500 so the test fails loudly instead of timing out.
      _respond(request, 500, {'message': 'fake backend error: $e'});
    }
  }

  /// Parses a multipart/form-data request body (as sent by Dio's
  /// FormData.fromMap) into a flat {fieldName: textValue} map. Only handles
  /// plain text fields — no file parts are expected from this app's auth
  /// endpoints, so none are supported here.
  Future<Map<String, String>> _parseMultipartFields(HttpRequest request) async {
    final ContentType? contentType = request.headers.contentType;
    final String? boundary = contentType?.parameters['boundary'];
    if (contentType == null || boundary == null) {
      return const {};
    }

    final result = <String, String>{};
    final transformer = MimeMultipartTransformer(boundary);
    await for (final MimeMultipart part in transformer.bind(request)) {
      final String disposition = part.headers['content-disposition'] ?? '';
      final RegExpMatch? nameMatch =
          RegExp(r'name="([^"]*)"').firstMatch(disposition);
      if (nameMatch == null) continue;
      final String fieldName = nameMatch.group(1)!;

      final bytes = <int>[];
      await for (final chunk in part) {
        bytes.addAll(chunk);
      }
      result[fieldName] = utf8.decode(bytes);
    }
    return result;
  }

  void _respond(HttpRequest request, int statusCode, Map<String, dynamic> body) {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(body));
    unawaited(request.response.close());
  }
}
