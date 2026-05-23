import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_session.dart';

class AuthSecureStorage {
  AuthSecureStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _tokenTypeKey = 'auth_token_type';
  static const _userIdKey = 'auth_user_id';
  static const _userNameKey = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveSession(AuthSession session) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: session.accessToken,
    );
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: session.refreshToken,
    );
    await _secureStorage.write(key: _tokenTypeKey, value: session.tokenType);
    await _secureStorage.write(key: _userIdKey, value: session.userId);
    await _secureStorage.write(key: _userNameKey, value: session.userName);
    await _secureStorage.write(key: _userEmailKey, value: session.userEmail);
  }

  Future<String?> loadAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> loadRefreshToken() {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenTypeKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userEmailKey);
  }
}
