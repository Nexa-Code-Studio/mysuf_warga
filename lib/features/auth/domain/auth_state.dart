class AuthState {
  final bool isAuthenticated;
  final String? userName;

  const AuthState({
    required this.isAuthenticated,
    this.userName,
  });
}
