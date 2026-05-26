class AppConstants {
  static const String appName = 'MySuF';
  static const String supportEmail = 'support@mysuf.id';
  static const String apiBaseUrl = String.fromEnvironment(
    'MYSUF_API_BASE_URL',
    defaultValue: 'https://api.smkn1wringin.sch.id/api/v1',
  );

  static const Duration registrationPollInterval = Duration(seconds: 3);
  static const Duration registrationRefreshDebounce = Duration(seconds: 2);

  static const int maxVehiclesPerFamily = 2;
  static const int maxFamilyMembers = 4;
  
  // Shared key for symmetric XOR obfuscation of E-KTP NIK in QR codes
  static const String qrisSecretKey = 'YTAU!@*@!^18728yLAHD{:{{';
}
