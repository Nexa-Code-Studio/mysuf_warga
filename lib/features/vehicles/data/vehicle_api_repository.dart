import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/app_constants.dart';
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

  Future<VehicleSubmissionResult> submitVehicle({
    required String registrationNumber,
    required String usageType,
    required String stnkPhotoPath,
    required String vehiclePhotoPath,
    String? productiveBusinessProofPath,
  }) async {
    final accessToken = await _secureStorage.loadAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }

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

    try {
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
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
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

  String _fileNameFromPath(String path) {
    return File(path).uri.pathSegments.last;
  }
}
