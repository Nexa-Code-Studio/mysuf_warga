import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../services/navigator_service.dart';
import '../../features/auth/data/auth_secure_storage.dart';

class AuthExpiredInterceptor extends Interceptor {
  final AuthSecureStorage _secureStorage = AuthSecureStorage();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null && response.statusCode == 403) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is String) {
          final isFrozen = detail.contains('dibekukan') || detail.contains('freeze');
          final isBlocked = detail.contains('diblokir') || detail.contains('blocked') || detail.contains('banned');
          
          if (isFrozen || isBlocked) {
            final accessToken = await _secureStorage.loadAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              // Clear session to log out
              await _secureStorage.clearSession();
              
              // Redirect to restricted screen
              final context = NavigatorService.navigatorKey.currentContext;
              if (context != null && context.mounted) {
                context.go('/restricted', extra: detail);
              }
            }
          }
        }
      }
    }
    super.onError(err, handler);
  }
}

Dio createDio() {
  final dio = Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl));
  dio.interceptors.add(AuthExpiredInterceptor());
  return dio;
}
