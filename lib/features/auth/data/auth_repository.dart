import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import 'auth_local_storage.dart';
import 'auth_secure_storage.dart';
import '../domain/auth_session.dart';
import '../domain/registration_attempt.dart';

class AuthRepository {
  AuthRepository({
    Dio? dio,
    AuthLocalStorage? localStorage,
    AuthSecureStorage? secureStorage,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl)),
       _localStorage = localStorage ?? AuthLocalStorage(),
       _secureStorage = secureStorage ?? AuthSecureStorage();

  final Dio _dio;
  final AuthLocalStorage _localStorage;
  final AuthSecureStorage _secureStorage;

  Future<AuthSession> signIn(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'client_type': 'BUYER_ANDROID',
        },
      );

      final payload = response.data;
      if (payload == null) {
        throw Exception('Backend tidak mengembalikan data login.');
      }

      final session = AuthSession.fromJson(payload);
      await _secureStorage.saveSession(session);
      return session;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<RegistrationAttempt> submitRegistrationAttempt({
    required String nik,
    required String email,
    required String password,
    required String ktpPhotoPath,
    required String selfiePhotoPath,
    String? ocrRawText,
  }) async {
    final payload = <String, Object>{
      'nik': nik,
      'email': email,
      'password': password,
      'ktp_photo': await MultipartFile.fromFile(
        ktpPhotoPath,
        filename: _fileNameFromPath(ktpPhotoPath),
      ),
      'selfie_photo': await MultipartFile.fromFile(
        selfiePhotoPath,
        filename: _fileNameFromPath(selfiePhotoPath),
      ),
    };
    if (ocrRawText != null) {
      payload['ocr_raw_text'] = ocrRawText;
    }
    final formData = FormData.fromMap(payload);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/buyer-registrations/',
        data: formData,
      );

      final payload = response.data;
      if (payload == null) {
        throw Exception('Backend tidak mengembalikan data pendaftaran.');
      }

      final attempt = RegistrationAttempt.fromJson(payload);
      await savePendingRegistrationAttemptId(attempt.id);
      return attempt;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<RegistrationAttempt> getRegistrationAttemptStatus(
    String attemptId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/buyer-registrations/$attemptId',
      );

      final payload = response.data;
      if (payload == null) {
        throw Exception('Status pendaftaran tidak tersedia.');
      }
      return RegistrationAttempt.fromJson(payload);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<void> savePendingRegistrationAttemptId(String attemptId) {
    return _localStorage.savePendingRegistrationAttemptId(attemptId);
  }

  Future<String?> loadPendingRegistrationAttemptId() {
    return _localStorage.loadPendingRegistrationAttemptId();
  }

  Future<void> clearPendingRegistrationAttemptId() {
    return _localStorage.clearPendingRegistrationAttemptId();
  }

  Future<String?> loadAccessToken() {
    return _secureStorage.loadAccessToken();
  }

  Future<String?> loadRefreshToken() {
    return _secureStorage.loadRefreshToken();
  }

  Future<void> clearSession() {
    return _secureStorage.clearSession();
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

  String _fileNameFromPath(String path) {
    return File(path).uri.pathSegments.last;
  }
}
