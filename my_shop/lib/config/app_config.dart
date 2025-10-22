class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://35.72.93.241:2015',
  );

  static const bool isProduction =
      bool.fromEnvironment('IS_PROD', defaultValue: false);
}
