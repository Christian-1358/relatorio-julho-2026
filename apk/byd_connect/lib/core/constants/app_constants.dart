class AppConstants {
  // App info
  static const String appName = 'BYD Connect';
  static const String appVersion = '1.0.0';

  // Car status simulation
  static const int defaultBatteryLevel = 78;
  static const bool defaultLockedStatus = true;
  static const int defaultClimateTemp = 22;
  static const int defaultFanSpeed = 3;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Simulated delays
  static const Duration commandDelay = Duration(milliseconds: 800);

  // UI constants
  static const double borderRadius = 16.0;
  static const double iconBorderRadius = 12.0;
  static const double iconSize = 48.0;
  static const double smallIconSize = 32.0;
  static const double largeIconSize = 64.0;

  // Navigation
  static const List<String> bottomNavItems = [
    'Início',
    'Câmeras',
    'Status',
    'Clima',
    'Comandos',
    'Bancos',
    'Mídia',
    'Bateria',
    'Local',
    'Sentinela',
  ];
}
