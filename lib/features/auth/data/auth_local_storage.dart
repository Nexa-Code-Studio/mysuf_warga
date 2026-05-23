import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const _pendingAttemptIdKey = 'pending_registration_attempt_id';

  Future<void> savePendingRegistrationAttemptId(String attemptId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingAttemptIdKey, attemptId);
  }

  Future<String?> loadPendingRegistrationAttemptId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingAttemptIdKey);
  }

  Future<void> clearPendingRegistrationAttemptId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingAttemptIdKey);
  }
}
