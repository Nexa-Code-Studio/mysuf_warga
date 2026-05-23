class AuthSession {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final String userName;
  final String userEmail;
  final List<String> roles;
  final List<String> allowedApps;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.roles,
    required this.allowedApps,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return AuthSession(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      userId: user['id'] as String? ?? '',
      userName: user['name'] as String? ?? '',
      userEmail: user['email'] as String? ?? '',
      roles: (user['roles'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      allowedApps: (json['allowed_apps'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
