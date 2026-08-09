import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/utils/dio_client.dart';
import '../../auth/data/auth_secure_storage.dart';
import '../../auth/domain/auth_session.dart';
import '../domain/risk_state.dart';

class RiskRepository {
  RiskRepository({
    Dio? dio,
    AuthSecureStorage? secureStorage,
  }) : _dio = dio ?? createDio(),
       _secureStorage = secureStorage ?? AuthSecureStorage();

  final Dio _dio;
  final AuthSecureStorage _secureStorage;

  Future<RiskState> fetchRisk() async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/me/buyer-profile',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan data risiko.');
      }

      final score = double.tryParse((body['risk_score'] ?? '0').toString()) ?? 0;
      final riskLevel = score > 85
          ? RiskLevel.freeze
          : score >= 60
              ? RiskLevel.review
              : RiskLevel.safe;
      final statusLabel = riskLevel == RiskLevel.freeze
          ? 'Disuspend'
          : riskLevel == RiskLevel.review
              ? 'Dalam Review'
              : 'Aman';

      return RiskState(
        score: score,
        statusLabel: statusLabel,
        statusLevel: riskLevel,
        notes: [
          'Skor risiko mempengaruhi total quota subsidi yang dapat digunakan.',
          'Akun akan disuspend otomatis jika skor melebihi 85.',
        ],
      );
    });
  }

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

  Future<T> _withAuthorizedAction<T>(Future<T> Function(String accessToken) action) async {
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
