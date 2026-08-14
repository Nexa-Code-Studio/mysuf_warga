import 'dart:io';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../services/navigator_service.dart';
import '../../features/auth/data/auth_secure_storage.dart';
import '../../features/auth/domain/auth_session.dart';

class AuthExpiredInterceptor extends QueuedInterceptor {
  final AuthSecureStorage _secureStorage = AuthSecureStorage();
  
  // We need a separate Dio instance for refreshing to avoid recursive interceptor loops
  final Dio _refreshDio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));

  Future<void> _redirectToLogin() async {
    await _secureStorage.clearSession();
    final context = NavigatorService.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go('/login');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.loadAccessToken();
    final hasAuth = options.headers.containsKey(HttpHeaders.authorizationHeader);
    if (!hasAuth && token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final requestOptions = err.requestOptions;
    
    // 1. Handle 403 Frozen / Blocked Account
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
              await _secureStorage.clearSession();
              final context = NavigatorService.navigatorKey.currentContext;
              if (context != null && context.mounted) {
                context.go('/restricted', extra: detail);
              }
              handler.next(err);
              return;
            }
          }
        }
      }
    }

    // 2. Handle 401 Unauthorized / Token Expiration
    final isAuthEndpoint = requestOptions.path.contains('/auth/login') ||
        requestOptions.path.contains('/auth/refresh');
    final canRetry = requestOptions.extra['retried'] != true;

    if (response?.statusCode == 401 && !isAuthEndpoint && canRetry) {
      final refreshToken = await _secureStorage.loadRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _redirectToLogin();
        handler.next(err);
        return;
      }

      try {
        final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
          '/auth/refresh',
          data: {
            'refresh_token': refreshToken,
            'client_type': 'BUYER_ANDROID',
          },
        );

        final body = refreshResponse.data;
        if (body == null) {
          await _redirectToLogin();
          handler.next(err);
          return;
        }

        final session = AuthSession.fromJson(body);
        await _secureStorage.saveSession(session);

        // Update auth header and retry request
        requestOptions.headers[HttpHeaders.authorizationHeader] = 'Bearer ${session.accessToken}';
        requestOptions.extra['retried'] = true;
        
        final retryDio = Dio(BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ));
        final retryResponse = await retryDio.fetch<dynamic>(requestOptions);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        await _redirectToLogin();
        handler.next(err);
        return;
      }
    }

    // If it's the refresh endpoint itself failing with 401/400, clear session and go to login
    if (isAuthEndpoint && requestOptions.path.contains('/auth/refresh')) {
      await _redirectToLogin();
    }

    super.onError(err, handler);
  }
}

Dio createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));
  dio.interceptors.add(AuthExpiredInterceptor());
  return dio;
}
