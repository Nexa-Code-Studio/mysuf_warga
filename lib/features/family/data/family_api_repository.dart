import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/data/auth_secure_storage.dart';
import '../../../features/auth/domain/auth_session.dart';
import '../../../shared/models/family_member.dart';

class FamilyApiRepository {
  FamilyApiRepository({
    Dio? dio,
    AuthSecureStorage? secureStorage,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl)),
       _secureStorage = secureStorage ?? AuthSecureStorage();

  final Dio _dio;
  final AuthSecureStorage _secureStorage;

  Future<AuthSession> _refreshSession() async {
    final refreshToken = await _secureStorage.loadRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Sesi login sudah habis. Silakan login kembali.');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
          'client_type': 'BUYER_ANDROID',
        },
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan data refresh session.');
      }

      final session = AuthSession.fromJson(body);
      await _secureStorage.saveSession(session);
      return session;
    } on DioException catch (error) {
      await _secureStorage.clearSession();
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<T> _withAuthorizedAction<T>(
    Future<T> Function(String accessToken) action,
  ) async {
    var accessToken = await _secureStorage.loadAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }

    try {
      return await action(accessToken);
    } on DioException catch (error) {
      if (error.response?.statusCode != 401) {
        throw Exception(_extractErrorMessage(error));
      }

      final refreshedSession = await _refreshSession();
      return action(refreshedSession.accessToken);
    }
  }

  Future<FamilyOverview> fetchMyFamilyOverview() async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/family/me',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan data keluarga.');
      }

      return FamilyOverview.fromJson(body);
    });
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
    }

    return error.message ?? 'Terjadi kesalahan jaringan. Coba lagi.';
  }
}
