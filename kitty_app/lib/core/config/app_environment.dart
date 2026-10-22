/// Supported deployment environment profiles for Kitty App.
enum AppEnvironment {
  /// Offline sandbox mock profile using local JSON fixtures (100% backend independent).
  mock,

  /// Internal local development backend profile.
  dev,

  /// Staging server profile for integration testing.
  staging,

  /// Production bank-grade backend profile.
  prod;

  /// Parses string value into [AppEnvironment] with fallback to [mock].
  static AppEnvironment fromString(String? value) {
    if (value == null || value.trim().isEmpty) return AppEnvironment.mock;
    return AppEnvironment.values.firstWhere(
      (AppEnvironment e) => e.name.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => AppEnvironment.mock,
    );
  }

  /// Whether this profile uses local mock repositories.
  bool get isMock => this == AppEnvironment.mock;

  /// Whether this profile is targeted for production.
  bool get isProduction => this == AppEnvironment.prod;
}
