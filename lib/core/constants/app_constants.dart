class AppConstants {
  static const String appName = 'MySuF';
  static const String supportEmail = 'support@mysuf.id';
  static const bool useLocalhost = bool.fromEnvironment(
    'USE_LOCALHOST',
    defaultValue: false,
  );

  static const String apiBaseUrl = useLocalhost
      ? 'http://localhost:8080/api/v1'
      : String.fromEnvironment(
          'MYSUF_API_BASE_URL',
          defaultValue: 'https://mysuf.nexacode.dev/api/v1',
        );

  static const Duration registrationPollInterval = Duration(seconds: 3);
  static const Duration registrationRefreshDebounce = Duration(seconds: 2);

  static const int maxVehiclesPerFamily = 2;
  static const int maxFamilyMembers = 4;
  
  // Shared key for symmetric XOR obfuscation of E-KTP NIK in QR codes
  static const String qrisSecretKey = 'YTAU!@*@!^18728yLAHD{:{{';
}
