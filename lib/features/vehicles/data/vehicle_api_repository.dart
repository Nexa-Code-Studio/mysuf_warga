import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/domain/auth_session.dart';
import '../../../shared/models/vehicle.dart';
import '../../auth/data/auth_secure_storage.dart';
import '../domain/vehicle_submission_result.dart';

class VehicleApiRepository {
  VehicleApiRepository({
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

  Future<VehicleSubmissionResult> submitVehicle({
    required String registrationNumber,
    required String usageType,
    required String stnkPhotoPath,
    required String vehiclePhotoPath,
    String? productiveBusinessProofPath,
  }) async {
    final payload = <String, Object>{
      'registration_number': registrationNumber,
      'usage_type': usageType,
      'stnk_photo': await MultipartFile.fromFile(
        stnkPhotoPath,
        filename: _fileNameFromPath(stnkPhotoPath),
      ),
      'vehicle_photo': await MultipartFile.fromFile(
        vehiclePhotoPath,
        filename: _fileNameFromPath(vehiclePhotoPath),
      ),
    };
    if (productiveBusinessProofPath != null) {
      payload['productive_business_proof'] = await MultipartFile.fromFile(
        productiveBusinessProofPath,
        filename: _fileNameFromPath(productiveBusinessProofPath),
      );
    }

    final formData = FormData.fromMap(payload);

    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/vehicle-ownerships/submissions',
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan hasil submit kendaraan.');
      }

      return VehicleSubmissionResult.fromJson(body);
    });
  }

  Future<List<Vehicle>> fetchMyVehicles() async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/vehicle-ownerships/me',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan data kendaraan.');
      }

      final items = body['items'] as List<dynamic>? ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(Vehicle.fromJson)
          .toList();
    });
  }

  Future<VehicleDetail> fetchVehicleDetail(String ownershipId) async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/vehicle-ownerships/$ownershipId/detail',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan detail kendaraan.');
      }

      return VehicleDetail.fromJson(body);
    });
  }

  Future<List<PendingVehicleRequest>> fetchPendingVehicleRequests() async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/vehicle-ownerships/submissions/me',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan daftar pengajuan kendaraan.');
      }

      final items = body['items'] as List<dynamic>? ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(PendingVehicleRequest.fromJson)
          .toList();
    });
  }

  Future<PendingVehicleRequestDetail> fetchPendingVehicleRequestDetail(
    String requestId,
  ) async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/vehicle-ownerships/submissions/$requestId/detail',
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final body = response.data;
      if (body == null) {
        throw Exception('Backend tidak mengembalikan detail pengajuan kendaraan.');
      }

      return PendingVehicleRequestDetail.fromJson(body);
    });
  }

  Future<VehicleDocumentPreviewData> fetchVehicleDocument({
    required String ownershipId,
    required VehicleDocument document,
  }) async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<List<int>>(
        '/vehicle-ownerships/$ownershipId/documents/${document.id}',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final bytes = response.data;
      if (bytes == null) {
        throw Exception('Dokumen kendaraan tidak tersedia.');
      }

      return VehicleDocumentPreviewData(
        bytes: bytes,
        mimeType: document.mimeType ?? 'application/octet-stream',
        fileName: document.originalFilename ?? document.storageKey,
      );
    });
  }

  Future<VehicleDocumentPreviewData> fetchPendingVehicleDocument({
    required String requestId,
    required VehicleDocument document,
  }) async {
    return _withAuthorizedAction((accessToken) async {
      final response = await _dio.get<List<int>>(
        '/vehicle-ownerships/submissions/$requestId/documents/${document.id}',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          },
        ),
      );

      final bytes = response.data;
      if (bytes == null) {
        throw Exception('Dokumen pengajuan kendaraan tidak tersedia.');
      }

      return VehicleDocumentPreviewData(
        bytes: bytes,
        mimeType: document.mimeType ?? 'application/octet-stream',
        fileName: document.originalFilename ?? document.storageKey,
      );
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

  String _fileNameFromPath(String path) {
    return File(path).uri.pathSegments.last;
  }
}
